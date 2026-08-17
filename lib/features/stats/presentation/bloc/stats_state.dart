part of 'stats_bloc.dart';

/// 时间区间。
enum StatsRange { week, month, year, custom }

/// 统计类型（支出/收入）。
enum StatsType { expense, income }

/// 收支日历的自然时间视图。
enum IncomeExpenseCalendarView { month, year, history }

/// 单张图表卡的加载态：各卡独立 loading/data/error，互不拖累。
enum StatsSectionStatus { loading, ready, error }

/// 泛型区块容器，[data] 在 ready 时非空。
class StatsSection<T> extends Equatable {
  final StatsSectionStatus status;
  final T? data;
  final String? error;

  const StatsSection({
    this.status = StatsSectionStatus.loading,
    this.data,
    this.error,
  });

  const StatsSection.loading() : this(status: StatsSectionStatus.loading);
  const StatsSection.ready(T value)
    : this(status: StatsSectionStatus.ready, data: value);
  const StatsSection.error(String message)
    : this(status: StatsSectionStatus.error, error: message);

  bool get isReady => status == StatsSectionStatus.ready;

  @override
  List<Object?> get props => [status, data, error];
}

/// 统计页聚合状态：区间 + 类型 + 各图表数据 + 概览。
class StatsState extends Equatable {
  /// 无账本（currentBookId==null）→ 整页空态。
  final bool hasBook;
  final StatsRange range;
  final StatsType type;

  /// 自定义区间起止（range==custom 时生效）。
  final DateTime? customStart;
  final DateTime? customEnd;

  final StatsSection<BillStatistics> overview;
  final StatsSection<List<TrendPoint>> trends;
  final StatsSection<List<PieSlice>> categories;
  final StatsSection<List<BarItem>> tags;
  final StatsSection<List<PieSlice>> payees;
  final IncomeExpenseCalendarView calendarView;
  final DateTime calendarAnchor;
  final StatsSection<IncomeExpenseCalendarResponse> calendar;
  final String? currencyCode;

  StatsState({
    this.hasBook = false,
    this.range = StatsRange.month,
    this.type = StatsType.expense,
    this.customStart,
    this.customEnd,
    this.overview = const StatsSection.loading(),
    this.trends = const StatsSection.loading(),
    this.categories = const StatsSection.loading(),
    this.tags = const StatsSection.loading(),
    this.payees = const StatsSection.loading(),
    this.calendarView = IncomeExpenseCalendarView.month,
    DateTime? calendarAnchor,
    this.calendar = const StatsSection.loading(),
    this.currencyCode,
  }) : calendarAnchor =
           calendarAnchor ??
           DateTime(DateTime.now().year, DateTime.now().month);

  StatsState copyWith({
    bool? hasBook,
    StatsRange? range,
    StatsType? type,
    DateTime? customStart,
    DateTime? customEnd,
    StatsSection<BillStatistics>? overview,
    StatsSection<List<TrendPoint>>? trends,
    StatsSection<List<PieSlice>>? categories,
    StatsSection<List<BarItem>>? tags,
    StatsSection<List<PieSlice>>? payees,
    IncomeExpenseCalendarView? calendarView,
    DateTime? calendarAnchor,
    StatsSection<IncomeExpenseCalendarResponse>? calendar,
    String? currencyCode,
  }) {
    return StatsState(
      hasBook: hasBook ?? this.hasBook,
      range: range ?? this.range,
      type: type ?? this.type,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      overview: overview ?? this.overview,
      trends: trends ?? this.trends,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      payees: payees ?? this.payees,
      calendarView: calendarView ?? this.calendarView,
      calendarAnchor: calendarAnchor ?? this.calendarAnchor,
      calendar: calendar ?? this.calendar,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    hasBook,
    range,
    type,
    customStart,
    customEnd,
    overview,
    trends,
    categories,
    tags,
    payees,
    calendarView,
    calendarAnchor,
    calendar,
    currencyCode,
  ];
}
