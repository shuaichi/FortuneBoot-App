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
  testWidgets('adjusted amount is labelled and never compacted', (
    tester,
  ) async {
    await tester.pumpWidget(
      _tileHarness(
        const FortuneBillVo(
          billId: 1,
          title: '费用核对',
          amount: 100,
          billType: 1,
          currencyCode: 'CNY',
          extras: [
            BillExtra(extraType: 1, amount: 3),
            BillExtra(extraType: 2, amount: 5),
          ],
        ),
      ),
    );

    expect(find.textContaining('实付'), findsOneWidget);
    expect(find.textContaining('原额'), findsOneWidget);
    expect(
      tester.widget<FxMoneyText>(find.byType(FxMoneyText)).compactWhenNeeded,
      isFalse,
    );
  });

  testWidgets('hidden adjusted amounts do not leak through text or semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      _tileHarness(
        const FortuneBillVo(
          billId: 1,
          title: '隐藏费用',
          amount: 100,
          billType: 1,
          currencyCode: 'CNY',
          extras: [BillExtra(extraType: 1, amount: 3)],
        ),
        masked: true,
      ),
    );

    expect(find.textContaining('103'), findsNothing);
    expect(find.textContaining('100'), findsNothing);
    expect(find.text('-'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('10[03]')), findsNothing);
    expect(find.byTooltip(RegExp('10[03]')), findsNothing);
  });

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
    expect(find.bySemanticsLabel('-¥28.00'), findsOneWidget);
    expect(find.text('+¥28.00'), findsNothing);
    final amount = tester.widget<FxMoneyText>(find.byType(FxMoneyText));
    expect(amount.amount, 28);
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

  testWidgets(
    'long title and full large amount do not overflow at 320 and 2x',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _tileHarness(
          const FortuneBillVo(
            billId: 1,
            title: '这是一段用于验证账单标题在窄屏和系统大字体下能够正常换行的长标题',
            amount: 123456789.12,
            billType: 1,
            currencyCode: 'CNY',
            extras: [BillExtra(extraType: 1, amount: 3)],
          ),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<FxMoneyText>(find.byType(FxMoneyText)).compactWhenNeeded,
        isFalse,
      );
      expect(find.bySemanticsLabel('-¥123,456,792.12'), findsOneWidget);
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

Widget _tileHarness(
  FortuneBillVo bill, {
  bool masked = false,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: BillTile(bill: bill, masked: masked),
      ),
    ),
  );
}
