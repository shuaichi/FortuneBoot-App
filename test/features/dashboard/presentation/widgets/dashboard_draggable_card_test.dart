import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_draggable_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('desktop editing uses immediate drag instead of long press', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(_draggableHarness());

      expect(find.byType(LongPressDraggable<DashboardCardId>), findsNothing);
      expect(find.byType(Draggable<DashboardCardId>), findsOneWidget);
    } finally {
      // Flutter 在 tearDown 之前校验 debug 变量，必须在用例体内恢复。
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('remove action exposes a minimum 44px touch target', (
    tester,
  ) async {
    await tester.pumpWidget(_draggableHarness());

    final target = find.byType(InkWell);
    expect(target, findsOneWidget);
    expect(tester.getSize(target).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(target).height, greaterThanOrEqualTo(44));
  });
}

Widget _draggableHarness() {
  return MaterialApp(
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
      body: SizedBox(
        width: 320,
        height: 120,
        child: DashboardDraggableCard(
          id: DashboardCardId.recentBills,
          child: const ColoredBox(color: Colors.white),
          onRemove: () {},
          onInsertNear: (from, to, {required after}) {},
        ),
      ),
    ),
  );
}
