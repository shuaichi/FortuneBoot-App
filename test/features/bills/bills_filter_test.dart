import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

void main() {
  group('BillsFilter', () {
    test(
      'counts every visible condition and keeps copied collections immutable',
      () {
        final billTypes = <int>{1, 2};
        final categoryIds = <int>[11];
        final filter = BillsFilter(
          billTypes: billTypes,
          amountMin: 1,
          confirm: false,
          include: false,
          categoryIds: categoryIds,
          tagIds: const [22],
          accountId: 33,
          payeeId: 44,
          dateRange: BillDateRange(
            start: DateTime(2026, 8, 1, 12),
            end: DateTime(2026, 8, 2, 12),
          ),
        );

        billTypes.clear();
        categoryIds.clear();

        expect(filter.activeCount, 9);
        expect(filter.billTypes, {1, 2});
        expect(filter.categoryIds, [11]);
      },
    );

    test('can clear nullable fields without retaining stale filters', () {
      final initial = BillsFilter(
        amountMin: 1,
        amountMax: 2,
        confirm: true,
        include: true,
        categoryIds: const [1],
        tagIds: const [2],
        accountId: 3,
        payeeId: 4,
        dateRange: BillDateRange(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 2),
        ),
      );

      final cleared = initial.copyWith(
        clearAmountMin: true,
        clearAmountMax: true,
        clearConfirm: true,
        clearInclude: true,
        clearCategoryIds: true,
        clearTagIds: true,
        clearAccountId: true,
        clearPayeeId: true,
        clearDateRange: true,
      );

      expect(cleared, BillsFilter.empty);
    });

    test('normalizes the public date range to inclusive day boundaries', () {
      final range = BillDateRange(
        start: DateTime(2026, 8, 1, 22, 30),
        end: DateTime(2026, 8, 2, 1),
      );

      expect(range.start, DateTime(2026, 8, 1));
      expect(range.end, DateTime(2026, 8, 2, 23, 59, 59, 999, 999));
      expect(range.startDate, '2026-08-01');
      expect(range.endDate, '2026-08-02');
    });
  });
}
