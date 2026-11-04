import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('short content is not forced to a minimum screen fraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => FxSheet.show<void>(
                context,
                title: '详情',
                footer: const SizedBox(height: 56),
                child: const SizedBox(height: 40),
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getSize(find.byType(FxSheet)).height,
      lessThan(viewportHeight * 0.4),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a titled sheet provides a close action by default', (
    tester,
  ) async {
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
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => FxSheet.show<void>(
                context,
                title: '账单详情',
                child: const Text('内容'),
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    final close = find.byIcon(Icons.close_rounded);
    expect(close, findsOneWidget);
    await tester.tap(close);
    await tester.pumpAndSettle();

    expect(find.byType(FxSheet), findsNothing);
  });
}
