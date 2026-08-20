import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fortuneboot/core/network/fx_api.dart';

/// 账单导入结果 VO（FortuneBillImportResultVo）。
class BillImportResult {
  final int total;
  final int successCount;
  final int failCount;
  final List<int> successBillIds;
  final String? message;

  const BillImportResult({
    this.total = 0,
    this.successCount = 0,
    this.failCount = 0,
    this.successBillIds = const [],
    this.message,
  });

  factory BillImportResult.fromJson(Map<String, dynamic> json) {
    final ids = <int>[];
    final raw = json['successBillIdList'] ?? json['billIdList'];
    if (raw is List) {
      for (final e in raw) {
        final id = FxApi.asId(e);
        if (id != null) ids.add(id);
      }
    }
    return BillImportResult(
      total: FxApi.asId(json['total'] ?? json['totalCount']) ?? 0,
      successCount:
          FxApi.asId(json['successCount'] ?? json['success']) ?? ids.length,
      failCount: FxApi.asId(json['failCount'] ?? json['fail']) ?? 0,
      successBillIds: ids,
      message: (json['msg'] ?? json['message'] ?? json['tip'])?.toString(),
    );
  }
}

/// 二进制结果：导出/模板/导入失败时的 Excel 字节流。
class BytesResult {
  final List<int> bytes;
  final String filename;
  const BytesResult({required this.bytes, required this.filename});
}

/// 导入返回：成功 JSON 或失败 Excel 字节流二选一。
class ImportOutcome {
  final BillImportResult? result; // application/json
  final BytesResult? errorFile; // 失败错误 Excel

  const ImportOutcome({this.result, this.errorFile});

  bool get isJson => result != null;
}

/// 导入导出数据服务：账单 Excel 导出 / 模板下载 / 导入。
///
/// 导出与模板下载返回字节流（非 HJResponse 包装），用 responseType bytes；
/// 导入按 Content-Type 分支：application/json → 结果 VO；否则 → 错误 Excel。
class IoService {
  final FxApi _api = FxApi.instance;

  Dio get _dio => _api.dio;

  static const String _xlsxMime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// 导出账单 Excel：GET /fortune/bill/excel（query=当前筛选，至少 bookId）。
  Future<BytesResult> exportBills(Map<String, dynamic> query) async {
    final res = await _dio.get<List<int>>(
      '/fortune/bill/excel',
      queryParameters: query,
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    _throwIfJsonError(res);
    return BytesResult(
      bytes: res.data ?? const [],
      filename: _filenameFrom(res, fallback: 'bills_export.xlsx'),
    );
  }

  /// 下载导入模板：GET /fortune/bill/{bookId}/excelTemplate。
  Future<BytesResult> downloadTemplate(int bookId) async {
    final res = await _dio.get<List<int>>(
      '/fortune/bill/$bookId/excelTemplate',
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    _throwIfJsonError(res);
    return BytesResult(
      bytes: res.data ?? const [],
      filename: _filenameFrom(res, fallback: 'bill_import_template.xlsx'),
    );
  }

  /// 导出/模板本应返回 Excel 字节流；若返回 application/json 则为错误体，
  /// 解析 code/msg 抛出，避免把错误 JSON 当成 .xlsx 保存。
  void _throwIfJsonError(Response<List<int>> res) {
    final contentType = (res.headers.value('content-type') ?? '').toLowerCase();
    if (!contentType.contains('application/json')) return;
    final json = _decodeJson(res.data ?? const <int>[]);
    final code = json == null ? null : FxApi.asId(json['code']);
    final msg = (json?['msg'] ?? json?['message'] ?? '导出失败').toString();
    throw FxApiException(code ?? -1, msg);
  }

  /// 导入账单：POST /fortune/bill/{bookId}/import（multipart file）。
  ///
  /// 用 bytes 接收，再按 Content-Type 判定：
  /// - application/json → 解析 [BillImportResult]（成功）；
  /// - 否则 → 视为错误 Excel 字节流。
  Future<ImportOutcome> importBills({
    required int bookId,
    required List<int> fileBytes,
    required String filename,
  }) async {
    final formData = FormData();
    formData.files.add(
      MapEntry('file', MultipartFile.fromBytes(fileBytes, filename: filename)),
    );
    final res = await _dio.post<List<int>>(
      '/fortune/bill/$bookId/import',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.bytes,
        // 不抛非 2xx，让业务层按内容判定（失败 Excel 也可能非 200）。
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    final contentType = (res.headers.value('content-type') ?? '').toLowerCase();
    final bytes = res.data ?? const <int>[];

    if (contentType.contains('application/json')) {
      final json = _decodeJson(bytes);
      if (json != null) {
        // 业务错误（code 非 0）以 JSON 返回：抛出真实 code/msg，避免被误读为
        // “成功 0/0/0”。code 缺省视为成功（部分接口直接返回裸 data）。
        final code = FxApi.asId(json['code']);
        if (code != null && code != 0) {
          final msg = (json['msg'] ?? json['message'] ?? '导入失败').toString();
          throw FxApiException(code, msg);
        }
        final data = json['data'];
        final payload = data is Map ? Map<String, dynamic>.from(data) : json;
        return ImportOutcome(result: BillImportResult.fromJson(payload));
      }
      throw FxApiException(-1, '导入失败');
    }
    if (bytes.isEmpty) throw FxApiException(-1, '导入失败');
    final isExcel =
        contentType.contains(_xlsxMime) ||
        contentType.contains('application/vnd.ms-excel') ||
        contentType.contains('application/octet-stream');
    if (!isExcel) throw FxApiException(-1, '导入失败');
    // 错误 Excel 字节流。
    return ImportOutcome(
      errorFile: BytesResult(
        bytes: bytes,
        filename: _filenameFrom(res, fallback: 'import_errors.xlsx'),
      ),
    );
  }

  static String get xlsxMime => _xlsxMime;

  /// 解码 JSON 响应为完整包（保留 code/msg/data，由调用方判定业务码）。
  Map<String, dynamic>? _decodeJson(List<int> bytes) {
    try {
      final text = utf8.decode(bytes, allowMalformed: true);
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on Object {
      return null;
    }
    return null;
  }

  String _filenameFrom(Response<dynamic> res, {required String fallback}) {
    final disposition = res.headers.value('content-disposition');
    if (disposition != null) {
      final match = RegExp('filename[^=]*=([^;]+)').firstMatch(disposition);
      var name = match?.group(1)?.trim();
      if (name != null && name.isNotEmpty) {
        // 去掉可能的引号与 UTF-8'' 前缀。
        name = name.replaceAll('"', '').replaceFirst("UTF-8''", '');
        if (name.isNotEmpty) return Uri.decodeComponent(name);
      }
    }
    return fallback;
  }
}
