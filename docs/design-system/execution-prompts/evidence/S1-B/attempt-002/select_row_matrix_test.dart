import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  for (final width in [320.0, 390.0, 440.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final clear in [false, true]) {
        testWidgets('select row label $width/$scale/clear=$clear', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          const label = '交易对象 / Counterparty';
          const value = '京东集团一个非常长的供应商名称 / A very long counterparty name';
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
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FxSelectRow(
                      label: label,
                      value: value,
                      onTap: clear ? () {} : null,
                      onClear: clear ? () {} : null,
                    ),
                  ),
                ),
              ),
            ),
          );

          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(
              of: find.text('Counterparty'),
              matching: find.byType(RichText),
            ),
          );
          final boxes = paragraph.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 12),
          );
          expect(boxes.map((box) => box.top.round()).toSet().length, 1);
          expect(find.text(value), findsOneWidget);
          if (clear) {
            final target = find.bySemanticsLabel('清空 $label');
            expect(target, findsOneWidget);
            expect(tester.getSize(target).width, greaterThanOrEqualTo(44));
            expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
