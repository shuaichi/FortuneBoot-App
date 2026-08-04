import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';

/// 周期记账数据服务：`/fortune/recurring/bill`。
class RecurringService {
  final FxApi _api = FxApi.instance;

  /// 规则分页。
  Future<List<RecurringRuleVo>> getRules({
    required int bookId,
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    final data = await _api.get(
      '/fortune/recurring/bill/getRulePage',
      query: {'bookId': bookId, 'pageNum': pageNum, 'pageSize': pageSize},
    );
    return _rows(data).map(RecurringRuleVo.fromJson).toList();
  }

  /// 补偿策略下拉。
  Future<List<RecoveryStrategyOption>> getRecoveryStrategy() async {
    final data = await _api.get('/fortune/recurring/bill/getRecoveryStrategy');
    return _rows(data).map(RecoveryStrategyOption.fromJson).toList();
  }

  /// cron 校验：cronExpression 是后端 @RequestParam（表单/query 参数），
  /// 不能放进 JSON body，否则 Spring 无法绑定导致校验恒失败。
  Future<bool> checkCronExpression(String cronExpression) async {
    final data = await _api.post(
      '/fortune/recurring/bill/checkCronExpression',
      query: {'cronExpression': cronExpression},
    );
    return FxApi.asBool(data);
  }

  /// 新增规则。billRequest 必须是对象（FortuneBillAddCommand）。
  Future<void> addRule(Map<String, dynamic> body) =>
      _api.post('/fortune/recurring/bill/addRule', data: body);

  /// 修改规则（body 需含 ruleId）。
  Future<void> modifyRule(Map<String, dynamic> body) =>
      _api.put('/fortune/recurring/bill/modifyRule', data: body);

  Future<void> removeRule({required int bookId, required int ruleId}) =>
      _api.delete('/fortune/recurring/bill/$bookId/$ruleId/removeRule');

  /// 启停：enableRule / disableRule。
  Future<void> toggleRule({
    required int bookId,
    required int ruleId,
    required bool enable,
  }) =>
      _api.patch(
        '/fortune/recurring/bill/$bookId/$ruleId/${enable ? 'enableRule' : 'disableRule'}',
      );

  /// 规则执行日志。
  Future<List<RecurringLogVo>> getLogs({
    required int bookId,
    required int ruleId,
  }) async {
    final data =
        await _api.get('/fortune/recurring/bill/$bookId/$ruleId/getLogByRuleId');
    return _rows(data).map(RecurringLogVo.fromJson).toList();
  }

  List<Map<String, dynamic>> _rows(dynamic data) {
    final List<dynamic> raw;
    if (data is Map) {
      raw = (data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[])
          as List<dynamic>;
    } else if (data is List) {
      raw = data;
    } else {
      return const [];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
