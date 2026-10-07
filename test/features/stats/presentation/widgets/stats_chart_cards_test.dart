import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_pie_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_tag_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('pie card hides amount and percent details when masked', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        hideAmounts: true,
        child: StatsPieCard(
          label: 'Category share',
          currencyCode: 'CNY',
          section: const StatsSection.ready([
            PieSlice(id: 1, name: 'Food', value: 1234, percent: 80),
            PieSlice(id: 2, name: 'Travel', value: 10, percent: 20),
          ]),
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.textContaining('1,234'), findsNothing);
    expect(find.textContaining('80%'), findsNothing);
    expect(find.textContaining('••••'), findsWidgets);
  });

  testWidgets('tag chart filters non-positive items and limits to top ten', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: StatsTagCard(
          label: 'Tags',
          currencyCode: 'CNY',
          section: StatsSection.ready([
            for (var i = 0; i < 12; i++)
              BarItem(id: i, name: 'Tag $i', value: (12 - i).toDouble()),
            const BarItem(id: 99, name: 'Zero'),
          ]),
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('Tag 0'), findsOneWidget);
    expect(find.text('Tag 9'), findsOneWidget);
    expect(find.text('Tag 10'), findsNothing);
    expect(find.text('Zero'), findsNothing);
  });
}

Widget _harness({required Widget child, bool hideAmounts = false}) {
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
    home: StatsPrivacy(
      hideAmounts: hideAmounts,
      child: Scaffold(body: child),
    ),
  );
}
