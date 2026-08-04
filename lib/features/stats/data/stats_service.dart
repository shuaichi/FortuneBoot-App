import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:intl/intl.dart';

/// 统计图表数据服务：趋势 / 分类占比 / 标签 / 交易对象。
///
/// 概览（income/expense/surplus）复用 [BillService.getStatistics]，此处不重复。
class StatsService {
  final FxApi _api = FxApi.instance;

  static final DateFormat _day = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm:ss');

  // ── 趋势（折线） ──────────────────────────────────────────

  /// 支出趋势：GET /fortune/include/getExpenseTrends。
  /// [timeGranularity]：日1/周2/月3；[timePoint] 传区间内代表点。
  Future<List<TrendPoint>> getExpenseTrends({
    required int bookId,
    required int timeGranularity,
    required DateTime timePoint,
  }) => _trends('getExpenseTrends', bookId, timeGranularity, timePoint);

  /// 收入趋势：GET /fortune/include/getIncomeTrends。
  Future<List<TrendPoint>> getIncomeTrends({
    required int bookId,
    required int timeGranularity,
    required DateTime timePoint,
  }) => _trends('getIncomeTrends', bookId, timeGranularity, timePoint);

  Future<List<TrendPoint>> _trends(
    String path,
    int bookId,
    int timeGranularity,
    DateTime timePoint,
  ) async {
    final data = await _api.get(
      '/fortune/include/$path',
      query: {
        'bookId': bookId,
        'timeGranularity': timeGranularity,
        'timePoint': _dateTime.format(timePoint),
      },
    );
    return _parseList(data, TrendPoint.fromJson);
  }

  // ── 分类占比（饼图） ──────────────────────────────────────

  /// 分类支出：GET /fortune/include/getCategoryExpense。
  Future<List<PieSlice>> getCategoryExpense({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _pie('getCategoryExpense', bookId, start, end);

  /// 分类收入：GET /fortune/include/getCategoryIncome。
  Future<List<PieSlice>> getCategoryIncome({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _pie('getCategoryIncome', bookId, start, end);

  // ── 交易对象（饼图） ──────────────────────────────────────

  /// 交易对象支出：GET /fortune/include/getPayeeExpense。
  Future<List<PieSlice>> getPayeeExpense({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _pie('getPayeeExpense', bookId, start, end);

  /// 交易对象收入：GET /fortune/include/getPayeeIncome。
  Future<List<PieSlice>> getPayeeIncome({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _pie('getPayeeIncome', bookId, start, end);

  Future<List<PieSlice>> _pie(
    String path,
    int bookId,
    DateTime start,
    DateTime end,
  ) async {
    final data = await _api.get(
      '/fortune/include/$path',
      query: {
        'bookId': bookId,
        'startDate': _day.format(start),
        'endDate': _day.format(end),
      },
    );
    final slices = _parseList(data, PieSlice.fromJson);
    slices.sort((a, b) => b.value.compareTo(a.value));
    return slices;
  }

  // ── 标签（柱图） ─────────────────────────────────────────

  /// 标签支出：GET /fortune/include/getTagExpense。
  Future<List<BarItem>> getTagExpense({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _bar('getTagExpense', bookId, start, end);

  /// 标签收入：GET /fortune/include/getTagIncome。
  Future<List<BarItem>> getTagIncome({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _bar('getTagIncome', bookId, start, end);

  Future<List<BarItem>> _bar(
    String path,
    int bookId,
    DateTime start,
    DateTime end,
  ) async {
    final data = await _api.get(
      '/fortune/include/$path',
      query: {
        'bookId': bookId,
        'startDate': _day.format(start),
        'endDate': _day.format(end),
      },
    );
    final items = _parseList(data, BarItem.fromJson);
    items.sort((a, b) => b.value.compareTo(a.value));
    return items;
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
