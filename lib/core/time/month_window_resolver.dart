import 'package:equatable/equatable.dart';

/// Inclusive billing-month window resolved from a user configured start day.
class MonthWindow extends Equatable {
  final DateTime anchorMonth;
  final DateTime start;
  final DateTime end;

  const MonthWindow({
    required this.anchorMonth,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [anchorMonth, start, end];
}

/// Resolves billing windows such as "every month starts on the 5th".
class MonthWindowResolver {
  const MonthWindowResolver._();

  static MonthWindow resolveCurrent(DateTime now, int startDay) {
    final date = _dateOnly(now);
    final currentStart = _monthStart(now.year, now.month, startDay);
    final anchor = date.isBefore(currentStart)
        ? DateTime(now.year, now.month - 1)
        : DateTime(now.year, now.month);
    return resolveForAnchor(anchor, startDay);
  }

  static MonthWindow resolveForAnchor(DateTime anchorMonth, int startDay) {
    final anchor = DateTime(anchorMonth.year, anchorMonth.month);
    final start = _monthStart(anchor.year, anchor.month, startDay);
    final nextStart = _monthStart(anchor.year, anchor.month + 1, startDay);
    return MonthWindow(
      anchorMonth: anchor,
      start: start,
      end: nextStart.subtract(const Duration(days: 1)),
    );
  }

  static DateTime shift(DateTime anchorMonth, int delta) {
    return DateTime(anchorMonth.year, anchorMonth.month + delta);
  }

  static int daysInMonth(int year, int month) {
    final normalized = DateTime(year, month);
    return DateTime(normalized.year, normalized.month + 1, 0).day;
  }

  static int clampDay(int year, int month, int preferredDay) {
    final maxDay = daysInMonth(year, month);
    if (preferredDay < 1) return 1;
    if (preferredDay > maxDay) return maxDay;
    return preferredDay;
  }

  static DateTime _monthStart(int year, int month, int startDay) {
    final normalized = DateTime(year, month);
    final day = clampDay(normalized.year, normalized.month, startDay);
    return DateTime(normalized.year, normalized.month, day);
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
