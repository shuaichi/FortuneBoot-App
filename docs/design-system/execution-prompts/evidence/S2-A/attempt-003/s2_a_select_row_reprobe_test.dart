import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('CX-02 select row keeps Counterparty in one line at 440/1x', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const label = '交易对象 / Counterparty';
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
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: FxSelectRow(
              label: label,
              value: '京东集团一个非常长的供应商名称 / A very long counterparty name',
              onTap: () {},
              onClear: () {},
            ),
          ),
        ),
      ),
    );

    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: find.text('Counterparty'), matching: find.byType(RichText)),
    );
    const start = 0;
    final boxes = paragraph.getBoxesForSelection(
      const TextSelection(
        baseOffset: start,
        extentOffset: start + 'Counterparty'.length,
      ),
    );
    expect(
      boxes.map((box) => box.top.round()).toSet().length,
      1,
      reason: 'The English field name must not split as Counterpart / y',
    );
  });
}
