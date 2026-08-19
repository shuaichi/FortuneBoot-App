import 'package:intl/intl.dart';

/// Controls whether financial values may be rendered to a user.
enum FxAmountVisibility { visible, hidden }

/// Locale-aware formatting for user-visible financial values.
abstract final class FxMoneyFormatter {
  static const hiddenPlaceholder = '••••';

  static String format(
    num value, {
    String? locale,
    String? currencySymbol,
    int decimalDigits = 2,
    bool showSign = false,
    FxAmountVisibility visibility = FxAmountVisibility.visible,
  }) {
    if (visibility == FxAmountVisibility.hidden) return hiddenPlaceholder;
    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(value.abs());
    final sign = showSign && value > 0
        ? '+'
        : value < 0
        ? '-'
        : '';
    return '$sign${currencySymbol ?? ''}$number';
  }

  static String formatCompact(
    num value, {
    String? locale,
    FxAmountVisibility visibility = FxAmountVisibility.visible,
  }) {
    if (visibility == FxAmountVisibility.hidden) return hiddenPlaceholder;
    return NumberFormat.compact(locale: locale).format(value);
  }

  static String formatPercent(
    num value, {
    String? locale,
    int decimalDigits = 0,
    FxAmountVisibility visibility = FxAmountVisibility.visible,
  }) {
    if (visibility == FxAmountVisibility.hidden) return hiddenPlaceholder;
    return NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(value / 100);
  }

  static String formatDate(DateTime value, {String? locale}) =>
      DateFormat.yMMMd(locale).format(value);
}
