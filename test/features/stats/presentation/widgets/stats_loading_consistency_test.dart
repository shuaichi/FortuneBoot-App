import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('StatsCardShell shows compact loading and retry states', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      _harness(
        child: StatsCardShell<int>(
          label: 'Loading card',
          section: const StatsSection.loading(),
          onRetry: () => retried = true,
          builder: (value) => Text('$value'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _harness(
        child: StatsCardShell<int>(
          label: 'Error card',
          section: const StatsSection.error('Failed'),
          onRetry: () => retried = true,
          builder: (value) => Text('$value'),
        ),
      ),
    );

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}

Widget _harness({required Widget child}) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: child),
  );
}
