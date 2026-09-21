part of 'orders_bloc.dart';

/// 单据 feature 事件。
sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrdersEvent {
  const OrdersLoaded();
}

class OrdersBookChanged extends OrdersEvent {
  final int? bookId;
  const OrdersBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class OrdersMutated extends OrdersEvent {
  const OrdersMutated();
}

/// 状态机流转：action = using / close / reopen。
class OrderTransitioned extends OrdersEvent {
  final FortuneFinanceOrderVo order;
  final String action;

  const OrderTransitioned({required this.order, required this.action});

  @override
  List<Object?> get props => [order.orderId, action];
}
