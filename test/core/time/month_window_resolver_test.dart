import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/time/month_window_resolver.dart';

void main() {
  group('MonthWindowResolver', () {
    test('uses natural month when start day is 1', () {
      final window = MonthWindowResolver.resolveCurrent(
        DateTime(2026, 8, 4),
        1,
      );

      expect(window.anchorMonth, DateTime(2026, 8));
      expect(window.start, DateTime(2026, 8));
      expect(window.end, DateTime(2026, 8, 31));
    });

    test('uses previous anchor month when now is before configured day', () {
      final window = MonthWindowResolver.resolveCurrent(
        DateTime(2026, 8, 4),
        26,
      );

      expect(window.anchorMonth, DateTime(2026, 7));
      expect(window.start, DateTime(2026, 7, 26));
      expect(window.end, DateTime(2026, 8, 25));
    });

    test('uses current anchor month when now equals configured day', () {
      final window = MonthWindowResolver.resolveCurrent(
        DateTime(2026, 8, 26),
        26,
      );

      expect(window.anchorMonth, DateTime(2026, 8));
      expect(window.start, DateTime(2026, 8, 26));
      expect(window.end, DateTime(2026, 9, 25));
    });

    test('clamps start day to the last day of short months', () {
      final window = MonthWindowResolver.resolveForAnchor(
        DateTime(2026, 2),
        31,
      );

      expect(window.start, DateTime(2026, 2, 28));
      expect(window.end, DateTime(2026, 3, 30));
    });

    test('supports leap year February', () {
      final window = MonthWindowResolver.resolveForAnchor(
        DateTime(2028, 2),
        29,
      );

      expect(window.start, DateTime(2028, 2, 29));
      expect(window.end, DateTime(2028, 3, 28));
    });

    test('supports cross-year windows', () {
      final window = MonthWindowResolver.resolveCurrent(
        DateTime(2026, 1, 3),
        26,
      );

      expect(window.anchorMonth, DateTime(2025, 12));
      expect(window.start, DateTime(2025, 12, 26));
      expect(window.end, DateTime(2026, 1, 25));
    });

    test('shifts anchor months', () {
      expect(
        MonthWindowResolver.shift(DateTime(2026, 1), -1),
        DateTime(2025, 12),
      );
      expect(
        MonthWindowResolver.shift(DateTime(2026, 12), 1),
        DateTime(2027, 1),
      );
    });
  });
}
