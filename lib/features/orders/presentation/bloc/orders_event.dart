part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrdersEvent {
  const OrdersLoaded();
}

class OrdersRefreshed extends OrdersEvent {
  const OrdersRefreshed();
}

class OrdersMutated extends OrdersEvent {
  const OrdersMutated();
}

class OrdersBookChanged extends OrdersEvent {
  final int? bookId;
  const OrdersBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class OrdersTypeChanged extends OrdersEvent {
  final FinanceOrderType type;
  const OrdersTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class OrdersStatusFilterChanged extends OrdersEvent {
  final int status;
  const OrdersStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class OrdersSearchChanged extends OrdersEvent {
  final String? keyword;
  const OrdersSearchChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class OrdersOverdueOnlyChanged extends OrdersEvent {
  final bool overdueOnly;
  const OrdersOverdueOnlyChanged(this.overdueOnly);

  @override
  List<Object?> get props => [overdueOnly];
}

class OrdersLoadMoreRequested extends OrdersEvent {
  const OrdersLoadMoreRequested();
}
