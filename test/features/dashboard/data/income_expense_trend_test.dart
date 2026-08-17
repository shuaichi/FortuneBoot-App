import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';

void main() {
  group('IncomeExpenseTrend.align', () {
    test('orders the date union and fills missing values with zero', () {
      final trend = IncomeExpenseTrend.align(
        expense: const [
          TrendPoint(name: '2026-08-03', value: 30),
          TrendPoint(name: '2026-08-01', value: 10),
        ],
        income: const [
          TrendPoint(name: '2026-08-02', value: 20),
          TrendPoint(name: '2026-08-03', value: 40),
        ],
      );

      expect(trend.expense.map((point) => (point.name, point.value)), [
        ('2026-08-01', 10.0),
        ('2026-08-02', 0.0),
        ('2026-08-03', 30.0),
      ]);
      expect(trend.income.map((point) => (point.name, point.value)), [
        ('2026-08-01', 0.0),
        ('2026-08-02', 20.0),
        ('2026-08-03', 40.0),
      ]);
    });

    test('returns empty series when both inputs are empty', () {
      final trend = IncomeExpenseTrend.align(expense: [], income: []);

      expect(trend.expense, isEmpty);
      expect(trend.income, isEmpty);
    });
  });
}
