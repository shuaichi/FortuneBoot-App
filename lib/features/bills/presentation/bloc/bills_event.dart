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

/// 重试最近一次追加分页，不重置已加载记录。
final class BillsPaginationRetried extends BillsEvent {
  const BillsPaginationRetried();
}

/// 应用跨页面传入的账本与日期范围。
final class BillsEntryApplied extends BillsEvent {
  const BillsEntryApplied(this.request);

  final BillsEntryRequest request;

  @override
  List<Object?> get props => [request];
}

/// 切换到上一账期 / 下一账期（delta = -1 / +1）。
final class BillsMonthChanged extends BillsEvent {
  final int delta;
  const BillsMonthChanged(this.delta);

  @override
  List<Object?> get props => [delta];
}

/// 账单月开始日变更。
final class BillsMonthStartDayChanged extends BillsEvent {
  final int day;
  const BillsMonthStartDayChanged(this.day);

  @override
  List<Object?> get props => [day];
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
  const BillsBillDeleted({required this.bookId, required this.billId});

  final int bookId;
  final int billId;

  @override
  List<Object?> get props => [bookId, billId];
}

/// 切换确认状态（confirm=true 确认，false 取消确认）。
final class BillsConfirmToggled extends BillsEvent {
  const BillsConfirmToggled({
    required this.bookId,
    required this.billId,
    required this.confirm,
  });

  final int bookId;
  final int billId;
  final bool confirm;

  @override
  List<Object?> get props => [bookId, billId, confirm];
}

/// 切换统计（include=true 计入统计，false 不计入）。
final class BillsIncludeToggled extends BillsEvent {
  const BillsIncludeToggled({
    required this.bookId,
    required this.billId,
    required this.include,
  });

  final int bookId;
  final int billId;
  final bool include;

  @override
  List<Object?> get props => [bookId, billId, include];
}
