import 'package:flutter/foundation.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';

/// 下拉选项（后端 {value,label} 通用结构）。
class OptionItem {
  final String value;
  final String label;

  const OptionItem({required this.value, required this.label});

  factory OptionItem.fromJson(Map<String, dynamic> json) => OptionItem(
    value: (json['value'] ?? '').toString(),
    label: (json['label'] ?? json['value'] ?? '').toString(),
  );
}

/// 账本与分组管理数据服务。
///
/// 分组走 `/fortune/group`，账本走 `/fortune/book/base`。全部经 [FxApi.instance]
/// 解包返 data，异常统一为 [FxApiException]。
class BooksService {
  final FxApi _api = FxApi.instance;

  // ---- 分组 ----

  /// 分组分页列表，用于管理页全量展示（包含启用/停用分组）。
  Future<PagedRows<ManagedGroup>> getGroupPage({
    int pageNum = 1,
    int pageSize = 500,
  }) async {
    try {
      final data = await _api.get(
        '/fortune/group/getPage',
        query: {'pageNum': pageNum, 'pageSize': pageSize},
      );
      final page = _pagedRows(data, ManagedGroup.fromJson);
      debugPrint(
        '[BooksService] getGroupPage raw=${_describeData(data)} rows=${page.rows.length} total=${page.total}',
      );
      if (page.rows.isNotEmpty) return page;
    } on FxApiException catch (e) {
      debugPrint('[BooksService] getGroupPage failed: ${e.message}');
      // 老接口环境可能没有 getPage，回退启用分组列表，至少保证管理页有数据。
    }
    final groups = await getEnabledGroups();
    debugPrint('[BooksService] getGroupPage fallback groups=${groups.length}');
    return PagedRows(
      rows: groups.map((group) => ManagedGroup(group: group)).toList(),
      total: groups.length,
    );
  }

  /// 启用分组列表（含当前用户 roleTypeDesc）。
  Future<List<FortuneGroupVo>> getGroups() => getEnabledGroups();

  Future<List<FortuneGroupVo>> getEnabledGroups() async {
    final data = await _api.get('/fortune/group/getEnableList');
    final groups = _rows(data).map(FortuneGroupVo.fromJson).toList();
    debugPrint(
      '[BooksService] getEnabledGroups raw=${_describeData(data)} rows=${groups.length}',
    );
    return groups;
  }

  Future<FortuneGroupVo?> getGroupById(int groupId) async {
    final data = await _api.get('/fortune/group/$groupId/getByGroupId');
    if (data is Map<dynamic, dynamic>) {
      return FortuneGroupVo.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<int?> getDefaultGroupId() async {
    final data = await _api.get('/fortune/group/getDefaultGroupId');
    if (data is Map<dynamic, dynamic>) {
      return FxApi.asId(
        data['groupId'] ?? data['defaultGroupId'] ?? data['id'],
      );
    }
    return FxApi.asId(data);
  }

  /// 货币模板。后端历史上 `value`=currencyId、`label`=币种代码；
  /// 与 Web 一致，业务字段存代码，故用 label（或已改为代码的 value）作为选项值。
  Future<List<OptionItem>> getCurrencyTemplate() async {
    final data = await _api.get('/fortune/group/getCurrencyTemplate');
    return _currencyRows(data).map((row) {
      final code = row.code;
      return OptionItem(value: code, label: code);
    }).toList();
  }

  /// 若误把 currencyId 存成了默认币种（如 `"33"`），按模板解析为币种代码。
  Future<String?> resolveCurrencyCode(String? raw) async {
    if (raw == null || raw.isEmpty) return raw;
    final trimmed = raw.trim();
    if (!_looksLikeCurrencyId(trimmed)) return trimmed;
    final rows = _currencyRows(
      await _api.get('/fortune/group/getCurrencyTemplate'),
    );
    for (final row in rows) {
      if (row.id == trimmed) return row.code;
    }
    // 模板缺失时的兜底：已知 33=CNY（currency-template.json）
    if (trimmed == '33') return 'CNY';
    return trimmed;
  }

  /// 提交前强制规范化；仍是数字 ID 则抛错，避免再次写入脏数据。
  Future<String> requireCurrencyCode(String? raw) async {
    final resolved = (await resolveCurrencyCode(raw))?.trim() ?? '';
    if (resolved.isEmpty) {
      throw FxApiException(-1, '请选择默认币种');
    }
    if (_looksLikeCurrencyId(resolved)) {
      throw FxApiException(-1, '币种数据异常（$resolved），请重新点选币种后再保存');
    }
    return resolved;
  }

  bool _looksLikeCurrencyId(String raw) => RegExp(r'^\d+$').hasMatch(raw);

  List<({String id, String code})> _currencyRows(dynamic data) {
    final list = <({String id, String code})>[];
    for (final json in _rows(data)) {
      final id = '${json['value'] ?? ''}'.split('.').first;
      final label = (json['label'] ?? '').toString().trim();
      final value = (json['value'] ?? '').toString().trim();
      // 兼容后端已改为 value=币种代码 的情况
      final code = label.isNotEmpty
          ? label
          : (_looksLikeCurrencyId(value) ? '' : value);
      if (code.isEmpty) continue;
      list.add((id: id, code: code));
    }
    return list;
  }

  Future<List<OptionItem>> getBookTemplate() async {
    final data = await _api.get('/fortune/group/getBookTemplate');
    return _rows(data).map(OptionItem.fromJson).toList();
  }

  Future<String?> getBookTemplateRemarkById(int id) async {
    final data = await _api.get('/fortune/group/$id/getBookTemplateRemarkById');
    return data?.toString();
  }

  Future<List<RoleTypeOption>> getRoleTypes() async {
    final data = await _api.get('/fortune/group/getRoleTypes');
    if (data is Map<dynamic, dynamic>) {
      final options = data.entries
          .map((e) => RoleTypeOption.fromEntry(e.key, e.value))
          .toList();
      options.sort((a, b) => a.value.compareTo(b.value));
      return options;
    }
    final options = _rows(data).map(RoleTypeOption.fromJson).toList();
    options.sort((a, b) => a.value.compareTo(b.value));
    return options;
  }

  Future<List<GroupMemberVo>> getGroupUsers(int groupId) async {
    final data = await _api.get('/fortune/group/$groupId/getGroupUser');
    return _rows(data).map(GroupMemberVo.fromJson).toList();
  }

  Future<void> inviteGroupUser({
    required int groupId,
    required String username,
    required int roleType,
  }) {
    return _api.post(
      '/fortune/group/inviteUser',
      data: {'groupId': groupId, 'username': username, 'roleType': roleType},
    );
  }

  Future<void> removeGroupUser(int relationId) =>
      _api.delete('/fortune/group/$relationId/removeGroupUser');

  Future<void> addGroup(Map<String, dynamic> body) =>
      _api.post('/fortune/group/add', data: body);

  Future<void> modifyGroup(Map<String, dynamic> body) =>
      _api.put('/fortune/group/modify', data: body);

  Future<void> removeGroup(int groupId) =>
      _api.delete('/fortune/group/$groupId/remove');

  Future<void> setDefaultGroup(int groupId) =>
      _api.patch('/fortune/group/$groupId/setDefaultGroup');

  Future<void> enableGroup(int groupId) =>
      _api.patch('/fortune/group/$groupId/enable');

  Future<void> disableGroup(int groupId) =>
      _api.patch('/fortune/group/$groupId/disable');

  /// 分组开关动作：setDefaultGroup / enable / disable。
  Future<void> groupAction(int groupId, String action) =>
      _api.patch('/fortune/group/$groupId/$action');

  // ---- 账本 ----

  /// 分组下账本分页（recycleBin 区分正常/回收站）。
  Future<List<FortuneBookVo>> getBooks({
    required int groupId,
    bool recycleBin = false,
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    final page = await getBookPage(
      groupId: groupId,
      recycleBin: recycleBin,
      pageNum: pageNum,
      pageSize: pageSize,
    );
    return page.rows;
  }

  Future<PagedRows<FortuneBookVo>> getBookPage({
    required int groupId,
    bool recycleBin = false,
    bool? enable,
    int pageNum = 1,
    int pageSize = 500,
  }) async {
    try {
      final query = <String, dynamic>{
        'groupId': groupId,
        'recycleBin': recycleBin,
        'pageNum': pageNum,
        'pageSize': pageSize,
      };
      if (enable != null) query['enable'] = enable;
      final data = await _api.get('/fortune/book/base/getPage', query: query);
      final page = _pagedRows(data, FortuneBookVo.fromJson);
      debugPrint(
        '[BooksService] getBookPage group=$groupId recycle=$recycleBin enable=$enable raw=${_describeData(data)} rows=${page.rows.length} total=${page.total}',
      );
      if (page.rows.isNotEmpty || recycleBin) return page;
    } on FxApiException catch (e) {
      debugPrint('[BooksService] getBookPage failed: ${e.message}');
      // 兼容旧接口环境。
    }
    if (recycleBin) return const PagedRows(rows: []);
    final books = await getBooksByGroupId(groupId);
    final filtered = enable == null
        ? books
        : books.where((book) => book.enable == enable).toList();
    return PagedRows(rows: filtered, total: filtered.length);
  }

  Future<List<FortuneBookVo>> getBooksByGroupId(int groupId) async {
    final data = await _api.get('/fortune/book/base/$groupId/getByGroupId');
    final books = _rows(data).map(FortuneBookVo.fromJson).toList();
    debugPrint(
      '[BooksService] getBooksByGroupId group=$groupId raw=${_describeData(data)} rows=${books.length}',
    );
    return books;
  }

  Future<List<FortuneBookVo>> getEnabledBooks(int groupId) async {
    final data = await _api.get('/fortune/book/base/$groupId/getEnableList');
    return _rows(data).map(FortuneBookVo.fromJson).toList();
  }

  Future<FortuneBookVo?> getBookById(int bookId) async {
    final data = await _api.get('/fortune/book/base/$bookId/getBookById');
    if (data is Map<dynamic, dynamic>) {
      return FortuneBookVo.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> addBook(Map<String, dynamic> body) =>
      _api.post('/fortune/book/base/add', data: body);

  Future<void> modifyBook(Map<String, dynamic> body) =>
      _api.put('/fortune/book/base/modify', data: body);

  Future<void> removeBook(int bookId) =>
      _api.delete('/fortune/book/base/$bookId/remove');

  Future<void> setDefaultBook(int bookId) =>
      _api.patch('/fortune/book/base/$bookId/setDefaultBook');

  Future<void> enableBook(int bookId) =>
      _api.patch('/fortune/book/base/$bookId/enable');

  Future<void> disableBook(int bookId) =>
      _api.patch('/fortune/book/base/$bookId/disable');

  Future<void> moveBookToRecycleBin(int bookId) =>
      _api.patch('/fortune/book/base/$bookId/moveToRecycleBin');

  Future<void> putBackBook(int bookId) =>
      _api.patch('/fortune/book/base/$bookId/putBack');

  /// 账本开关动作：moveToRecycleBin / putBack / setDefaultBook / enable / disable。
  Future<void> bookAction(int bookId, String action) =>
      _api.patch('/fortune/book/base/$bookId/$action');

  // ---- 支撑 ----

  Future<List<AccountOptionVo>> getEnabledAccounts(int groupId) async {
    final data = await _api.get('/fortune/account/$groupId/getEnableList');
    return _rows(data).map(AccountOptionVo.fromJson).toList();
  }

  Future<LoginUserInfo> getLoginUserInfo() async {
    final data = await _api.get('/getLoginUserInfo');
    if (data is Map<dynamic, dynamic>) {
      return LoginUserInfo.fromJson(Map<String, dynamic>.from(data));
    }
    return const LoginUserInfo();
  }

  // ---- 解析 ----

  PagedRows<T> _pagedRows<T>(
    dynamic data,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final rows = _rows(data).map(fromJson).toList();
    final page = data is Map<dynamic, dynamic>
        ? Map<String, dynamic>.from(data)
        : const <String, dynamic>{};
    final total = FxApi.asId(
      page['total'] ?? page['count'] ?? page['totalCount'] ?? page['totalRow'],
    );
    return PagedRows(rows: rows, total: total);
  }

  List<Map<String, dynamic>> _rows(dynamic data) {
    final Object? source;
    if (data is Map<dynamic, dynamic>) {
      source =
          data['records'] ??
          data['rows'] ??
          data['list'] ??
          data['items'] ??
          data['content'] ??
          data['data'];
    } else {
      source = data;
    }
    if (source is! List<dynamic>) return const [];
    return source
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _describeData(dynamic data) {
    if (data is Map<dynamic, dynamic>) {
      final keys = data.keys.map((e) => e.toString()).join(',');
      final samples = <String>[];
      for (final key in [
        'records',
        'rows',
        'list',
        'items',
        'content',
        'data',
      ]) {
        final value = data[key];
        if (value is List<dynamic>) samples.add('$key:${value.length}');
      }
      return 'Map{$keys} ${samples.join(' ')}';
    }
    if (data is List<dynamic>) return 'List(${data.length})';
    return data.runtimeType.toString();
  }
}
