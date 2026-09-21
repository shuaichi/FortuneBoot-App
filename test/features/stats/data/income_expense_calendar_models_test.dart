import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';

void main() {
  group('IncomeExpenseCalendarRequest', () {
    test('builds only month query parameters', () {
      final request = IncomeExpenseCalendarRequest.month(
        bookId: 1,
        year: 2026,
        month: 8,
      );

      expect(request.toQueryParameters(), {
        'bookId': 1,
        'granularity': 1,
        'year': 2026,
        'month': 8,
      });
    });

    test('builds only history query parameters', () {
      final request = IncomeExpenseCalendarRequest.history(
        bookId: 1,
        startYear: 2021,
        endYear: 2025,
      );

      expect(request.toQueryParameters(), {
        'bookId': 1,
        'granularity': 3,
        'startYear': 2021,
        'endYear': 2025,
      });
    });

    test('rejects invalid request values', () {
      expect(
        () =>
            IncomeExpenseCalendarRequest.month(bookId: 0, year: 2026, month: 8),
        throwsArgumentError,
      );
      expect(
        () => IncomeExpenseCalendarRequest.month(
          bookId: 1,
          year: 2026,
          month: 13,
        ),
        throwsArgumentError,
      );
      expect(
        () => IncomeExpenseCalendarRequest.history(
          bookId: 1,
          startYear: 2025,
          endYear: 2021,
        ),
        throwsArgumentError,
      );
      expect(
        () => IncomeExpenseCalendarRequest.history(
          bookId: 1,
          startYear: 2015,
          endYear: 2025,
        ),
        throwsArgumentError,
      );
      expect(
        () => IncomeExpenseCalendarRequest.year(bookId: 1, year: 1899),
        throwsArgumentError,
      );
      expect(
        () => IncomeExpenseCalendarRequest.year(bookId: 1, year: 2101),
        throwsArgumentError,
      );
    });
  });

  test('parses the confirmed calendar response envelope', () {
    final response = IncomeExpenseCalendarResponse.fromJson({
      'startDate': '2026-01-01',
      'endDate': '2026-12-31',
      'granularity': 2,
      'items': [
        {
          'period': '2026-08',
          'income': '125.5',
          'expense': 80,
          'incomeCount': '2',
          'expenseCount': 1,
        },
      ],
    });

    expect(response.granularity, IncomeExpenseCalendarGranularity.year);
    expect(response.startDate, '2026-01-01');
    expect(response.endDate, '2026-12-31');
    expect(response.items, hasLength(1));
    expect(response.items.single.period, '2026-08');
    expect(response.items.single.income, 125.5);
    expect(response.items.single.expense, 80);
    expect(response.items.single.incomeCount, 2);
    expect(response.items.single.expenseCount, 1);
    expect(response.items.single.totalAmount, 205.5);
    expect(response.items.single.totalCount, 3);
  });

  test('uses safe zero defaults for missing bucket values', () {
    final bucket = IncomeExpenseCalendarBucket.fromJson({'period': '2026'});

    expect(bucket.income, 0);
    expect(bucket.expense, 0);
    expect(bucket.incomeCount, 0);
    expect(bucket.expenseCount, 0);
  });
}
