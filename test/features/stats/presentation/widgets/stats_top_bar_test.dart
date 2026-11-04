import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_top_bar.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets(
    'range opens one menu beside the only primary segmented control',
    (tester) async {
      final bloc = StatsBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            theme: FxTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              S.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const Scaffold(body: StatsTopBar()),
          ),
        ),
      );

      expect(find.byType(FxSegmented<StatsType>), findsOneWidget);
      expect(find.text('This week'), findsNothing);
      expect(find.text('This year'), findsNothing);

      await tester.tap(find.text('This period'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<StatsRange>), findsNWidgets(4));
      await tester.tap(find.text('This week'));
      await tester.pumpAndSettle();
      expect(bloc.state.range, StatsRange.week);
    },
  );
}
