import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/layout/fx_page_scaffold.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('renders the shared header and delegates back navigation', (
    tester,
  ) async {
    var backed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: FxPageScaffold(
          title: '日志',
          onBack: () => backed = true,
          child: const Text('page-body'),
        ),
      ),
    );

    expect(find.text('日志'), findsOneWidget);
    expect(find.text('page-body'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    expect(backed, isTrue);
  });

  testWidgets('can hide the back affordance for first-level pages', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const FxPageScaffold(
          title: '我的',
          showBack: false,
          child: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('我的'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
  });
}
