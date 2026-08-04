part of 'bills_bloc.dart';

/// BillsBloc 事件。
sealed class BillsEvent extends Equatable {
  const BillsEvent();

  @override
  List<Object?> get props => [];
}

/// 账本变更（来自 SessionCubit）→ 重置并首屏加载。
final class BillsBookChanged extends BillsEvent {
  final int? bookId;
  const BillsBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// 首屏 / 重新加载当前月第一页。
final class BillsRefreshed extends BillsEvent {
  const BillsRefreshed();
}

/// 上拉加载下一页。
final class BillsNextPageRequested extends BillsEvent {
  const BillsNextPageRequested();
}

/// 切换到上一月 / 下一月（delta = -1 / +1）。
final class BillsMonthChanged extends BillsEvent {
  final int delta;
  const BillsMonthChanged(this.delta);

  @override
  List<Object?> get props => [delta];
}

/// 应用筛选条件。
final class BillsFilterApplied extends BillsEvent {
  final BillsFilter filter;
  const BillsFilterApplied(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// 删除一条账单。
final class BillsBillDeleted extends BillsEvent {
  final int billId;
  const BillsBillDeleted(this.billId);

  @override
  List<Object?> get props => [billId];
}

/// 切换确认状态（confirm=true 确认，false 取消确认）。
final class BillsConfirmToggled extends BillsEvent {
  final int billId;
  final bool confirm;
  const BillsConfirmToggled(this.billId, {required this.confirm});

  @override
  List<Object?> get props => [billId, confirm];
}

/// 切换统计（include=true 计入统计，false 不计入）。
final class BillsIncludeToggled extends BillsEvent {
  final int billId;
  final bool include;
  const BillsIncludeToggled(this.billId, {required this.include});

  @override
  List<Object?> get props => [billId, include];
}
