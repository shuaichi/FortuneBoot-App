part of 'payees_bloc.dart';

sealed class PayeesEvent extends Equatable {
  const PayeesEvent();

  @override
  List<Object?> get props => [];
}

class PayeesLoaded extends PayeesEvent {
  const PayeesLoaded();
}

class PayeesBookChanged extends PayeesEvent {
  final int? bookId;
  const PayeesBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class PayeesTabChanged extends PayeesEvent {
  final ManageTab tab;
  const PayeesTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class PayeesSearchChanged extends PayeesEvent {
  final String keyword;
  const PayeesSearchChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class PayeesMutated extends PayeesEvent {
  const PayeesMutated();
}

class PayeeToggleChanged extends PayeesEvent {
  final FortunePayeeVo payee;
  final PayeeToggleField field;
  final bool value;
  const PayeeToggleChanged({
    required this.payee,
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [payee.payeeId, field, value];
}
