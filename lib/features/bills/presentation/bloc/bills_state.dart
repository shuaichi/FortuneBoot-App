part of 'bills_bloc.dart';

enum BillsStatus { initial, loading, loaded, error }

/// 按交易日分组的账单块。
class BillDayGroup extends Equatable {
  final DateTime day;
  final List<FortuneBillVo> bills;
  const BillDayGroup({required this.day, required this.bills});

  @override
  List<Object?> get props => [day, bills];
}

/// 按账期分组的账单块。
class BillMonthGroup extends Equatable {
  final MonthWindow window;
  final List<BillDayGroup> dayGroups;
  final BillStatistics? statistics;

  const BillMonthGroup({
    required this.window,
    required this.dayGroups,
    this.statistics,
  });

  @override
  List<Object?> get props => [window, dayGroups, statistics];
}

/// 单一状态类：状态机由 [status] + 数据字段承载。
class BillsState extends Equatable {
  final BillsStatus status;

  /// 当前展示账期的锚点月份（取其年月，日=1）。
  final DateTime month;
  final BillsFilter filter;

  /// 扁平账单列表（分页累积，交易时间降序）。
  final List<FortuneBillVo> bills;
  final int total;
  final bool hasMore;

  /// 是否正在追加下一页（上拉分页 loading，不覆盖列表）。
  final bool isLoadingMore;

  /// 是否正在下拉刷新（保留旧列表）。
  final bool isRefreshing;

  final BillStatistics? statistics;
  final Map<DateTime, BillStatistics> monthStatistics;
  final String? errorMessage;

  const BillsState({
    this.status = BillsStatus.initial,
    required this.month,
    this.filter = BillsFilter.empty,
    this.bills = const [],
    this.total = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.statistics,
    this.monthStatistics = const {},
    this.errorMessage,
  });

  factory BillsState.initial(DateTime month) =>
      BillsState(month: DateTime(month.year, month.month));

  bool get isEmpty => status == BillsStatus.loaded && bills.isEmpty;

  /// 交易日分组（降序），供 sticky header 渲染。
  List<BillDayGroup> get dayGroups {
    final map = <DateTime, List<FortuneBillVo>>{};
    for (final b in bills) {
      final t = b.tradeTime;
      final day = t == null
          ? DateTime(month.year, month.month)
          : DateTime(t.year, t.month, t.day);
      map.putIfAbsent(day, () => []).add(b);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return days
        .map((d) => BillDayGroup(day: d, bills: map[d]!))
        .toList(growable: false);
  }

  List<BillMonthGroup> monthGroups(int monthStartDay) {
    final map = <DateTime, List<FortuneBillVo>>{};
    for (final bill in bills) {
      final tradeTime = bill.tradeTime;
      final window = MonthWindowResolver.resolveCurrent(
        tradeTime ?? DateTime(month.year, month.month),
        monthStartDay,
      );
      map.putIfAbsent(window.anchorMonth, () => []).add(bill);
    }
    final anchors = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final anchor in anchors)
        BillMonthGroup(
          window: MonthWindowResolver.resolveForAnchor(anchor, monthStartDay),
          dayGroups: _dayGroupsFor(map[anchor]!, anchor),
          statistics: monthStatistics[anchor],
        ),
    ];
  }

  List<BillDayGroup> _dayGroupsFor(
    List<FortuneBillVo> source,
    DateTime anchor,
  ) {
    final map = <DateTime, List<FortuneBillVo>>{};
    for (final b in source) {
      final t = b.tradeTime;
      final day = t == null
          ? DateTime(anchor.year, anchor.month)
          : DateTime(t.year, t.month, t.day);
      map.putIfAbsent(day, () => []).add(b);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return days
        .map((d) => BillDayGroup(day: d, bills: map[d]!))
        .toList(growable: false);
  }

  BillsState copyWith({
    BillsStatus? status,
    DateTime? month,
    BillsFilter? filter,
    List<FortuneBillVo>? bills,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    BillStatistics? statistics,
    Map<DateTime, BillStatistics>? monthStatistics,
    bool clearStatistics = false,
    String? errorMessage,
  }) {
    return BillsState(
      status: status ?? this.status,
      month: month ?? this.month,
      filter: filter ?? this.filter,
      bills: bills ?? this.bills,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      statistics: clearStatistics ? null : (statistics ?? this.statistics),
      monthStatistics: monthStatistics ?? this.monthStatistics,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    month,
    filter,
    bills,
    total,
    hasMore,
    isLoadingMore,
    isRefreshing,
    statistics,
    monthStatistics,
    errorMessage,
  ];
}
