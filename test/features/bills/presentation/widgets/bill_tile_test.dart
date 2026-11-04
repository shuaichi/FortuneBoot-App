import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bill_tile.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
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
  });
}
