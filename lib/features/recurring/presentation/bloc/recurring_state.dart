part of 'recurring_bloc.dart';

enum RecurringStatus { initial, loading, loaded, error, empty }

class RecurringState extends Equatable {
  final RecurringStatus status;
  final List<RecurringRuleVo> rules;
  final String? errorMessage;
  final String? toastMessage;

  const RecurringState({
    this.status = RecurringStatus.initial,
    this.rules = const [],
    this.errorMessage,
    this.toastMessage,
  });

  RecurringState copyWith({
    RecurringStatus? status,
    List<RecurringRuleVo>? rules,
    String? errorMessage,
    String? toastMessage,
  }) {
    return RecurringState(
      status: status ?? this.status,
      rules: rules ?? this.rules,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [status, rules, errorMessage, toastMessage];
}
