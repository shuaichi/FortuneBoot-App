import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('long money text wraps instead of ellipsizing by default', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 160,
              child: FxMoneyText(
                amount: 1234567890.12,
                currencyCode: 'CNY',
                fontSize: 34,
              ),
            ),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'masked money never exposes exact value to semantics or tooltip',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FxTheme.light,
          home: const Scaffold(
            body: FxMoneyText(
              amount: 123456.78,
              currencyCode: 'CNY',
              masked: true,
              compactWhenNeeded: true,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(FxMoneyFormatter.hiddenPlaceholder),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('123')), findsNothing);
      expect(find.byType(Tooltip), findsNothing);
      expect(find.textContaining('123'), findsNothing);
    },
  );

  testWidgets(
    'finance preference color is not reused as small text foreground',
    (tester) async {
      const businessColor = Color(0xFFFFF59D);
      final theme = FxTheme.light.copyWith(
        extensions: [
          FxPalette.light,
          const FxFinanceColors(
            income: businessColor,
            expense: businessColor,
            transfer: businessColor,
            adjust: businessColor,
            advance: businessColor,
            reimburse: businessColor,
            loanOut: businessColor,
            loanRecover: businessColor,
            loanIn: businessColor,
            loanRepay: businessColor,
            holiday: businessColor,
            rest: businessColor,
            work: businessColor,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: FxMoneyText(amount: 12, billType: 1)),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.color, isNot(businessColor));
      expect(text.style?.color, FxPalette.light.textPrimary);
    },
  );
}
