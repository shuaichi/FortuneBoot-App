part of 'bills_overview_bloc.dart';

sealed class BillsOverviewEvent extends Equatable {
  const BillsOverviewEvent();

  @override
  List<Object> get props => [];
}

final class BillsOverviewSubscriptionRequested extends BillsOverviewEvent {
  const BillsOverviewSubscriptionRequested();
}

final class BillsOverviewUndoDeletionRequested extends BillsOverviewEvent {
  const BillsOverviewUndoDeletionRequested();
}

// 删除
final class BillsOverviewDeleteRequested extends BillsOverviewEvent {
  final int billId;
  const BillsOverviewDeleteRequested(this.billId);
}

/// 上拉加载更多事件
class BillsOverviewLoadMoreRequested extends BillsOverviewEvent {
  const BillsOverviewLoadMoreRequested();
}

/// 上拉加载更多事件
class BillsOverviewLoadLastRequested extends BillsOverviewEvent {
  const BillsOverviewLoadLastRequested();
}

class BillsOverviewRefreshStatisticsRequested extends BillsOverviewEvent {
  DateTime refreshDate;
  BillsOverviewRefreshStatisticsRequested(this.refreshDate);
  @override
  List<Object> get props => [refreshDate];
}

class BillsOverviewRefreshStatisticsDayChanged extends BillsOverviewEvent {
  int day;
  BillsOverviewRefreshStatisticsDayChanged(this.day);
  @override
  List<Object> get props => [day];
}

class BillsOverviewFilterChanged extends BillsOverviewEvent {
  final FortuneBillQuery? query;

  const BillsOverviewFilterChanged(this.query);

  @override
  // 修复报错：将 List<Object?> 改为 List<Object>
  List<Object> get props => query != null ? [query!] :[];
}