part of 'recurring_bloc.dart';

enum RecurringStatus { initial, loading, loaded, error, empty }

class RecurringState extends Equatable {
  final RecurringStatus status;
  final List<RecurringRuleVo> rules;
  final String? errorMessage;
  final String? toastMessage;
  final int toastSerial;
  final Set<int> pendingToggleIds;

  const RecurringState({
    this.status = RecurringStatus.initial,
    this.rules = const [],
    this.errorMessage,
    this.toastMessage,
    this.toastSerial = 0,
    this.pendingToggleIds = const {},
  });

  RecurringState copyWith({
    RecurringStatus? status,
    List<RecurringRuleVo>? rules,
    String? errorMessage,
    String? toastMessage,
    int? toastSerial,
    Set<int>? pendingToggleIds,
  }) {
    return RecurringState(
      status: status ?? this.status,
      rules: rules ?? this.rules,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
      toastSerial: toastSerial ?? this.toastSerial,
      pendingToggleIds: pendingToggleIds ?? this.pendingToggleIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rules,
    errorMessage,
    toastMessage,
    toastSerial,
    pendingToggleIds,
  ];
}
