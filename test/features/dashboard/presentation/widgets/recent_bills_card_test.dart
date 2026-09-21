import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/recent_bills_card.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('tapping a recent bill reports that bill to its parent', (
    tester,
  ) async {
    const bill = FortuneBillVo(billId: 1, title: '午餐', amount: 28, billType: 1);
    FortuneBillVo? tappedBill;
    final preferences = PreferencesCubit();
    addTearDown(preferences.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: preferences,
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
          home: Scaffold(
            body: RecentBillsCard(
              section: const DashboardSection<List<FortuneBillVo>>.ready([
                bill,
              ]),
              currencyCode: 'CNY',
              onRetry: () {},
              onBillTap: (value) => tappedBill = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('午餐'));

    expect(tappedBill, same(bill));
  });
}
