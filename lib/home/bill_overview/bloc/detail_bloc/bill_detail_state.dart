part of 'bill_detail_bloc.dart';

enum BillDetailStatus {
  initial,
  loading,
  success,
  failure,
  closed,
  submitFailed
}

extension BillDetailStatusX on BillDetailStatus {
  bool get isLoadingOrInit => [
        BillDetailStatus.loading,
        BillDetailStatus.initial,
      ].contains(this);
}

final class BillDetailState extends Equatable {
  BillDetailState({
    required this.initialBill,
  });

  final BillItem initialBill;

  BillDetailState copyWith({
    BillItem? initialBill,
  }) {
    return BillDetailState(
      initialBill: initialBill ?? this.initialBill,
    );
  }

  @override
  List<Object?> get props => [
        initialBill,
      ];
}
