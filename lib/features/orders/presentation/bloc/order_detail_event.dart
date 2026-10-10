part of 'order_detail_bloc.dart';

sealed class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class OrderDetailLoaded extends OrderDetailEvent {
  const OrderDetailLoaded();
}

class OrderDetailRefreshed extends OrderDetailEvent {
  const OrderDetailRefreshed();
}

class OrderDetailEntryStatusChanged extends OrderDetailEvent {
  final String entryStatus;
  const OrderDetailEntryStatusChanged(this.entryStatus);

  @override
  List<Object?> get props => [entryStatus];
}

class OrderDetailLoadMoreRequested extends OrderDetailEvent {
  const OrderDetailLoadMoreRequested();
}

class OrderDetailEntryActionRequested extends OrderDetailEvent {
  final FinanceOrderEntry entry;
  final FinanceOrderEntryAction action;

  const OrderDetailEntryActionRequested({
    required this.entry,
    required this.action,
  });

  @override
  List<Object?> get props => [entry.billId, action];
}

class OrderDetailTransitionRequested extends OrderDetailEvent {
  final String action;
  const OrderDetailTransitionRequested(this.action);

  @override
  List<Object?> get props => [action];
}
