import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/logs/data/logs_models.dart';

/// 系统日志只读服务。对应后端 `/logs/operationLogs`、`/logs/loginLogs`。
class LogsService {
  final FxApi _api = FxApi.instance;

  Future<LogPage<OperationLog>> operationLogs({
    int pageNum = 1,
    int pageSize = 20,
    String? username,
  }) async {
    final data = await _api.get(
      '/logs/operationLogs',
      query: _query(
        pageNum: pageNum,
        pageSize: pageSize,
        username: username,
        orderColumn: 'operationTime',
      ),
    );
    return _parse(data, OperationLog.fromJson);
  }

  Future<LogPage<LoginLog>> loginLogs({
    int pageNum = 1,
    int pageSize = 20,
    String? username,
  }) async {
    final data = await _api.get(
      '/logs/loginLogs',
      query: _query(
        pageNum: pageNum,
        pageSize: pageSize,
        username: username,
        orderColumn: 'loginTime',
      ),
    );
    return _parse(data, LoginLog.fromJson);
  }

  Map<String, dynamic> _query({
    required int pageNum,
    required int pageSize,
    required String orderColumn,
    String? username,
  }) {
    final query = <String, dynamic>{
      'pageNum': pageNum,
      'pageSize': pageSize,
      'orderColumn': orderColumn,
      'orderDirection': 'descending',
    };
    final name = username?.trim();
    if (name != null && name.isNotEmpty) query['username'] = name;
    return query;
  }

  LogPage<T> _parse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is Map) {
      final rowsRaw =
          data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[];
      final rows = (rowsRaw as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final total = FxApi.asId(data['total']) ?? rows.length;
      return LogPage(rows: rows, total: total);
    }
    if (data is List) {
      final rows = data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return LogPage(rows: rows, total: rows.length);
    }
    return LogPage<T>();
  }
}
