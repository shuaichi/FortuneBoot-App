import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/data/stats_card_catalog.dart';

void main() {
  group('StatsCardCatalog', () {
    test('normalizeOrder appends missing ids', () {
      final order = StatsCardCatalog.normalizeOrder(const ['trend', 'bogus']);
      expect(order.first, StatsCardId.trend);
      expect(order.toSet(), StatsCardCatalog.allIds.toSet());
    });

    test('relocate inserts before or after', () {
      const visible = [
        StatsCardId.overview,
        StatsCardId.calendar,
        StatsCardId.trend,
      ];
      expect(
        StatsCardCatalog.relocate(
          visible: visible,
          from: StatsCardId.trend,
          to: StatsCardId.overview,
          after: false,
        ),
        [
          StatsCardId.trend,
          StatsCardId.overview,
          StatsCardId.calendar,
        ],
      );
    });
  });
}
