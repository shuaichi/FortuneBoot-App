import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('uses distinct semantic colors for goods lifecycle states', (
    tester,
  ) async {
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
        home: const Scaffold(
          body: Column(
            children: [
              GoodsCard(
                goods: FortuneGoodsKeeperVo(status: 1, statusDesc: '在役'),
              ),
              GoodsCard(
                goods: FortuneGoodsKeeperVo(status: 2, statusDesc: '退役'),
              ),
              GoodsCard(
                goods: FortuneGoodsKeeperVo(status: 3, statusDesc: '已出售'),
              ),
            ],
          ),
        ),
      ),
    );

    Color colorOf(String label) =>
        tester.widget<Text>(find.text(label)).style!.color!;

    expect(colorOf('在役'), FxPalette.light.success);
    expect(colorOf('退役'), FxPalette.light.textSecondary);
    expect(colorOf('已出售'), FxPalette.light.info);
  });
}
