import 'package:flutter/widgets.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/util/currency_symbol.dart';

class StatsFormatters {
  const StatsFormatters._({
    required this.locale,
    required this.visibility,
    required this.masked,
    required this.currencyCode,
  });

  final String locale;
  final FxAmountVisibility visibility;
  final bool masked;
  final String? currencyCode;

  factory StatsFormatters.of(BuildContext context, {String? currencyCode}) {
    final hideAmounts = StatsPrivacy.hideAmountsOf(context);
    return StatsFormatters._(
      locale: Localizations.localeOf(context).toString(),
      visibility: hideAmounts
          ? FxAmountVisibility.hidden
          : FxAmountVisibility.visible,
      masked: hideAmounts,
      currencyCode: currencyCode,
    );
  }

  String money(num value, {bool showSign = false, int decimalDigits = 2}) {
    return FxMoneyFormatter.format(
      value,
      locale: locale,
      currencySymbol: _currencySymbol,
      showSign: showSign,
      decimalDigits: decimalDigits,
      visibility: visibility,
    );
  }

  String compact(num value) => FxMoneyFormatter.formatCompact(
    value,
    locale: locale,
    visibility: visibility,
  );

  String percent(num value, {int decimalDigits = 0}) {
    return FxMoneyFormatter.formatPercent(
      value,
      locale: locale,
      decimalDigits: decimalDigits,
      visibility: visibility,
    );
  }

  String chartValue(double value) => money(value);

  String get _currencySymbol {
    final code = currencyCode;
    if (code == null || code.isEmpty) return '';
    return getCurrencySymbol(code);
  }
}
