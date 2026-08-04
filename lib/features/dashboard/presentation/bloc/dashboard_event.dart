part of 'dashboard_bloc.dart';

/// DashboardBloc 事件。
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// 账本变更（来自 SessionCubit currentBookId）→ 重新并发拉取全部。
final class DashboardBookChanged extends DashboardEvent {
  final int? bookId;
  final int? groupId;
  const DashboardBookChanged({this.bookId, this.groupId});

  @override
  List<Object?> get props => [bookId, groupId];
}

/// 首屏 / 下拉刷新：并发拉取全部卡片数据。
final class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

/// 账单月开始日变更。
final class DashboardMonthStartDayChanged extends DashboardEvent {
  final int day;
  const DashboardMonthStartDayChanged(this.day);

  @override
  List<Object?> get props => [day];
}
