import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

Widget _app(Widget child, {double scale = 1}) => MaterialApp(
  theme: FxTheme.light,
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Scaffold(body: child),
  ),
);

Set<int> _lineTops(
  WidgetTester tester,
  String fullText, {
  required int start,
  required int end,
}) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: find.text(fullText), matching: find.byType(RichText)),
  );
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: start, extentOffset: end),
  );
  return boxes.map((box) => box.top.round()).toSet();
}

void main() {
  for (final testCase in [
    (width: 280.0, scale: 1.0),
    (width: 280.0, scale: 2.0),
    (width: 350.0, scale: 2.0),
    (width: 400.0, scale: 2.0),
  ]) {
    testWidgets(
      'S2A-001 amount preserves financial groups ${testCase.width}/${testCase.scale}',
      (tester) async {
        await tester.pumpWidget(
          _app(
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: testCase.width,
                child: const FxMoneyText(
                  amount: 1234567890.12,
                  currencyCode: 'CNY',
                  fontSize: 34,
                ),
              ),
            ),
            scale: testCase.scale,
          ),
        );

        expect(find.text('¥'), findsOneWidget);
        for (final token in ['1,', '234,', '567,', '890.12']) {
          expect(find.text(token), findsOneWidget);
          expect(
            tester.getSize(find.text(token)).width,
            lessThanOrEqualTo(testCase.width),
          );
          expect(
            _lineTops(tester, token, start: 0, end: token.length).length,
            1,
          );
        }
        expect(find.textContaining('1,234,567,890.12'), findsNothing);
        expect(
          find.bySemanticsLabel(RegExp('1,234,567,890.12')),
          findsOneWidget,
        );
      },
    );
  }

  for (final testCase in [
    (width: 320.0, scale: 2.0, multi: false),
    (width: 390.0, scale: 2.0, multi: false),
    (width: 440.0, scale: 2.0, multi: false),
    (width: 320.0, scale: 2.0, multi: true),
  ]) {
    testWidgets(
      'S2A-002 segmented reflows ${testCase.width}/${testCase.scale}/${testCase.multi}',
      (tester) async {
        tester.view.physicalSize = Size(testCase.width, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final labels = testCase.multi
            ? ['收入 / Income', '支出 / Expense', '转账 / Transfer']
            : ['收入分类 / Income', '支出分类 / Expense'];
        await tester.pumpWidget(
          _app(
            Padding(
              padding: const EdgeInsets.all(20),
              child: FxSegmented<int>(
                value: 1,
                onChanged: (_) {},
                segments: [
                  for (var index = 0; index < labels.length; index++)
                    FxSegment(index, labels[index]),
                ],
              ),
            ),
            scale: testCase.scale,
          ),
        );

        final rects = labels
            .map((label) => tester.getRect(find.text(label)))
            .toList();
        for (var index = 1; index < rects.length; index++) {
          expect(
            rects[index].top,
            greaterThanOrEqualTo(rects[index - 1].bottom),
          );
        }
        for (final label in labels) {
          final english = label.split(' ').last;
          expect(
            _lineTops(
              tester,
              label,
              start: label.length - english.length,
              end: label.length,
            ).length,
            1,
          );
          expect(
            tester.getSize(find.text(label)).height,
            greaterThanOrEqualTo(44),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
