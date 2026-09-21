part of 'orders_bloc.dart';

enum OrdersStatus { initial, loading, loaded, error, empty }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<FortuneFinanceOrderVo> orders;
  final String? errorMessage;
  final String? toastMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.toastMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<FortuneFinanceOrderVo>? orders,
    String? errorMessage,
    String? toastMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage, toastMessage];
}
