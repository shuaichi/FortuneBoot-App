import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('matches dashboard asset and liability colors', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => PreferencesCubit(),
        child: MaterialApp(
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
            body: Column(
              children: [
                AccountCard(
                  account: FortuneAccountVo(
                    accountName: '储蓄卡',
                    accountType: 1,
                    balance: 100,
                  ),
                ),
                AccountCard(
                  account: FortuneAccountVo(
                    accountName: '信用卡',
                    accountType: 2,
                    balance: -100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final money = tester
        .widgetList<FxMoneyText>(find.byType(FxMoneyText))
        .toList();
    expect(money.map((item) => item.color), [
      FxPalette.light.success,
      FxPalette.light.danger,
    ]);
    expect(find.text('调整余额'), findsNothing);
  });
}
