import 'package:flutter/cupertino.dart';
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
    expect(find.text('Confirm'), findsNothing);
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

  testWidgets('shows a 24-hour date and time picker', (tester) async {
    await tester.pumpWidget(_harness(const Locale('en'), dateTime: true));

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final picker = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(find.text('Select date and time'), findsOneWidget);
    expect(picker.mode, CupertinoDatePickerMode.dateAndTime);
    expect(picker.use24hFormat, isTrue);
  });

  testWidgets('keeps the selected time when using a date-time shortcut', (
    tester,
  ) async {
    final expected = DateTime.now().subtract(const Duration(days: 1));
    DateTime? picked;
    await tester.pumpWidget(
      _harness(
        const Locale('en'),
        dateTime: true,
        onPicked: (value) => picked = value,
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yesterday'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.year, expected.year);
    expect(picked!.month, expected.month);
    expect(picked!.day, expected.day);
    expect(picked!.hour, 14);
    expect(picked!.minute, 35);
  });

  testWidgets('shifts the selected date by one year', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _harness(
        const Locale('en'),
        initial: DateTime(2026, 8, 20),
        onPicked: (value) => picked = value,
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous year'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(picked, DateTime(2025, 8, 20));
  });

  testWidgets('clamps leap days when shifting years', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _harness(
        const Locale('en'),
        initial: DateTime(2024, 2, 29),
        onPicked: (value) => picked = value,
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next year'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(picked, DateTime(2025, 2, 28));
  });

  testWidgets('keeps Done usable at 320px with 3x text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _harness(const Locale('en'), dateTime: true, textScale: 3),
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Select date and time'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byTooltip('Previous year'), findsOneWidget);
    expect(find.byTooltip('Next year'), findsOneWidget);
    expect(find.byType(CupertinoDatePicker), findsOneWidget);

    final doneRect = tester.getRect(find.text('Done'));
    expect(doneRect.bottom, lessThanOrEqualTo(640));
  });
}

Widget _harness(
  Locale locale, {
  String? title,
  DateTime? initial,
  bool dateTime = false,
  ValueChanged<DateTime?>? onPicked,
  double textScale = 1,
}) {
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
              onPressed: () async {
                final picked = dateTime
                    ? await showFxDateTimePicker(
                        context,
                        initial: initial ?? DateTime(2026, 8, 20, 14, 35),
                        title: title,
                      )
                    : await showFxDatePicker(
                        context,
                        initial: initial ?? DateTime(2026, 8, 20),
                        title: title,
                      );
                onPicked?.call(picked);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}
