part of 'bills_overview_bloc.dart';

enum BillsOverviewStatus { initial, loading, success, failure }

final class BillsOverviewState extends Equatable {
  const BillsOverviewState({
    this.status = BillsOverviewStatus.initial,
    this.lastDeletedBill,
    this.bills = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.statistics,
    this.query,
  });

  final BillsOverviewStatus status;
  final BillItem? lastDeletedBill;
  final List<BillItem>? bills;
  final BillStatistics? statistics;
  final FortuneBillQuery? query; // 查询参数状态

  // 分页相关
  final bool hasMore; // 是否还有更多数据
  final bool isLoadingMore; // 是否正在加载更多

  BillsOverviewState copyWith({
    BillsOverviewStatus Function()? status,
    List<BillItem>? bills,
    BillItem? Function()? lastDeletedBill,
    bool? hasMore,
    bool? isLoadingMore,
    BillStatistics? statistics,
    FortuneBillQuery? Function()? query,
  }) {
    return BillsOverviewState(
      status: status != null ? status() : this.status,
      bills: bills ?? this.bills,
      lastDeletedBill:
          lastDeletedBill != null ? lastDeletedBill() : this.lastDeletedBill,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statistics: statistics ?? this.statistics,
      query: query != null ? query() : this.query,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bills,
        lastDeletedBill,
        bills,
        hasMore,
        isLoadingMore,
        statistics,
        query,
      ];
}
