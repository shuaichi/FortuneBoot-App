import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_date_picker.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('localizes date picker chrome in English', (tester) async {
    await tester.pumpWidget(_harness(const Locale('en')));

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Select date'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Start of month'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('选择日期'), findsNothing);
  });

  testWidgets('keeps a caller supplied picker title', (tester) async {
    await tester.pumpWidget(
      _harness(const Locale('en'), title: 'Posting date'),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Posting date'), findsOneWidget);
  });

  testWidgets('keeps date picker usable at 320px with 2x text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness(const Locale('en'), textScale: 2));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Select date'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}

Widget _harness(Locale locale, {String? title, double textScale = 1}) {
  return MaterialApp(
    locale: locale,
    theme: FxTheme.light,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () {
                if (title case final customTitle?) {
                  showFxDatePicker(
                    context,
                    initial: DateTime(2026, 8, 20),
                    title: customTitle,
                  );
                  return;
                }
                showFxDatePicker(context, initial: DateTime(2026, 8, 20));
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}
