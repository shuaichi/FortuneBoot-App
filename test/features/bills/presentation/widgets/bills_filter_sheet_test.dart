import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/bills/presentation/pages/bills_filter_page.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bills_filter_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('filter actions stay visible and work without scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    BillsFilter? applied;

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
          body: BillsFilterPage(
            initial: BillsFilter(title: '旧条件'),
            onApply: (filter) => applied = filter,
          ),
        ),
      ),
    );
    await tester.pump();

    final apply = find.text('应用');
    expect(apply, findsOneWidget);
    expect(tester.getBottomLeft(apply).dy, lessThanOrEqualTo(700));
    expect(
      find.descendant(of: find.byType(BillsFilterSheet), matching: apply),
      findsNothing,
    );

    await tester.tap(find.text('重置'));
    await tester.tap(apply);

    expect(applied, BillsFilter.empty);
  });

  testWidgets('real sheet keeps actions fixed while its form scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
          body: FractionallySizedBox(
            heightFactor: FxSheet.pickerHeightFactor,
            child: FxSheet(
              title: '筛选',
              child: BillsFilterPage(
                initial: BillsFilter.empty,
                onApply: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final actions = find.byKey(const ValueKey('bills-filter-actions'));
    final scroll = find.descendant(
      of: find.byType(BillsFilterPage),
      matching: find.byType(SingleChildScrollView),
    );
    final before = tester.getRect(actions);
    expect(scroll.evaluate().length, 1);
    await tester.drag(scroll, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.getRect(actions), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet keyboard inset is applied once', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 200)),
          child: FxSheet(
            scrollable: true,
            maxHeightFactor: 0.8,
            child: SizedBox(height: 1200),
          ),
        ),
      ),
    );

    final scroll = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scroll.padding, EdgeInsets.zero);
  });
}
