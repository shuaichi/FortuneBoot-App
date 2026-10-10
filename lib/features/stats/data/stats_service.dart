import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:intl/intl.dart';

/// 统计图表数据服务：趋势 / 分类占比 / 标签 / 交易对象 / 对比 / 排行。
///
/// 概览（income/expense/surplus）复用 BillService.getStatistics，
/// Dashboard/资产/借贷的聚合服务按 feature 独立封装。
class StatsService {
  StatsService({OrdersService? ordersService})
    : _ordersService = ordersService ?? OrdersService();

  final FxApi _api = FxApi.instance;
  final OrdersService _ordersService;

  static final DateFormat _day = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm:ss');

  // ── 趋势（折线） ──────────────────────────────────────────

  /// 支出趋势：GET /fortune/include/getExpenseTrends。
  /// [timeGranularity]：1近7天 / 2近30天 / 3近12月 / 4跨年。
  Future<List<TrendPoint>> getExpenseTrends({
    required int bookId,
    required int timeGranularity,
    DateTime? timePoint,
  }) => _trends('getExpenseTrends', bookId, timeGranularity, timePoint);

  /// 收入趋势：GET /fortune/include/getIncomeTrends。
  Future<List<TrendPoint>> getIncomeTrends({
    required int bookId,
    required int timeGranularity,
    DateTime? timePoint,
  }) => _trends('getIncomeTrends', bookId, timeGranularity, timePoint);

  Future<List<TrendPoint>> _trends(
    String path,
    int bookId,
    int timeGranularity,
    DateTime? timePoint,
  ) async {
    final data = await _api.get(
      '/fortune/include/$path',
      query: {
        'bookId': bookId,
        'timeGranularity': timeGranularity,
        if (timePoint != null) 'timePoint': _dateTime.format(timePoint),
      },
    );
    return _parseList(data, TrendPoint.fromJson);
  }

  // ── 基础统计扩展 ──────────────────────────────────────────

  /// V2 单据汇总：新借贷总览的唯一数据源。
  Future<FinanceOrderSummary> getFinanceOrderSummary({required int bookId}) =>
      _ordersService.getSummary(bookId: bookId);

  Future<List<BillComparePoint>> getBillCompare({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int compareType = 1,
    int? billType,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
    int? memberId,
  }) async {
    final data = await _api.get(
      '/fortune/include/getBillCompare',
      query: _includeQuery(
        bookId: bookId,
        start: start,
        end: end,
        billType: billType,
        categoryIds: categoryIds,
        tagIds: tagIds,
        payeeIds: payeeIds,
        accountId: accountId,
        memberId: memberId,
      )..['compareType'] = compareType,
    );
    return _parseList(data, BillComparePoint.fromJson);
  }

  Future<List<BillRankItem>> getBillRank({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int? billType,
    int topN = 10,
  }) async {
    final data = await _api.get(
      '/fortune/include/getBillRank',
      query: _includeQuery(
        bookId: bookId,
        start: start,
        end: end,
        billType: billType,
      )..['topN'] = topN,
    );
    return _parseList(data, BillRankItem.fromJson);
  }

  // ── 分类占比（饼图） ──────────────────────────────────────

  /// 分类支出：GET /fortune/include/getCategoryExpense。
  Future<List<PieSlice>> getCategoryExpense({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) async {
    final stat = await getCategoryExpenseStat(
      bookId: bookId,
      start: start,
      end: end,
    );
    return stat.items;
  }

  Future<DimensionStat<PieSlice>> getCategoryExpenseStat({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _dimensionEnvelope(
    'getCategoryExpense',
    bookId,
    start,
    end,
    PieSlice.fromCategoryExpense,
  );

  /// 分类收入：GET /fortune/include/getCategoryIncome。
  ///
  /// TODO(statistics): remove this dual parsing branch when income dimension
  /// endpoints return the same `{total, items}` envelope as expense endpoints.
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
  }) async {
    final stat = await getPayeeExpenseStat(
      bookId: bookId,
      start: start,
      end: end,
    );
    return stat.items;
  }

  Future<DimensionStat<PieSlice>> getPayeeExpenseStat({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _dimensionEnvelope(
    'getPayeeExpense',
    bookId,
    start,
    end,
    PieSlice.fromPayeeExpense,
  );

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
      query: _rangeQuery(bookId, start, end),
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
  }) async {
    final stat = await getTagExpenseStat(
      bookId: bookId,
      start: start,
      end: end,
    );
    return stat.items;
  }

  Future<DimensionStat<BarItem>> getTagExpenseStat({
    required int bookId,
    required DateTime start,
    required DateTime end,
  }) => _dimensionEnvelope(
    'getTagExpense',
    bookId,
    start,
    end,
    BarItem.fromTagExpense,
  );

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
      query: _rangeQuery(bookId, start, end),
    );
    final items = _parseList(data, BarItem.fromJson);
    items.sort((a, b) => b.value.compareTo(a.value));
    return items;
  }

  // ── 双向统计 ────────────────────────────────────────────

  Future<List<IncludeParticipantStat>> getAccountInclude({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int? billType,
  }) async {
    final data = await _api.get(
      '/fortune/include/getAccountInclude',
      query: _includeQuery(
        bookId: bookId,
        start: start,
        end: end,
        billType: billType,
      ),
    );
    return _parseList(data, IncludeParticipantStat.fromAccount);
  }

  Future<List<IncludeParticipantStat>> getMemberInclude({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int? billType,
  }) async {
    final data = await _api.get(
      '/fortune/include/getMemberInclude',
      query: _includeQuery(
        bookId: bookId,
        start: start,
        end: end,
        billType: billType,
      ),
    );
    return _parseList(data, IncludeParticipantStat.fromMember);
  }

  Future<List<DateIncludePoint>> getDateInclude({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int? billType,
    List<int>? categoryIds,
    List<int>? tagIds,
  }) async {
    final data = await _api.get(
      '/fortune/include/getDateInclude',
      query: _includeQuery(
        bookId: bookId,
        start: start,
        end: end,
        billType: billType,
        categoryIds: categoryIds,
        tagIds: tagIds,
      ),
    );
    return _parseList(data, DateIncludePoint.fromJson);
  }

  Future<List<BillTypeDistributionItem>> getBillTypeDistribution({
    required int bookId,
    DateTime? start,
    DateTime? end,
  }) async {
    final data = await _api.get(
      '/fortune/include/getBillTypeDistribution',
      query: _includeQuery(bookId: bookId, start: start, end: end),
    );
    return _parseList(data, BillTypeDistributionItem.fromJson);
  }

  // ── Dashboard / 资产 / 借贷理财 / 导出策略 ───────────────────

  Future<List<CalendarHeatmapPoint>> getCalendarHeatmap({
    required int bookId,
    int? year,
  }) async {
    final data = await _api.get(
      '/fortune/include/getCalendarHeatmap',
      query: {'bookId': bookId, if (year != null) 'year': year},
    );
    return _parseList(data, CalendarHeatmapPoint.fromJson);
  }

  Future<IncomeExpenseCalendarResponse> getIncomeExpenseCalendar({
    required IncomeExpenseCalendarRequest request,
  }) async {
    final data = await _api.get(
      '/fortune/include/getIncomeExpenseCalendar',
      query: request.toQueryParameters(),
    );
    if (data is Map) {
      return IncomeExpenseCalendarResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
    return IncomeExpenseCalendarResponse(granularity: request.granularity);
  }

  Future<List<NetAssetsTrendPoint>> getNetAssetsTrend({
    required int groupId,
    int periodType = 3,
  }) async {
    final data = await _api.get(
      '/fortune/include/$groupId/netAssetsTrend',
      query: {'periodType': periodType},
    );
    return _parseList(data, NetAssetsTrendPoint.fromJson);
  }

  Future<List<PieSlice>> getTotalAssets({required int groupId}) async {
    final data = await _api.get('/fortune/include/$groupId/getTotalAssets');
    return _parseList(data, PieSlice.fromJson)
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  Future<List<PieSlice>> getTotalLiabilities({required int groupId}) async {
    final data = await _api.get(
      '/fortune/include/$groupId/getTotalLiabilities',
    );
    return _parseList(data, PieSlice.fromJson)
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  Future<List<AssetsByAccountType>> getAssetsByAccountType({
    required int groupId,
  }) async {
    final data = await _api.get(
      '/fortune/include/$groupId/getAssetsByAccountType',
    );
    return _parseList(data, AssetsByAccountType.fromJson);
  }

  Future<List<CreditCardOverview>> getCreditCardOverview({
    required int groupId,
  }) async {
    final data = await _api.get(
      '/fortune/include/$groupId/getCreditCardOverview',
    );
    return _parseList(data, CreditCardOverview.fromJson);
  }

  Future<List<AccountBalanceTrendPoint>> getAccountBalanceTrend({
    required int accountId,
    DateTime? start,
    DateTime? end,
  }) async {
    final data = await _api.get(
      '/fortune/include/getAccountBalanceTrend',
      query: {
        'accountId': accountId,
        if (start != null) 'startDate': _day.format(start),
        if (end != null) 'endDate': _day.format(end),
      },
    );
    return _parseList(data, AccountBalanceTrendPoint.fromJson);
  }

  Future<LoanOverview> getLoanOverview({required int bookId}) async {
    final data = await _api.get('/fortune/include/$bookId/getLoanOverview');
    if (data is Map) {
      return LoanOverview.fromJson(Map<String, dynamic>.from(data));
    }
    return const LoanOverview();
  }

  Future<FinanceProfit> getFinanceProfit({required int bookId}) async {
    final data = await _api.get('/fortune/include/$bookId/getFinanceProfit');
    if (data is Map) {
      return FinanceProfit.fromJson(Map<String, dynamic>.from(data));
    }
    return const FinanceProfit();
  }

  Future<StatisticsPolicy> getStatisticsPolicy({required int bookId}) async {
    final data = await _api.get('/fortune/include/getIncludePolicy');
    if (data is Map) {
      return StatisticsPolicy.fromJson(Map<String, dynamic>.from(data));
    }
    return const StatisticsPolicy();
  }

  Future<void> exportStatisticsReport({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int? billType,
  }) async {
    // TODO(statistics): return Excel bytes here when the export UI is wired.
    await _api.get(
      '/fortune/include/exportReport',
      query: _includeQuery(
        bookId: bookId,
        start: start,
        end: end,
        billType: billType,
      ),
    );
  }

  Future<DimensionStat<T>> _dimensionEnvelope<T>(
    String path,
    int bookId,
    DateTime start,
    DateTime end,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final data = await _api.get(
      '/fortune/include/$path',
      query: _rangeQuery(bookId, start, end),
    );
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      final items = _parseList(
        json['items'],
        fromJson,
      )..sort((a, b) => _valueOf(b as Object).compareTo(_valueOf(a as Object)));
      return DimensionStat<T>(
        total: FxApi.asDouble(json['total']) ?? 0,
        items: items,
      );
    }
    return DimensionStat<T>(items: _parseList(data, fromJson));
  }

  static double _valueOf(Object value) {
    if (value is PieSlice) return value.value;
    if (value is BarItem) return value.value;
    return 0;
  }

  static Map<String, dynamic> _rangeQuery(
    int bookId,
    DateTime start,
    DateTime end,
  ) => {
    'bookId': bookId,
    'startDate': _day.format(start),
    'endDate': _day.format(end),
  };

  static Map<String, dynamic> _includeQuery({
    required int bookId,
    DateTime? start,
    DateTime? end,
    int? billType,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
    int? memberId,
  }) => {
    'bookId': bookId,
    if (start != null) 'startDate': _day.format(start),
    if (end != null) 'endDate': _day.format(end),
    if (billType != null) 'billType': billType,
    if (categoryIds != null && categoryIds.isNotEmpty)
      'categoryIds': categoryIds,
    if (tagIds != null && tagIds.isNotEmpty) 'tagIds': tagIds,
    if (payeeIds != null && payeeIds.isNotEmpty) 'payeeIds': payeeIds,
    if (accountId != null) 'accountId': accountId,
    if (memberId != null) 'memberId': memberId,
  };

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
