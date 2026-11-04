import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_trend_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('empty trend collapses to a lightweight empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        StatsTrendCard(
          section: const StatsSection.ready(<TrendPoint>[]),
          type: StatsType.expense,
          currencyCode: 'CNY',
          onRetry: () {},
        ),
      ),
    );

    expect(tester.getSize(find.byType(StatsTrendCard)).height, lessThan(140));
    expect(find.text('No records this period'), findsOneWidget);
  });

  testWidgets('loading shell does not reserve chart height', (tester) async {
    await tester.pumpWidget(
      _harness(
        StatsCardShell<List<TrendPoint>>(
          label: 'Trend',
          section: const StatsSection.loading(),
          onRetry: () {},
          builder: (_) => const SizedBox.shrink(),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(StatsCardShell<List<TrendPoint>>)).height,
      lessThan(160),
    );
  });
}

Widget _harness(Widget child) {
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
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}
