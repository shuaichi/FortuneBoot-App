import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/features/tags/presentation/widgets/tag_tile.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('uses one row surface and bounded indentation', (tester) async {
    const parent = FortuneTagVo(
      tagId: 1,
      tagName: '出行',
      children: [FortuneTagVo(tagId: 2, tagName: '地铁')],
    );

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
          body: TagTile(
            node: parent,
            expanded: true,
            onTap: (_) {},
            onMenu: (_) {},
            onToggleExpand: (_) {},
            expandedFor: (_) => false,
          ),
        ),
      ),
    );

    final root = tester.getTopLeft(find.text('出行'));
    final child = tester.getTopLeft(find.text('地铁'));
    expect(child.dx - root.dx, 16);
    expect(find.byIcon(Icons.more_horiz_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });
}
