import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';

void main() {
  group('DashboardCardCatalog', () {
    test('normalizeOrder drops unknowns, dedupes, and appends missing ids', () {
      final order = DashboardCardCatalog.normalizeOrder([
        'recentBills',
        'bogus',
        'recentBills',
        'netWorth',
      ]);

      expect(order.first, DashboardCardId.recentBills);
      expect(order[1], DashboardCardId.netWorth);
      expect(order.toSet(), DashboardCardCatalog.allIds.toSet());
      expect(order.length, DashboardCardCatalog.allIds.length);
    });

    test('normalizeHidden uses defaults until layout is configured', () {
      expect(
        DashboardCardCatalog.normalizeHidden(
          const [],
          layoutConfigured: false,
        ),
        DashboardCardCatalog.defaultHidden,
      );
      expect(
        DashboardCardCatalog.normalizeHidden(
          const [],
          layoutConfigured: true,
        ),
        isEmpty,
      );
      expect(
        DashboardCardCatalog.normalizeHidden(
          const ['quickAdd', 'trend', 'nope'],
          layoutConfigured: true,
        ),
        {DashboardCardId.quickAdd, DashboardCardId.trend},
      );
    });

    test('relocate pushes the target card by inserting before or after', () {
      const visible = [
        DashboardCardId.trend,
        DashboardCardId.recentBills,
        DashboardCardId.categoryTop,
      ];

      expect(
        DashboardCardCatalog.relocate(
          visible: visible,
          from: DashboardCardId.trend,
          to: DashboardCardId.categoryTop,
          after: false,
        ),
        [
          DashboardCardId.recentBills,
          DashboardCardId.trend,
          DashboardCardId.categoryTop,
        ],
      );
      expect(
        DashboardCardCatalog.relocate(
          visible: visible,
          from: DashboardCardId.trend,
          to: DashboardCardId.recentBills,
          after: true,
        ),
        [
          DashboardCardId.recentBills,
          DashboardCardId.trend,
          DashboardCardId.categoryTop,
        ],
      );
    });

    test('wide card onto narrow pair pushes the whole pair down', () {
      const visible = [
        DashboardCardId.monthExpense,
        DashboardCardId.monthIncome,
        DashboardCardId.netWorth,
      ];

      expect(
        DashboardCardCatalog.relocate(
          visible: visible,
          from: DashboardCardId.netWorth,
          to: DashboardCardId.monthIncome,
          after: true,
        ),
        [
          DashboardCardId.netWorth,
          DashboardCardId.monthExpense,
          DashboardCardId.monthIncome,
        ],
      );
    });

    test('visibleOrder respects stored order and hidden set', () {
      final visible = DashboardCardCatalog.visibleOrder(
        storedOrder: const ['trend', 'netWorth', 'quickAdd'],
        storedHidden: const ['trend'],
        layoutConfigured: true,
      );

      expect(visible, [
        DashboardCardId.netWorth,
        DashboardCardId.quickAdd,
        DashboardCardId.monthExpense,
        DashboardCardId.monthIncome,
        DashboardCardId.recentBills,
        DashboardCardId.categoryTop,
      ]);
    });
  });
}
