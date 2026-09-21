import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';

/// 分页结果。
class PayeePage {
  final List<FortunePayeeVo> rows;
  final int total;
  const PayeePage({this.rows = const [], this.total = 0});
}

/// 交易对象数据服务 /fortune/payee（分页列表，含 can* 开关）。
class PayeeService {
  final FxApi _api = FxApi.instance;

  /// 分页查询：GET /fortune/payee/getPage。recycleBin 必传。
  ///
  /// 交易对象为扁平列表，UI 需全量展示；当 total 超过单页时循环拉取后续页聚合，
  /// 避免 >pageSize 时静默截断丢数据。
  Future<PayeePage> getPage({
    required int bookId,
    required bool recycleBin,
    String? payeeName,
    int pageSize = 200,
  }) async {
    final all = <FortunePayeeVo>[];
    var pageNum = 1;
    var total = 0;
    while (true) {
      final query = <String, dynamic>{
        'bookId': bookId,
        'recycleBin': recycleBin,
        'pageNum': pageNum,
        'pageSize': pageSize,
      };
      if (payeeName != null && payeeName.trim().isNotEmpty) {
        query['payeeName'] = payeeName.trim();
      }
      final data = await _api.get('/fortune/payee/getPage', query: query);
      final page = _parse(data);
      all.addAll(page.rows);
      total = page.total;
      if (page.rows.isEmpty || all.length >= total) break;
      pageNum++;
    }
    return PayeePage(rows: all, total: total);
  }

  PayeePage _parse(dynamic data) {
    if (data is! Map) return const PayeePage();
    final rowsRaw =
        (data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[])
            as List<dynamic>;
    final rows = rowsRaw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => FortunePayeeVo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final total = FxApi.asId(data['total']) ?? rows.length;
    return PayeePage(rows: rows, total: total);
  }

  Future<void> add(Map<String, dynamic> body) =>
      _api.post('/fortune/payee/add', data: body);

  Future<void> modify(Map<String, dynamic> body) =>
      _api.put('/fortune/payee/modify', data: body);

  /// 开关/回收站切换：PATCH /fortune/payee/{bookId}/{payeeId}/{action}。
  Future<void> toggle({
    required int bookId,
    required int payeeId,
    required String action,
  }) => _api.patch('/fortune/payee/$bookId/$payeeId/$action');

  Future<void> moveToRecycleBin({required int bookId, required int payeeId}) =>
      toggle(bookId: bookId, payeeId: payeeId, action: 'moveToRecycleBin');

  Future<void> putBack({required int bookId, required int payeeId}) =>
      toggle(bookId: bookId, payeeId: payeeId, action: 'putBack');

  Future<void> remove({required int bookId, required int payeeId}) =>
      _api.delete('/fortune/payee/$bookId/$payeeId/remove');
}
