import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

    for (final token in ['1,', '234,', '567,', '890.12']) {
      final text = tester.widget<Text>(find.text(token));
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.text(token), matching: find.byType(RichText)),
      );
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: token.length),
      );
      expect(boxes.map((box) => box.top.round()).toSet().length, 1);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('masked text keeps the placeholder on one readable line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const Scaffold(
          body: FxMoneyText(amount: 0, currencyCode: 'CNY', masked: true),
        ),
      ),
    );
    expect(find.text(FxMoneyFormatter.hiddenPlaceholder), findsOneWidget);
    expect(
      find.bySemanticsLabel(FxMoneyFormatter.hiddenPlaceholder),
      findsOneWidget,
    );
  });

  testWidgets('compact negative amount preserves exact semantics and tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 48,
            child: FxMoneyText(
              amount: -1234567.89,
              currencyCode: 'CNY',
              compactWhenNeeded: true,
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp('1,234,567.89')), findsOneWidget);
    expect(
      tester.widget<Tooltip>(find.byType(Tooltip)).message,
      contains('1,234,567.89'),
    );
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

      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        expect(text.style?.color, isNot(businessColor));
        expect(text.style?.color, FxPalette.light.textPrimary);
      }
    },
  );
}
