import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('large text keeps the complete action readable and tappable', (
    tester,
  ) async {
    var presses = 0;
    const label = '保存修改并返回账本';
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: FxButton(label: label, onPressed: () => presses++),
              ),
            ),
          ),
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.getSize(find.byType(FxButton)).height, greaterThan(48));
    await tester.tap(find.text(label));
    expect(presses, 1);
    expect(tester.takeException(), isNull);
  });
}
