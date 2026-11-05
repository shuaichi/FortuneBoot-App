import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  for (final width in [390.0, 440.0]) {
    testWidgets('S2A-001 decimal digits stay with integer at $width/2x', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: FxTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FxMoneyText(
                    amount: 1234567890.12,
                    currencyCode: 'CNY',
                    fontSize: 34,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('890.'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      final integerRect = tester.getRect(find.text('890.'));
      final decimalRect = tester.getRect(find.text('12'));
      expect(
        decimalRect.top,
        integerRect.top,
        reason: 'Decimal digits must not become an isolated third line',
      );
    });
  }
}
