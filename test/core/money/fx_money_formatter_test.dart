import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';

void main() {
  group('FxMoneyFormatter', () {
    test('formats money using the supplied locale', () {
      expect(FxMoneyFormatter.format(1234.5, locale: 'en_US'), '1,234.50');
      expect(FxMoneyFormatter.format(1234.5, locale: 'zh_CN'), '1,234.50');
    });

    test('masks every value without preserving sign or currency', () {
      const visibility = FxAmountVisibility.hidden;

      expect(
        FxMoneyFormatter.format(
          -1234.5,
          currencySymbol: r'$',
          showSign: true,
          visibility: visibility,
        ),
        FxMoneyFormatter.hiddenPlaceholder,
      );
      expect(
        FxMoneyFormatter.formatCompact(1234567, visibility: visibility),
        FxMoneyFormatter.hiddenPlaceholder,
      );
      expect(
        FxMoneyFormatter.formatPercent(42, visibility: visibility),
        FxMoneyFormatter.hiddenPlaceholder,
      );
    });
  });
}
