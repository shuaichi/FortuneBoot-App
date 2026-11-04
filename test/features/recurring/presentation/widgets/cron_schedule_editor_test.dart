import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/recurring/data/cron_builder.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/cron_schedule_editor.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('monthly days use a seven-column grid with 44pt targets', (
    tester,
  ) async {
    CronSpec? changed;
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
          body: CronScheduleEditor(
            spec: const CronSpec(frequency: CronFrequency.monthly),
            onChanged: (spec) => changed = spec,
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('cron-day-grid')),
    );
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 7);

    final day15 = find.byKey(const ValueKey('cron-day-15'));
    expect(tester.getSize(day15).height, greaterThanOrEqualTo(44));
    await tester.tap(day15);
    expect(changed?.dayOfMonth, 15);
    expect(changed?.lastDayOfMonth, isFalse);

    expect(
      tester.getSize(find.byKey(const ValueKey('cron-last-day'))).height,
      greaterThanOrEqualTo(44),
    );
  });
}
