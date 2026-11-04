import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

Widget _app(Widget child) => MaterialApp(
  theme: FxTheme.light,
  locale: const Locale('zh'),
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    S.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('clear action does not open the picker', (tester) async {
    var pickerOpened = 0;
    var cleared = 0;
    await tester.pumpWidget(
      _app(
        FxSelectRow(
          label: '分类',
          value: '餐饮',
          onTap: () => pickerOpened++,
          onClear: () => cleared++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    expect(cleared, 1);
    expect(pickerOpened, 0);

    await tester.tap(find.text('餐饮'));
    expect(pickerOpened, 1);
  });

  testWidgets('long value stays inside a 320 width row', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(FxSelectRow(label: '账户', value: '招商银行储蓄卡（尾号1234）', onTap: () {})),
    );

    expect(tester.takeException(), isNull);
  });
}
