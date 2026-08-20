import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';

void main() {
  test('supports only reimbursement orders', () {
    expect(FinanceOrderType.values, [FinanceOrderType.reimbursement]);
    expect(FinanceOrderType.reimbursement.value, 1);
  });

  test('identifies only type 1 as a reimbursement order', () {
    expect(const FortuneFinanceOrderVo(type: 1).isReimbursementOrder, isTrue);
    expect(const FortuneFinanceOrderVo(type: 2).isReimbursementOrder, isFalse);
    expect(const FortuneFinanceOrderVo(type: 3).isReimbursementOrder, isFalse);
    expect(const FortuneFinanceOrderVo().isReimbursementOrder, isFalse);
  });
}
