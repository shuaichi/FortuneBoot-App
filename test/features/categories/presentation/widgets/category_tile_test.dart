import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/features/categories/presentation/widgets/category_tile.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('tapping a branch expands it instead of editing', (tester) async {
    const parent = FortuneCategoryVo(
      categoryId: 1,
      categoryName: '餐饮',
      children: [FortuneCategoryVo(categoryId: 2, categoryName: '早餐')],
    );
    var editCount = 0;
    var expandedId = 0;

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
          body: CategoryTile(
            node: parent,
            typeTint: Colors.green,
            expanded: false,
            onTap: (_) => editCount++,
            onMenu: (_) {},
            onToggleExpand: (id) => expandedId = id,
            expandedFor: (_) => false,
            matchCountFor: (_) => 0,
          ),
        ),
      ),
    );

    await tester.tap(find.text('餐饮'));

    expect(expandedId, 1);
    expect(editCount, 0);
  });

  testWidgets('expanded descendants keep bounded indentation', (tester) async {
    const parent = FortuneCategoryVo(
      categoryId: 1,
      categoryName: '餐饮',
      children: [FortuneCategoryVo(categoryId: 2, categoryName: '早餐')],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: Scaffold(
          body: CategoryTile(
            node: parent,
            typeTint: Colors.green,
            expanded: true,
            onTap: (_) {},
            onMenu: (_) {},
            onToggleExpand: (_) {},
            expandedFor: (_) => false,
            matchCountFor: (_) => 0,
          ),
        ),
      ),
    );

    final root = tester.getTopLeft(find.text('餐饮'));
    final child = tester.getTopLeft(find.text('早餐'));
    expect(child.dx - root.dx, 16);
  });
}
