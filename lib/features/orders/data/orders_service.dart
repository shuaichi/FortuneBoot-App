import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_validator.dart';

/// C08 V2 单据客户端。所有新单据读写必须走本服务，不再混用旧接口。
class OrdersService {
  OrdersService({Dio? dio}) : _dio = dio ?? FxApi.instance.dio;

  static const String _base = '/fortune/finance/order/v2';
  final Dio _dio;

  Future<FinanceOrderPage> getPage({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    int? type,
    int? status,
    String? settlementState,
    String? keyword,
    String? title,
    bool overdueOnly = false,
  }) async {
    final query = <String, dynamic>{
      'bookId': bookId,
      'pageNum': pageNum,
      'pageSize': pageSize,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (settlementState != null && settlementState.isNotEmpty)
        'settlementState': settlementState,
      if ((keyword ?? title)?.trim().isNotEmpty == true)
        'keyword': (keyword ?? title)!.trim(),
      if (overdueOnly) 'overdueOnly': true,
    };
    final data = await _get('$_base/page', query);
    return FinanceOrderPage.fromJson(data);
  }

  Future<FinanceOrderDetail> getDetail({
    required int bookId,
    required int orderId,
  }) async {
    final data = await _get('$_base/$bookId/$orderId', const {});
    return _parseDetail(data);
  }

  Future<FinanceOrderSummary> getSummary({required int bookId}) async {
    final data = await _get('$_base/$bookId/summary', const {});
    return _parse(data, FinanceOrderSummary.fromJson);
  }

  Future<FinanceOrderPage> getOptions({
    required int bookId,
    required int billType,
    String? keyword,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final data = await _get('$_base/$bookId/options', {
      'billType': billType,
      if (keyword != null && keyword.trim().isNotEmpty)
        'keyword': keyword.trim(),
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    return FinanceOrderPage.fromJson(data);
  }

  Future<FinanceOrderEntryPage> getEntries({
    required int bookId,
    required int orderId,
    int pageNum = 1,
    int pageSize = 20,
    String entryStatus = 'ACTIVE',
  }) async {
    final data = await _get('$_base/$bookId/$orderId/entries', {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'entryStatus': entryStatus,
    });
    return FinanceOrderEntryPage.fromJson(data);
  }

  Future<FinanceOrderAuditPage> getAudit({
    required int bookId,
    required int orderId,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final data = await _get('$_base/$bookId/$orderId/audit', {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    return FinanceOrderAuditPage.fromJson(data);
  }

  Future<FinanceOrderReconciliationPage> getReconciliation({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final data = await _get('$_base/$bookId/reconciliation', {
      'pageNum': pageNum,
      'pageSize': pageSize,
    });
    return FinanceOrderReconciliationPage.fromJson(data);
  }

  Future<FinanceOrderMutationResult> create(
    FinanceOrderCreateInput command,
  ) async {
    final data = await _post('$_base/create', command.toJson());
    return _parseMutation(data);
  }

  Future<FinanceOrderMutationResult> modify(
    FinanceOrderMetadataInput command,
  ) async {
    final data = await _put('$_base/modify', command.toJson());
    return _parseMutation(data);
  }

  Future<FinanceOrderMutationResult> transition({
    required int bookId,
    required int orderId,
    required Object action,
    String? requestId,
    int? expectedVersion,
  }) async {
    final actionValue = action is FinanceOrderTransitionAction
        ? action.value
        : action.toString();
    if (requestId == null || expectedVersion == null) {
      final response = await _dio.patch<dynamic>(
        '/fortune/finance/order/$bookId/$orderId/$actionValue',
      );
      return _parseMutation(FxApi.unwrapRaw(response));
    }
    final data = await _post('$_base/$bookId/$orderId/$actionValue', {
      'bookId': bookId,
      'orderId': orderId,
      'requestId': requestId,
      'expectedVersion': expectedVersion,
    });
    return _parseMutation(data);
  }

  /// 旧订单页面兼容：只返回进行中的报销单。
  Future<List<FortuneFinanceOrderVo>> getUsingList(int bookId) async {
    final response = await _dio.get<dynamic>(
      '/fortune/finance/order/$bookId/getUsingFinanceOrderList',
    );
    final data = FxApi.unwrapRaw(response);
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => FortuneFinanceOrderVo.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((order) => order.isReimbursementOrder)
        .toList();
  }

  /// 旧订单页面兼容新增接口。
  Future<void> add({
    required int bookId,
    required String title,
    required int type,
    String? remark,
  }) async {
    final response = await _dio.post<dynamic>(
      '/fortune/finance/order/add',
      data: {
        'bookId': bookId,
        'title': title,
        'type': type,
        if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    FxApi.unwrapRaw(response);
  }

  /// 旧订单页面兼容修改接口。
  Future<void> modifyLegacy({
    required int bookId,
    required int orderId,
    required String title,
    required int type,
    String? remark,
  }) async {
    final response = await _dio.put<dynamic>(
      '/fortune/finance/order/modify',
      data: {
        'bookId': bookId,
        'orderId': orderId,
        'title': title,
        'type': type,
        if (remark != null && remark.trim().isNotEmpty)
          'remark': remark.trim(),
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    FxApi.unwrapRaw(response);
  }

  /// 旧订单页面兼容删除接口。
  Future<void> remove({required int bookId, required int orderId}) async {
    final response = await _dio.delete<dynamic>(
      '/fortune/finance/order/$bookId/$orderId/remove',
    );
    FxApi.unwrapRaw(response);
  }

  Future<FinanceOrderMutationResult> createEntry({
    required int bookId,
    required int orderId,
    required FinanceOrderEntryCommandInput command,
    List<BillAttachment> attachments = const [],
  }) async {
    final data = await _submitEntryForm(
      method: 'POST',
      path: '$_base/$bookId/$orderId/entries',
      command: command,
      attachments: attachments,
      includeBillId: false,
    );
    return _parseMutation(data);
  }

  Future<FinanceOrderMutationResult> modifyEntry({
    required int bookId,
    required int orderId,
    required int billId,
    required FinanceOrderEntryCommandInput command,
    List<BillAttachment> attachments = const [],
  }) async {
    final data = await _submitEntryForm(
      method: 'PUT',
      path: '$_base/$bookId/$orderId/entries/$billId',
      command: command.copyWith(billId: billId),
      attachments: attachments,
      includeBillId: true,
    );
    return _parseMutation(data);
  }

  Future<FinanceOrderMutationResult> entryAction({
    required int bookId,
    required int orderId,
    required int billId,
    required FinanceOrderEntryAction action,
    required String requestId,
    required int expectedVersion,
  }) async {
    final data = await _post(
      '$_base/$bookId/$orderId/entries/$billId/${action.value}',
      {
        'bookId': bookId,
        'orderId': orderId,
        'billId': billId,
        'requestId': requestId,
        'expectedVersion': expectedVersion,
      },
    );
    return _parseMutation(data);
  }

  Future<dynamic> _get(
    String path,
    Map<String, dynamic> query,
  ) async {
    final response = await _dio.get<dynamic>(path, queryParameters: query);
    return FxApi.unwrapRaw(response);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>(path, data: body);
    return FxApi.unwrapRaw(response);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final response = await _dio.put<dynamic>(path, data: body);
    return FxApi.unwrapRaw(response);
  }

  Future<dynamic> _submitEntryForm({
    required String method,
    required String path,
    required FinanceOrderEntryCommandInput command,
    required List<BillAttachment> attachments,
    required bool includeBillId,
  }) async {
    await const BillAttachmentValidator().inspectAll(attachments);
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(command.toJson(includeBillId: includeBillId)),
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );
    for (final attachment in attachments) {
      final file = switch (attachment) {
        BytesBillAttachment(:final bytes, :final name) =>
          MultipartFile.fromBytes(bytes, filename: name),
        PathBillAttachment(:final path, :final name) =>
          await MultipartFile.fromFile(path, filename: name),
      };
      formData.files.add(MapEntry('files', file));
    }
    final response = method == 'POST'
        ? await _dio.post<dynamic>(
            path,
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          )
        : await _dio.put<dynamic>(
            path,
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
    return FxApi.unwrapRaw(response);
  }

  FinanceOrderDetail _parseDetail(dynamic data) =>
      _parse(data, FinanceOrderDetail.fromJson);

  FinanceOrderMutationResult _parseMutation(dynamic data) =>
      _parse(data, FinanceOrderMutationResult.fromJson);

  T _parse<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is Map<String, dynamic>) return fromJson(data);
    if (data is Map) return fromJson(Map<String, dynamic>.from(data));
    throw const FxFailure(kind: FxFailureKind.invalidResponse);
  }
}
