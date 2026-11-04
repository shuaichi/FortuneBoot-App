import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('keeps recycle bin outside lifecycle segments', (tester) async {
    var tab = ManageTab.all;

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
        home: StatefulBuilder(
          builder: (context, setState) {
            return ManageScaffold(
              title: '成员',
              onAdd: () {},
              onSearch: (_) {},
              tab: tab,
              onTabChanged: (next) => setState(() => tab = next),
              body: const SizedBox.shrink(),
            );
          },
        ),
      ),
    );

    final segmented = tester.widget<FxSegmented<ManageTab>>(
      find.byType(FxSegmented<ManageTab>),
    );
    expect(segmented.segments.map((s) => s.value), [
      ManageTab.all,
      ManageTab.enabled,
      ManageTab.disabled,
    ]);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(tab, ManageTab.recycleBin);
    expect(find.byType(FxSegmented<ManageTab>), findsNothing);
    expect(find.text('回收站'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    await tester.tap(find.text('回收站'));
    await tester.pumpAndSettle();

    expect(tab, ManageTab.all);
    expect(find.byType(FxSegmented<ManageTab>), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
