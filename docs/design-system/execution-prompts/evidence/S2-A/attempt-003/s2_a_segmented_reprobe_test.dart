import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('S2A-002 vertical segmented remains tappable at 320/2x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = 'income';
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setState) => FxSegmented<String>(
                  value: selected,
                  onChanged: (value) => setState(() => selected = value),
                  segments: const [
                    FxSegment('income', '收入分类 / Income'),
                    FxSegment('expense', '支出分类 / Expense'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (final label in ['收入分类 / Income', '支出分类 / Expense']) {
      final target = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == label,
      );
      expect(target, findsOneWidget);
      expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
    }
    await tester.tap(find.text('支出分类 / Expense'));
    await tester.pumpAndSettle();
    expect(selected, 'expense');
    expect(tester.takeException(), isNull);
  });
}
