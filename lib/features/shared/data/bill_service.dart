import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_validator.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:intl/intl.dart';

/// 账单列表分页结果。
class BillPage {
  final List<FortuneBillVo> rows;
  final int total;
  const BillPage({this.rows = const [], this.total = 0});
}

/// 月度/区间统计。
class BillStatistics {
  final double income;
  final double expense;
  final double surplus;
  const BillStatistics({this.income = 0, this.expense = 0, this.surplus = 0});

  factory BillStatistics.fromJson(Map<String, dynamic> json) => BillStatistics(
    income: FxApi.asDouble(json['income']) ?? 0,
    expense: FxApi.asDouble(json['expense']) ?? 0,
    surplus:
        FxApi.asDouble(json['surplus']) ??
        ((FxApi.asDouble(json['income']) ?? 0) -
            (FxApi.asDouble(json['expense']) ?? 0)),
  );
}

/// 账单查询条件。
class BillQuery {
  final int bookId;
  final int pageNum;
  final int pageSize;
  final int? billType;
  final List<int>? billTypes;
  final String? title;
  final String? tradeTimeStartTime; // yyyy-MM-dd
  final String? tradeTimeEndTime; // yyyy-MM-dd
  final double? amountMin;
  final double? amountMax;
  final int? accountId;
  final int? payeeId;
  final List<int>? categoryIds;
  final List<int>? tagIds;
  final bool? confirm;
  final bool? include;
  final String orderColumn;
  final String orderDirection;

  const BillQuery({
    required this.bookId,
    this.pageNum = 1,
    this.pageSize = 20,
    this.billType,
    this.billTypes,
    this.title,
    this.tradeTimeStartTime,
    this.tradeTimeEndTime,
    this.amountMin,
    this.amountMax,
    this.accountId,
    this.payeeId,
    this.categoryIds,
    this.tagIds,
    this.confirm,
    this.include,
    this.orderColumn = 'tradeTime',
    this.orderDirection = 'descending',
  });

  Map<String, dynamic> toQueryParams() {
    final m = <String, dynamic>{
      'bookId': bookId,
      'pageNum': pageNum,
      'pageSize': pageSize,
      'orderColumn': orderColumn,
      'orderDirection': orderDirection,
    };
    // 后端 getPage 只认单数字段 billType；billTypes 会被忽略。
    final resolvedBillType = billType ??
        (billTypes != null && billTypes!.length == 1 ? billTypes!.first : null);
    if (resolvedBillType != null) m['billType'] = resolvedBillType;
    if (title != null && title!.isNotEmpty) m['title'] = title;
    if (tradeTimeStartTime != null)
      m['tradeTimeStartTime'] = tradeTimeStartTime;
    if (tradeTimeEndTime != null) m['tradeTimeEndTime'] = tradeTimeEndTime;
    if (amountMin != null) m['amountMin'] = amountMin;
    if (amountMax != null) m['amountMax'] = amountMax;
    if (accountId != null) m['accountId'] = accountId;
    if (payeeId != null) m['payeeId'] = payeeId;
    if (categoryIds != null && categoryIds!.isNotEmpty)
      m['categoryIds'] = categoryIds;
    if (tagIds != null && tagIds!.isNotEmpty) m['tagIds'] = tagIds;
    if (confirm != null) m['confirm'] = confirm;
    if (include != null) m['include'] = include;
    return m;
  }
}

/// 账单附件 VO。
class BillFileVo {
  final int? fileId;
  final String? contentType;
  final String? fileData; // base64
  final int? size;
  final String? originalName;
  final int? billId;

  const BillFileVo({
    this.fileId,
    this.contentType,
    this.fileData,
    this.size,
    this.originalName,
    this.billId,
  });

  factory BillFileVo.fromJson(Map<String, dynamic> json) => BillFileVo(
    fileId: FxApi.asId(json['fileId']),
    contentType: json['contentType']?.toString(),
    fileData: json['fileData']?.toString(),
    size: FxApi.asId(json['size']),
    originalName: json['originalName']?.toString(),
    billId: FxApi.asId(json['billId']),
  );
}

/// 账单数据服务（覆盖现有 Retrofit BillService 未提供的接口）。
class BillService {
  final FxApi _api = FxApi.instance;

  Future<BillPage> getPage(BillQuery query) async {
    final multiTypes = query.billTypes;
    // 后端只支持单个 billType；多选时 App 侧按类型分别请求再合并。
    if (multiTypes != null && multiTypes.length > 1) {
      return _getPageMergedByTypes(query, multiTypes);
    }
    final data = await _api.get(
      '/fortune/bill/getPage',
      query: query.toQueryParams(),
    );
    return _parsePage(data);
  }

  /// 多类型筛选：后端不支持 billTypes，按类型分别拉取后在 App 合并分页。
  Future<BillPage> _getPageMergedByTypes(
    BillQuery query,
    List<int> types,
  ) async {
    final need = query.pageNum * query.pageSize;
    final pages = await Future.wait([
      for (final type in types)
        getPage(
          BillQuery(
            bookId: query.bookId,
            pageNum: 1,
            pageSize: need,
            billType: type,
            title: query.title,
            tradeTimeStartTime: query.tradeTimeStartTime,
            tradeTimeEndTime: query.tradeTimeEndTime,
            amountMin: query.amountMin,
            amountMax: query.amountMax,
            accountId: query.accountId,
            payeeId: query.payeeId,
            categoryIds: query.categoryIds,
            tagIds: query.tagIds,
            confirm: query.confirm,
            include: query.include,
            orderColumn: query.orderColumn,
            orderDirection: query.orderDirection,
          ),
        ),
    ]);
    final seen = <int?>{};
    final rows = <FortuneBillVo>[
      for (final page in pages)
        for (final row in page.rows)
          if (seen.add(row.billId)) row,
    ];
    rows.sort((a, b) {
      final at = a.tradeTime;
      final bt = b.tradeTime;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    final total = pages.fold<int>(0, (sum, p) => sum + p.total);
    final start = ((query.pageNum - 1) * query.pageSize).clamp(0, rows.length);
    final end = (start + query.pageSize).clamp(0, rows.length);
    return BillPage(rows: rows.sublist(start, end), total: total);
  }

  BillPage _parsePage(dynamic data) {
    if (data is Map) {
      final rowsRaw =
          data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[];
      final rows = (rowsRaw as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => FortuneBillVo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final total = FxApi.asId(data['total']) ?? rows.length;
      return BillPage(rows: rows, total: total);
    }
    if (data is List) {
      final rows = data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => FortuneBillVo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return BillPage(rows: rows, total: rows.length);
    }
    return const BillPage();
  }

  Future<BillStatistics> getStatistics({
    required int bookId,
    required String tradeTimeStartTime,
    required String tradeTimeEndTime,
  }) async {
    final data = await _api.get(
      '/fortune/include/getBillStatistics',
      query: {
        'bookId': bookId,
        'tradeTimeStartTime': tradeTimeStartTime,
        'tradeTimeEndTime': tradeTimeEndTime,
      },
    );
    if (data is Map) {
      return BillStatistics.fromJson(Map<String, dynamic>.from(data));
    }
    return const BillStatistics();
  }

  Future<List<BillFileVo>> getFiles(int billId) async {
    final data = await _api.get('/fortune/bill/file/$billId/getByBillId');
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => BillFileVo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<void> remove({required int bookId, required int billId}) =>
      _api.delete('/fortune/bill/$bookId/$billId/remove');

  Future<void> confirm({required int bookId, required int billId}) =>
      _api.patch('/fortune/bill/$bookId/$billId/confirm');

  Future<void> unConfirm({required int bookId, required int billId}) =>
      _api.patch('/fortune/bill/$bookId/$billId/unConfirm');

  Future<void> include({required int bookId, required int billId}) =>
      _api.patch('/fortune/bill/$bookId/$billId/include');

  Future<void> exclude({required int bookId, required int billId}) =>
      _api.patch('/fortune/bill/$bookId/$billId/exclude');

  /// 新增/编辑账单（multipart: data JSON part + files）。
  Future<void> submit(
    Map<String, dynamic> data, {
    required bool modify,
    List<BillAttachment>? attachments,
  }) async {
    final attachmentList = attachments ?? const <BillAttachment>[];
    await const BillAttachmentValidator().inspectAll(attachmentList);

    final formData = FormData();
    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(data),
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );
    for (final attachment in attachmentList) {
      final file = switch (attachment) {
        BytesBillAttachment(:final bytes, :final name) =>
          MultipartFile.fromBytes(bytes, filename: name),
        PathBillAttachment(:final path, :final name) =>
          await MultipartFile.fromFile(path, filename: name),
      };
      formData.files.add(MapEntry('files', file));
    }
    final path = modify ? '/fortune/bill/modify' : '/fortune/bill/add';
    final res = modify
        ? await _api.dio.put<dynamic>(
            path,
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          )
        : await _api.dio.post<dynamic>(
            path,
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
    FxApi.unwrapRaw(res);
  }

  static final DateFormat dayFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
}
