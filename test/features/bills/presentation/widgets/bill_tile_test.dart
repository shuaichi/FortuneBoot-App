import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/finance_color_preferences.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bill_tile.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('account and category metadata uses the readable text role', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(
          body: BillTile(
            bill: FortuneBillVo(
              title: '午餐',
              amount: 28,
              currencyCode: 'CNY',
              billType: 1,
              accountName: '日常银行卡',
              categoryAmountPair: [
                BillCategoryAmount(categoryName: '餐饮', amount: 28),
              ],
            ),
          ),
        ),
      ),
    );

    final metadata = tester.widget<Text>(find.text('餐饮 · 日常银行卡'));
    expect(metadata.style?.color, FxPalette.light.textSecondary);
    expect(find.text('-¥28.00'), findsOneWidget);
    expect(find.text('+¥28.00'), findsNothing);
    final amount = tester.widget<FxMoneyText>(find.byType(FxMoneyText));
    expect(amount.amount, -28);
  });

  testWidgets(
    'incoming and outgoing document flows use their financial colors',
    (tester) async {
      expect(
        FxFinanceColors.light.forBillType(FxBillType.reimburse.value),
        FxFinanceColors.light.income,
      );
      expect(
        FxFinanceColors.light.forBillType(FxBillType.loanRepay.value),
        FxFinanceColors.light.expense,
      );
      expect(FxFinanceColors.light.reimburse, FxFinanceColors.light.income);
      for (final preset in FinanceColorPreset.values) {
        final colors = FinanceColorPreferences.fromPreset(preset.storageValue);
        expect(colors.reimburse, colors.income, reason: preset.storageValue);
      }
    },
  );

  test('bill types expose an explicit account-flow direction', () {
    expect(FxBillType.expense.signedFlowAmount(99), -99);
    expect(FxBillType.income.signedFlowAmount(-99), 99);
    expect(FxBillType.reimburse.signedFlowAmount(99), 99);
    expect(FxBillType.loanRepay.signedFlowAmount(99), -99);
    expect(FxBillType.transfer.signedFlowAmount(99), 99);
  });
}
