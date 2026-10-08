import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('masks compact amounts and semantics when amounts are hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        hideAmounts: true,
        child: _calendar(
          view: IncomeExpenseCalendarView.month,
          response: IncomeExpenseCalendarResponse(
            items: const [
              IncomeExpenseCalendarBucket(
                period: '2026-08-20',
                income: 1234,
                expense: 56,
                incomeCount: 1,
                expenseCount: 2,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.textContaining('1234'), findsNothing);
    expect(find.textContaining('56'), findsNothing);
    expect(find.textContaining('••••'), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('1234')), findsNothing);
  });

  testWidgets('opens same-day bills from the day summary', (tester) async {
    DateTime? requestedDate;
    await tester.pumpWidget(
      _harness(
        child: _calendar(
          view: IncomeExpenseCalendarView.month,
          bookId: 1,
          onBillsRequested: (date) => requestedDate = date,
        ),
      ),
    );

    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Open in Bills'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open in Bills'));

    expect(requestedDate, DateTime(2026, 8, 20));
  });

  testWidgets('drills year months and history years to precise anchors', (
    tester,
  ) async {
    IncomeExpenseCalendarView? drilledView;
    DateTime? drilledAnchor;

    await tester.pumpWidget(
      _harness(
        child: _calendar(
          view: IncomeExpenseCalendarView.year,
          onDrillDown: (view, anchor) {
            drilledView = view;
            drilledAnchor = anchor;
          },
        ),
      ),
    );

    await tester.tap(find.text('Aug'));
    expect(drilledView, IncomeExpenseCalendarView.month);
    expect(drilledAnchor, DateTime(2026, 8));

    drilledView = null;
    drilledAnchor = null;
    await tester.pumpWidget(
      _harness(
        child: _calendar(
          view: IncomeExpenseCalendarView.history,
          onDrillDown: (view, anchor) {
            drilledView = view;
            drilledAnchor = anchor;
          },
        ),
      ),
    );

    await tester.tap(find.text('2024'));
    expect(drilledView, IncomeExpenseCalendarView.year);
    expect(drilledAnchor, DateTime(2024));
  });

  testWidgets('keeps calendar layout stable at 320px with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _harness(
        textScale: 2,
        child: _calendar(
          view: IncomeExpenseCalendarView.month,
          response: IncomeExpenseCalendarResponse(
            items: const [
              IncomeExpenseCalendarBucket(
                period: '2026-08-20',
                income: 1234,
                expense: 56,
                incomeCount: 1,
                expenseCount: 2,
              ),
              IncomeExpenseCalendarBucket(
                period: 'not-a-date',
                income: 9999,
                expense: 9999,
              ),
              IncomeExpenseCalendarBucket(
                period: '2026-08-20',
                income: 1,
                expense: 1,
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('20'), findsOneWidget);
  });
}

Widget _calendar({
  required IncomeExpenseCalendarView view,
  IncomeExpenseCalendarResponse? response,
  int? bookId,
  void Function(IncomeExpenseCalendarView view, DateTime anchor)? onDrillDown,
  ValueChanged<DateTime>? onBillsRequested,
}) {
  return Scaffold(
    body: SingleChildScrollView(
      child: StatsIncomeExpenseCalendarCard(
        section: StatsSection.ready(
          response ?? IncomeExpenseCalendarResponse(),
        ),
        bookId: bookId,
        view: view,
        anchor: DateTime(2026, 8),
        currencyCode: 'CNY',
        onViewChanged: (_) {},
        onNavigate: (_) {},
        onDrillDown: onDrillDown ?? (_, _) {},
        onBillsRequested: onBillsRequested ?? (_) {},
        onRetry: () {},
      ),
    ),
  );
}

Widget _harness({
  required Widget child,
  bool hideAmounts = false,
  double textScale = 1,
}) {
  return BlocProvider<SessionCubit>(
    create: (_) => SessionCubit(),
    child: MaterialApp(
      theme: FxTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: StatsPrivacy(hideAmounts: hideAmounts, child: child),
      ),
    ),
  );
}
