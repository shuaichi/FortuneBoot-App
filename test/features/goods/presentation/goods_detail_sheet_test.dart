import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_detail_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('keeps a long goods detail within adaptive sheet bounds', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const goods = FortuneGoodsKeeperVo(
      goodsName: '归物详情',
      price: 123,
      purchaseDate: '2026-03-22',
      holdingTime: 1,
      dailyAverageCost: 123,
      categoryName: '生活必要支出',
      tagName: '测试标签',
      warrantyDate: '2027-07-08',
      isOverWarranty: '未过保',
      useByTimes: true,
      usageNum: 1,
      statusDesc: '出售',
      retiredDate: '2026-03-22',
      soldPrice: 87,
      remark:
          '这是一段较长的归物备注，用来验证小屏幕下详情内容可以安全滚动。'
          '这是一段较长的归物备注，用来验证小屏幕下详情内容可以安全滚动。'
          '这是一段较长的归物备注，用来验证小屏幕下详情内容可以安全滚动。',
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
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => FxSheet.show<void>(
                context,
                scrollable: true,
                minHeightFactor: 0.4,
                maxHeightFactor: 0.72,
                child: const GoodsDetailSheet(goods: goods),
              ),
              child: const Text('打开归物详情'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开归物详情'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(FxSheet)).height,
      lessThanOrEqualTo(568 * 0.72),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('87.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
