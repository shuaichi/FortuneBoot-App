import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/dashboard_page.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/month_stat_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/net_worth_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/recent_bills_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/trend_card.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/layout/fx_bento_grid.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('mobile places recent bills after the bento grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpDashboard(tester);

    final grid = tester.getRect(find.byType(FxBentoGrid));
    final recent = tester.getRect(find.byType(RecentBillsCard));
    expect(recent.top, greaterThanOrEqualTo(grid.bottom));
    expect(
      find.descendant(
        of: find.byType(FxBentoGrid),
        matching: find.byType(RecentBillsCard),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('net worth is the full-width hero above the supporting grid', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    final hero = tester.getRect(find.byType(NetWorthCard));
    final grid = tester.getRect(find.byType(FxBentoGrid));
    expect(hero.bottom, lessThanOrEqualTo(grid.top));
    expect(hero.width, closeTo(grid.width, 0.01));
    expect(
      find.descendant(
        of: find.byType(FxBentoGrid),
        matching: find.byType(NetWorthCard),
      ),
      findsNothing,
    );
  });

  testWidgets('desktop uses an aligned 360px recent-bills sidebar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpDashboard(tester);

    final grid = tester.getRect(find.byType(FxBentoGrid));
    final recent = tester.getRect(find.byType(RecentBillsCard));
    expect(recent.width, 360);
    expect(recent.top, closeTo(grid.top, 0.01));
    expect(recent.left, greaterThan(grid.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text does not shrink summary amounts or overflow cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpDashboard(
      tester,
      textScale: 2,
      assets: const AssetsLiabilities(
        totalAssets: 987654321098.76,
        totalLiabilities: 123456789012.34,
        netAssets: 864197532086.42,
      ),
      monthStats: const BillStatistics(
        expense: 123456789012.34,
        income: 987654321098.76,
      ),
      categories: const [
        CategorySlice(name: '非常长的分类名称用于验证布局', value: 123456789, percent: 100),
      ],
    );

    for (final cardType in [NetWorthCard, MonthStatCard]) {
      expect(
        find.descendant(
          of: find.byType(cardType),
          matching: find.byType(FittedBox),
        ),
        findsNothing,
      );
    }
    final monthAmount = tester.widget<FxMoneyText>(
      find.descendant(
        of: find.byType(MonthStatCard).first,
        matching: find.byType(FxMoneyText),
      ),
    );
    expect(monthAmount.color, FxPalette.light.textPrimary);
    expect(
      find.descendant(
        of: find.byType(MonthStatCard).first,
        matching: find.text('¥123,456,789,012.34'),
      ),
      findsNothing,
    );
    final layoutError = tester.takeException();
    expect(
      layoutError,
      isNull,
      reason: layoutError is FlutterError
          ? layoutError.toStringDeep()
          : layoutError?.toString(),
    );
  });

  testWidgets('empty trends do not consume primary dashboard space', (
    tester,
  ) async {
    await _pumpDashboard(tester);

    expect(find.byType(TrendCard), findsNothing);
    expect(find.byType(RecentBillsCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  double textScale = 1,
  AssetsLiabilities assets = const AssetsLiabilities(),
  BillStatistics monthStats = const BillStatistics(),
  List<CategorySlice> categories = const [],
}) async {
  final session = SessionCubit();
  final preferences = PreferencesCubit();
  final dashboard = _PreviewDashboardBloc()
    ..seed(
      DashboardState(
        hasBook: true,
        currencyCode: 'CNY',
        assets: DashboardSection.ready(assets),
        monthStats: DashboardSection.ready(monthStats),
        expenseTrends: const DashboardSection.ready(<TrendPoint>[]),
        incomeTrends: const DashboardSection.ready(<TrendPoint>[]),
        categories: DashboardSection.ready(categories),
        recentBills: const DashboardSection.ready([
          FortuneBillVo(billId: 1, title: '午餐', amount: 28, billType: 1),
          FortuneBillVo(billId: 2, title: '晚餐', amount: 45, billType: 1),
          FortuneBillVo(billId: 3, title: '交通', amount: 6, billType: 1),
        ]),
      ),
    );
  addTearDown(session.close);
  addTearDown(preferences.close);
  addTearDown(dashboard.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: preferences),
        BlocProvider<DashboardBloc>.value(value: dashboard),
      ],
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
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const DashboardPage(),
      ),
    ),
  );
  await tester.pump();
}

class _PreviewDashboardBloc extends DashboardBloc {
  _PreviewDashboardBloc() : super(bookId: 1, currencyCode: 'CNY');

  void seed(DashboardState value) => emit(value);
}
