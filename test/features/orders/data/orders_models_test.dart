import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';

void main() {
  test('supports only reimbursement orders', () {
    expect(FinanceOrderType.values, [FinanceOrderType.reimbursement]);
    expect(FinanceOrderType.reimbursement.value, 1);
  });

  test('matches backend status enum values', () {
    expect(FinanceOrderStatus.init.value, 100);
    expect(FinanceOrderStatus.using.value, 200);
    expect(FinanceOrderStatus.closed.value, 1000);
  });

  test('matches backend transition action paths', () {
    expect(FinanceOrderTransitionAction.using.value, 'using');
    expect(FinanceOrderTransitionAction.close.value, 'close');
    expect(FinanceOrderTransitionAction.reopen.value, 'reopen');
  });

  test('identifies only type 1 as a reimbursement order', () {
    expect(const FortuneFinanceOrderVo(type: 1).isReimbursementOrder, isTrue);
    expect(const FortuneFinanceOrderVo(type: 2).isReimbursementOrder, isFalse);
    expect(const FortuneFinanceOrderVo(type: 3).isReimbursementOrder, isFalse);
    expect(const FortuneFinanceOrderVo().isReimbursementOrder, isFalse);
  });

  test('identifies order states from backend status values', () {
    expect(const FortuneFinanceOrderVo(status: 100).isInitial, isTrue);
    expect(const FortuneFinanceOrderVo(status: 200).isUsing, isTrue);
    expect(const FortuneFinanceOrderVo(status: 1000).isClosed, isTrue);

    expect(const FortuneFinanceOrderVo(status: 100).isUsing, isFalse);
    expect(const FortuneFinanceOrderVo(status: 200).isInitial, isFalse);
    expect(const FortuneFinanceOrderVo(status: 1000).isUsing, isFalse);
  });

  test('maps order states to next transition actions', () {
    expect(
      const FortuneFinanceOrderVo(status: 100).nextTransitionAction,
      FinanceOrderTransitionAction.using,
    );
    expect(
      const FortuneFinanceOrderVo(status: 200).nextTransitionAction,
      FinanceOrderTransitionAction.close,
    );
    expect(
      const FortuneFinanceOrderVo(status: 1000).nextTransitionAction,
      FinanceOrderTransitionAction.reopen,
    );
    expect(
      const FortuneFinanceOrderVo(status: 999).nextTransitionAction,
      isNull,
    );
  });
}
