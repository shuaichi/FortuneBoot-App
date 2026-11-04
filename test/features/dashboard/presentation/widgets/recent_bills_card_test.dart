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

  testWidgets('view-all action exposes a minimum 44px interactive target', (
    tester,
  ) async {
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
          home: const Scaffold(
            body: RecentBillsCard(
              section: DashboardSection<List<FortuneBillVo>>.ready([]),
              currencyCode: 'CNY',
              onRetry: _noRetry,
            ),
          ),
        ),
      ),
    );

    final target = find.ancestor(
      of: find.text('全部'),
      matching: find.byType(InkWell),
    );
    expect(target, findsOneWidget);
    expect(tester.getSize(target).height, greaterThanOrEqualTo(44));
    expect(tester.getSize(target).width, greaterThanOrEqualTo(44));
  });

  testWidgets('large accessibility text is not scaled down to fit a card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: RecentBillsCard(
                section: DashboardSection<List<FortuneBillVo>>.ready([
                  FortuneBillVo(
                    billId: 1,
                    title: '午餐',
                    amount: 28,
                    billType: 1,
                    accountName: '日常消费银行卡',
                  ),
                  FortuneBillVo(billId: 2, title: '交通', amount: 6, billType: 1),
                ]),
                currencyCode: 'CNY',
                onRetry: _noRetry,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(RecentBillsCard),
        matching: find.byType(FittedBox),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

void _noRetry() {}
