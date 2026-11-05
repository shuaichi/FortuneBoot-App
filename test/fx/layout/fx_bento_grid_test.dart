import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/layout/fx_bento_grid.dart';

void main() {
  testWidgets('full-span tile fills available grid width', (tester) async {
    const key = ValueKey('full');

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 900,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FxBentoGrid(
              tiles: [
                FxBentoTile(
                  colSpan: FxBentoTile.fullSpan,
                  child: ColoredBox(key: key, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final gridWidth = tester.getSize(find.byType(SizedBox).last).width;
    final tileWidth = tester.getSize(find.byKey(key)).width;

    expect(tileWidth, gridWidth);
  });

  testWidgets('tiles do not overlap after a row-spanning tile', (tester) async {
    const tall = ValueKey('tall');
    const first = ValueKey('first');
    const second = ValueKey('second');

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 900,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FxBentoGrid(
              rowHeight: 40,
              spacing: 8,
              padding: EdgeInsets.zero,
              tiles: [
                FxBentoTile(
                  colSpan: 2,
                  rowSpan: 2,
                  child: ColoredBox(key: tall, color: Colors.red),
                ),
                FxBentoTile(
                  child: ColoredBox(key: first, color: Colors.green),
                ),
                FxBentoTile(
                  child: ColoredBox(key: second, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final tallRect = tester.getRect(find.byKey(tall));
    final firstRect = tester.getRect(find.byKey(first));
    final secondRect = tester.getRect(find.byKey(second));

    expect(tallRect.overlaps(firstRect), isFalse);
    expect(tallRect.overlaps(secondRect), isFalse);
    expect(firstRect.overlaps(secondRect), isFalse);
  });

  testWidgets('reduced motion resolves grid animation durations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FxBentoGrid(tiles: [FxBentoTile(child: Text('卡片'))]),
          ),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
      Duration.zero,
    );
    expect(
      tester
          .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
          .duration,
      Duration.zero,
    );
  });

  testWidgets(
    'narrow large-text grid becomes an intrinsic-height summary list',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                child: FxBentoGrid(
                  tiles: [
                    FxBentoTile(child: Text('非常长的统计卡片标题和完整金额人民币123456789元')),
                    FxBentoTile(child: Text('第二张卡片')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(FxBentoGrid),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );
      expect(tester.getSize(find.text('第二张卡片')).width, greaterThan(200));
      expect(tester.takeException(), isNull);
    },
  );
}
