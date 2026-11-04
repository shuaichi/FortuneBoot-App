import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/features/payees/presentation/widgets/payee_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('keeps internal sort out of the list row', (tester) async {
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
        home: Scaffold(
          body: PayeeCard(
            payee: const FortunePayeeVo(
              payeeName: '便利店',
              sort: 0,
              canExpense: true,
              canIncome: false,
            ),
            onTap: () {},
            onMenu: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('排序'), findsNothing);
    expect(find.text('可支'), findsOneWidget);
    expect(find.text('可收'), findsNothing);
  });
}
