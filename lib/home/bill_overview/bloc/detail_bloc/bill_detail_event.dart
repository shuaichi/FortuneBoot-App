part of 'bill_detail_bloc.dart';

sealed class BillDetailEvent extends Equatable {
  const BillDetailEvent();

  @override
  List<Object> get props => [];
}

final class BillLoadFile extends BillDetailEvent {
  int billId;
  BillLoadFile(this.billId);
  @override
  List<Object> get props => [billId];
}
