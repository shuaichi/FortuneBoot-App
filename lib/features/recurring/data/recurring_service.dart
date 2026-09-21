import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/request/book_request.dart';

/// 周期规则所属账本引用（跨分组聚合用）。
class RecurringBookRef {
  final int bookId;
  final int groupId;
  final String? bookName;

  const RecurringBookRef({
    required this.bookId,
    required this.groupId,
    this.bookName,
  });
}

/// [probeRulesForBooks] 的探测结果。
class RecurringProbeResult {
  final List<RecurringRuleVo> rules;
  final Map<int, int> totalsByBook;
  final String? note;

  const RecurringProbeResult({
    required this.rules,
    required this.totalsByBook,
    this.note,
  });
}

/// 周期记账数据服务：`/fortune/recurring/bill`。
class RecurringService {
  RecurringService({FxApi? api, BookService? bookService})
    : _api = api ?? FxApi.instance,
      _bookService = bookService ?? BookService();

  final FxApi _api;
  final BookService _bookService;

  /// 解析用户可见的全部账本（所有分组）。
  Future<List<RecurringBookRef>> resolveAllBooks({
    required List<int> groupIds,
    List<RecurringBookRef> knownBooks = const [],
  }) async {
    final byId = <int, RecurringBookRef>{
      for (final b in knownBooks) b.bookId: b,
    };
    for (final groupId in groupIds) {
      try {
        final raw = FxApi.unwrap(await _bookService.getEnableList(groupId));
        for (final book in _booksOf(raw, groupId)) {
          byId[book.bookId] = book;
        }
      } on Object {
        try {
          final raw = FxApi.unwrap(await _bookService.getByGroupId(groupId));
          for (final book in _booksOf(raw, groupId)) {
            byId[book.bookId] = book;
          }
        } on Object {
          // ignore
        }
      }
    }
    return byId.values.toList();
  }

  Iterable<RecurringBookRef> _booksOf(dynamic raw, int fallbackGroupId) sync* {
    if (raw is! List) return;
    for (final e in raw) {
      if (e is! Map) continue;
      final map = Map<String, dynamic>.from(e);
      final bookId = FxApi.asId(map['bookId']);
      if (bookId == null) continue;
      yield RecurringBookRef(
        bookId: bookId,
        groupId: FxApi.asId(map['groupId']) ?? fallbackGroupId,
        bookName: map['bookName']?.toString(),
      );
    }
  }

  /// 多账本探测：返回规则 + 各账本服务端 total，便于空列表诊断。
  Future<RecurringProbeResult> probeRulesForBooks(List<int> bookIds) async {
    if (bookIds.isEmpty) {
      return const RecurringProbeResult(rules: [], totalsByBook: {});
    }
    final all = <RecurringRuleVo>[];
    final totals = <int, int>{};
    Object? lastError;
    var failCount = 0;
    var rawRowCount = 0;
    var parsedCount = 0;
    for (final bookId in bookIds) {
      try {
        final page = await _fetchFirstPage(bookId);
        totals[bookId] = page.total;
        rawRowCount += page.rawCount;
        parsedCount += page.rules.length;
        all.addAll(page.rules);
        // 若第一页未拉全，继续翻页。
        if (page.rules.isNotEmpty && page.rules.length < page.total) {
          all.addAll(
            await getRules(bookId: bookId, startPage: 2, knownTotal: page.total),
          );
        }
      } on Object catch (e) {
        failCount++;
        lastError = e;
        totals[bookId] = -1;
      }
    }
    if (all.isEmpty && failCount == bookIds.length && lastError != null) {
      throw lastError;
    }
    String? note;
    if (all.isEmpty && rawRowCount > 0 && parsedCount == 0) {
      note = '服务端返回了 $rawRowCount 行，但本地解析为 0（字段不兼容）';
    } else if (all.isEmpty) {
      final positive = totals.values.where((t) => t > 0).length;
      if (positive > 0) {
        note = '服务端 total>0 但 rows 解析为空';
      } else {
        note = '服务端对各账本均返回 total=0';
      }
    }
    return RecurringProbeResult(
      rules: await _alignExecutedCounts(all),
      totalsByBook: totals,
      note: note,
    );
  }

  /// 服务端 executedCount 会少计 1 次；以成功写入的执行日志条数为准。
  Future<List<RecurringRuleVo>> _alignExecutedCounts(
    List<RecurringRuleVo> rules,
  ) async {
    if (rules.isEmpty) return rules;
    return Future.wait(
      rules.map((rule) async {
        final bookId = rule.bookId;
        final ruleId = rule.ruleId;
        if (bookId == null || ruleId == null) return rule;
        try {
          final logs = await getLogs(bookId: bookId, ruleId: ruleId);
          if (logs.length == (rule.executedCount ?? 0)) return rule;
          return rule.copyWith(executedCount: logs.length);
        } on Object {
          return rule;
        }
      }),
    );
  }

  /// 多账本规则聚合。
  Future<List<RecurringRuleVo>> getRulesForBooks(List<int> bookIds) async {
    final probe = await probeRulesForBooks(bookIds);
    return probe.rules;
  }

  Future<_PageFetch> _fetchFirstPage(int bookId) async {
    final data = await _api.get(
      '/fortune/recurring/bill/getRulePage',
      query: {
        'bookId': bookId,
        'pageNum': 1,
        'pageSize': 200,
      },
    );
    final rawMaps = _mapsOf(data);
    final rules = _parseRowsFromMaps(rawMaps);
    final total = data is Map
        ? (FxApi.asId(data['total']) ?? rawMaps.length)
        : rawMaps.length;
    return _PageFetch(rules: rules, total: total, rawCount: rawMaps.length);
  }

  /// 规则分页。
  Future<List<RecurringRuleVo>> getRules({
    required int bookId,
    int pageSize = 200,
    int startPage = 1,
    int? knownTotal,
  }) async {
    final all = <RecurringRuleVo>[];
    var pageNum = startPage;
    var total = knownTotal ?? 0;
    var guard = 0;
    while (guard < 50) {
      guard++;
      final data = await _api.get(
        '/fortune/recurring/bill/getRulePage',
        query: {
          'bookId': bookId,
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );
      final rawMaps = _mapsOf(data);
      final rows = _parseRowsFromMaps(rawMaps);
      all.addAll(rows);
      if (data is Map) {
        total = FxApi.asId(data['total']) ?? (knownTotal ?? all.length);
      }
      if (rawMaps.isEmpty || rows.isEmpty || all.length >= total) break;
      pageNum++;
    }
    return all;
  }

  Future<List<RecoveryStrategyOption>> getRecoveryStrategy() async {
    final data = await _api.get('/fortune/recurring/bill/getRecoveryStrategy');
    return [
      for (final row in _mapsOf(data)) RecoveryStrategyOption.fromJson(row),
    ];
  }

  Future<bool> checkCronExpression(String cronExpression) async {
    final data = await _api.post(
      '/fortune/recurring/bill/checkCronExpression',
      query: {'cronExpression': cronExpression},
    );
    return FxApi.asBool(data);
  }

  Future<void> addRule(Map<String, dynamic> body) =>
      _api.post('/fortune/recurring/bill/addRule', data: body);

  Future<void> modifyRule(Map<String, dynamic> body) =>
      _api.put('/fortune/recurring/bill/modifyRule', data: body);

  Future<void> removeRule({required int bookId, required int ruleId}) =>
      _api.delete('/fortune/recurring/bill/$bookId/$ruleId/removeRule');

  Future<void> toggleRule({
    required int bookId,
    required int ruleId,
    required bool enable,
  }) => _api.patch(
    '/fortune/recurring/bill/$bookId/$ruleId/${enable ? 'enableRule' : 'disableRule'}',
  );

  Future<List<RecurringLogVo>> getLogs({
    required int bookId,
    required int ruleId,
  }) async {
    final data = await _api.get(
      '/fortune/recurring/bill/$bookId/$ruleId/getLogByRuleId',
    );
    return [
      for (final row in _mapsOf(data)) RecurringLogVo.fromJson(row),
    ];
  }

  List<RecurringRuleVo> _parseRowsFromMaps(List<Map<String, dynamic>> maps) {
    final out = <RecurringRuleVo>[];
    for (final row in maps) {
      try {
        out.add(RecurringRuleVo.fromJson(row));
      } on Object {
        // skip bad row
      }
    }
    return out;
  }

  List<Map<String, dynamic>> _mapsOf(dynamic data) {
    final List<dynamic> raw;
    if (data is Map) {
      final rows = data['rows'] ?? data['list'] ?? data['records'];
      if (rows is List) {
        raw = rows;
      } else if (data['data'] is List) {
        raw = data['data'] as List<dynamic>;
      } else {
        return const [];
      }
    } else if (data is List) {
      raw = data;
    } else {
      return const [];
    }
    return [
      for (final e in raw)
        if (e is Map) Map<String, dynamic>.from(e),
    ];
  }
}

class _PageFetch {
  final List<RecurringRuleVo> rules;
  final int total;
  final int rawCount;

  const _PageFetch({
    required this.rules,
    required this.total,
    required this.rawCount,
  });
}
