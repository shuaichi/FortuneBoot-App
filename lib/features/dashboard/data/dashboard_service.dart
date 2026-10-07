import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:intl/intl.dart';

/// 看板数据服务：净资产 / 收支趋势 / 分类支出等 include 端点。
///
/// 本月统计与最近账单复用 [BillService]，此处仅覆盖 dashboard 专属端点。
class DashboardService {
  final FxApi _api = FxApi.instance;

  static final DateFormat _day = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// 净资产总览：GET /fortune/include/{groupId}/getFortuneAssetsLiabilities。
  Future<AssetsLiabilities> getAssetsLiabilities(int groupId) async {
    final data = await _api.get(
      '/fortune/include/$groupId/getFortuneAssetsLiabilities',
    );
    if (data is Map) {
      return AssetsLiabilities.fromJson(Map<String, dynamic>.from(data));
    }
    return const AssetsLiabilities();
  }

  /// 支出趋势（日粒度）：GET /fortune/include/getExpenseTrends。
  /// [timePoint] 传账期内任意时刻；[start]/[end] 用于兼容新版账期窗口查询。
  Future<List<TrendPoint>> getExpenseTrends({
    required int bookId,
    required DateTime timePoint,
    DateTime? start,
    DateTime? end,
  }) async {
    final data = await _api.get(
      '/fortune/include/getExpenseTrends',
      query: {
        'bookId': bookId,
        'timeGranularity': 1,
        'timePoint': _dateTime.format(timePoint),
        if (start != null) 'startDate': _day.format(start),
        if (end != null) 'endDate': _day.format(end),
      },
    );
    return _parseList(data, TrendPoint.fromJson);
  }

  /// 收入趋势（日粒度）：GET /fortune/include/getIncomeTrends。
  Future<List<TrendPoint>> getIncomeTrends({
    required int bookId,
    required DateTime timePoint,
    DateTime? start,
    DateTime? end,
  }) async {
    final data = await _api.get(
      '/fortune/include/getIncomeTrends',
      query: {
        'bookId': bookId,
        'timeGranularity': 1,
        'timePoint': _dateTime.format(timePoint),
        if (start != null) 'startDate': _day.format(start),
        if (end != null) 'endDate': _day.format(end),
      },
    );
    return _parseList(data, TrendPoint.fromJson);
  }

  /// 分类支出 Top（本月）：GET /fortune/include/getCategoryExpense。
  Future<List<CategorySlice>> getCategoryExpense({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) async {
    final data = await _api.get(
      '/fortune/include/getCategoryExpense',
      query: {
        'bookId': bookId,
        'startDate': _day.format(start),
        'endDate': _day.format(end),
      },
    );
    final slices = data is Map
        ? _parseList(data['items'], CategorySlice.fromExpenseEnvelope)
        : _parseList(data, CategorySlice.fromJson);
    slices.sort((a, b) => b.value.compareTo(a.value));
    return slices;
  }

  static List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <T>[];
  }
}
