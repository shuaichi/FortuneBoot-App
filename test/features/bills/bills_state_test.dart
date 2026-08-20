import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';

void main() {
  group('BillsState', () {
    test('uses the first visible month statistics for the summary bar', () {
      final visibleMonth = DateTime(2026, 5);
      final state = BillsState(
        status: BillsStatus.loaded,
        month: DateTime(2026, 8),
        statistics: const BillStatistics(expense: 0, income: 0, surplus: 0),
        monthStatistics: {
          visibleMonth: const BillStatistics(
            expense: 123,
            income: 0,
            surplus: -123,
          ),
        },
        bills: [
          FortuneBillVo(
            billId: 1,
            tradeTime: DateTime(2026, 5, 19, 21, 14),
            amount: 123,
            billType: FxBillType.expense.value,
          ),
        ],
      );

      final summary = state.summaryForAnchor(visibleMonth, 1);

      expect(summary.expense, 123);
      expect(summary.income, 0);
      expect(summary.surplus, -123);
    });

    test('falls back when the visible anchor has no month statistics', () {
      final visibleMonth = DateTime(2026, 5);
      final state = BillsState(
        status: BillsStatus.loaded,
        month: DateTime(2026, 8),
        statistics: const BillStatistics(expense: 12, income: 34, surplus: 22),
        monthStatistics: {
          DateTime(2026, 4): const BillStatistics(
            expense: 400,
            income: 0,
            surplus: -400,
          ),
        },
        bills: [
          FortuneBillVo(billId: 1, tradeTime: DateTime(2026, 5, 24)),
          FortuneBillVo(billId: 2, tradeTime: DateTime(2026, 4, 24)),
        ],
      );

      final summary = state.summaryForAnchor(visibleMonth, 1);

      expect(summary.expense, 12);
      expect(summary.income, 34);
      expect(summary.surplus, 22);
    });

    test(
      'falls back to current window statistics when no month group is visible',
      () {
        final visibleMonth = DateTime(2026, 5);
        final state = BillsState(
          status: BillsStatus.loaded,
          month: DateTime(2026, 8),
          statistics: const BillStatistics(
            expense: 12,
            income: 34,
            surplus: 22,
          ),
        );

        final summary = state.summaryForAnchor(visibleMonth, 1);

        expect(summary.expense, 12);
        expect(summary.income, 34);
        expect(summary.surplus, 22);
      },
    );
  });
}
