part of 'dashboard_bloc.dart';

/// 单个卡片区块的加载态：每张卡独立 loading/data/error,互不拖累。
enum SectionStatus { loading, ready, error }

/// 泛型区块容器。[data] 在 ready 时非空。
class DashboardSection<T> extends Equatable {
  final SectionStatus status;
  final T? data;
  final String? error;

  const DashboardSection({
    this.status = SectionStatus.loading,
    this.data,
    this.error,
  });

  const DashboardSection.loading() : this(status: SectionStatus.loading);
  const DashboardSection.ready(T value)
    : this(status: SectionStatus.ready, data: value);
  const DashboardSection.error(String message)
    : this(status: SectionStatus.error, error: message);

  bool get isReady => status == SectionStatus.ready;

  @override
  List<Object?> get props => [status, data, error];
}

/// 看板聚合状态：各部分独立持有加载态,任一失败仅该卡兜底。
class DashboardState extends Equatable {
  /// 当前无账本(currentBookId==null)→整页空态。
  final bool hasBook;
  final DashboardSection<AssetsLiabilities> assets;
  final DashboardSection<BillStatistics> monthStats;
  final DashboardSection<List<TrendPoint>> expenseTrends;
  final DashboardSection<List<TrendPoint>> incomeTrends;
  final DashboardSection<List<CategorySlice>> categories;
  final DashboardSection<List<FortuneBillVo>> recentBills;
  final String? currencyCode;

  const DashboardState({
    this.hasBook = false,
    this.assets = const DashboardSection.loading(),
    this.monthStats = const DashboardSection.loading(),
    this.expenseTrends = const DashboardSection.loading(),
    this.incomeTrends = const DashboardSection.loading(),
    this.categories = const DashboardSection.loading(),
    this.recentBills = const DashboardSection.loading(),
    this.currencyCode,
  });

  /// 是否为新用户空态：账单为空(且已加载完)。
  bool get isEmptyUser =>
      recentBills.isReady && (recentBills.data?.isEmpty ?? true);

  DashboardState copyWith({
    bool? hasBook,
    DashboardSection<AssetsLiabilities>? assets,
    DashboardSection<BillStatistics>? monthStats,
    DashboardSection<List<TrendPoint>>? expenseTrends,
    DashboardSection<List<TrendPoint>>? incomeTrends,
    DashboardSection<List<CategorySlice>>? categories,
    DashboardSection<List<FortuneBillVo>>? recentBills,
    String? currencyCode,
  }) {
    return DashboardState(
      hasBook: hasBook ?? this.hasBook,
      assets: assets ?? this.assets,
      monthStats: monthStats ?? this.monthStats,
      expenseTrends: expenseTrends ?? this.expenseTrends,
      incomeTrends: incomeTrends ?? this.incomeTrends,
      categories: categories ?? this.categories,
      recentBills: recentBills ?? this.recentBills,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    hasBook,
    assets,
    monthStats,
    expenseTrends,
    incomeTrends,
    categories,
    recentBills,
    currencyCode,
  ];
}
