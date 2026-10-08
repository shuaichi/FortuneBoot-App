import 'package:equatable/equatable.dart';

/// User-facing billing preferences stored locally.
class BillingPreferences extends Equatable {
  static const int defaultMonthStartDay = 1;
  static const int minMonthStartDay = 1;
  static const int maxMonthStartDay = 31;
  static const bool defaultCopyUsesCurrentTime = true;

  final int monthStartDay;
  final bool copyUsesCurrentTime;

  const BillingPreferences({
    this.monthStartDay = defaultMonthStartDay,
    this.copyUsesCurrentTime = defaultCopyUsesCurrentTime,
  });

  factory BillingPreferences.defaults() => const BillingPreferences();

  BillingPreferences copyWith({
    int? monthStartDay,
    bool? copyUsesCurrentTime,
  }) {
    return BillingPreferences(
      monthStartDay: normalizeMonthStartDay(
        monthStartDay ?? this.monthStartDay,
      ),
      copyUsesCurrentTime: copyUsesCurrentTime ?? this.copyUsesCurrentTime,
    );
  }

  static int normalizeMonthStartDay(int value) {
    if (value < minMonthStartDay) return minMonthStartDay;
    if (value > maxMonthStartDay) return maxMonthStartDay;
    return value;
  }

  @override
  List<Object?> get props => [monthStartDay, copyUsesCurrentTime];
}
