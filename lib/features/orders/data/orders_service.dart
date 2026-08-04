import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';

/// 单据数据服务：分页 / 新增 / 修改 / 删除 / 状态机（using/close/reopen）。
class OrdersService {
  final FxApi _api = FxApi.instance;

  static const String _base = '/fortune/finance/order';

  Future<OrdersPage> getPage({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    String? title,
    int? type,
    int? status,
  }) async {
    final query = <String, dynamic>{
      'bookId': bookId,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (title != null && title.trim().isNotEmpty) query['title'] = title.trim();
    if (type != null) query['type'] = type;
    if (status != null) query['status'] = status;
    final data = await _api.get('$_base/getPage', query: query);
    return _parsePage(data);
  }

  OrdersPage _parsePage(dynamic data) {
    if (data is Map) {
      final rowsRaw =
          data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[];
      final rows = (rowsRaw as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (e) => FortuneFinanceOrderVo.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      final total = FxApi.asId(data['total']) ?? rows.length;
      return OrdersPage(rows: rows, total: total);
    }
    if (data is List) {
      final rows = data
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (e) => FortuneFinanceOrderVo.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      return OrdersPage(rows: rows, total: rows.length);
    }
    return const OrdersPage();
  }

  /// 使用中单据列表。
  Future<List<FortuneFinanceOrderVo>> getUsingList(int bookId) async {
    final data = await _api.get('$_base/$bookId/getUsingFinanceOrderList');
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (e) => FortuneFinanceOrderVo.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    return const [];
  }

  /// 新增：POST /add（bookId,title,type,remark?）。
  Future<void> add({
    required int bookId,
    required String title,
    required int type,
    String? remark,
  }) {
    final body = <String, dynamic>{
      'bookId': bookId,
      'title': title,
      'type': type,
    };
    if (remark != null && remark.trim().isNotEmpty) {
      body['remark'] = remark.trim();
    }
    return _api.post('$_base/add', data: body);
  }

  /// 修改：PUT /modify（+orderId）。
  Future<void> modify({
    required int bookId,
    required int orderId,
    required String title,
    required int type,
    String? remark,
  }) {
    final body = <String, dynamic>{
      'bookId': bookId,
      'orderId': orderId,
      'title': title,
      'type': type,
    };
    if (remark != null && remark.trim().isNotEmpty) {
      body['remark'] = remark.trim();
    }
    return _api.put('$_base/modify', data: body);
  }

  /// 删除：DELETE /{bookId}/{orderId}/remove。
  Future<void> remove({required int bookId, required int orderId}) =>
      _api.delete('$_base/$bookId/$orderId/remove');

  /// 状态机 PATCH：using / close / reopen。
  Future<void> transition({
    required int bookId,
    required int orderId,
    required String action,
  }) => _api.patch('$_base/$bookId/$orderId/$action');
}
