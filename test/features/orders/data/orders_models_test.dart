import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

void main() {
  test('defines the three fixed finance order types', () {
    expect(FinanceOrderType.values.map((type) => type.value), [1, 2, 3]);
    expect(FinanceOrderType.reimbursement.value, 1);
    expect(FinanceOrderType.receivable.value, 2);
    expect(FinanceOrderType.payable.value, 3);
    expect(FinanceOrderType.fromValue(2), FinanceOrderType.receivable);
    expect(FinanceOrderType.fromValue(99), isNull);
  });

  test('defines all principal bill types and keeps recurring types unchanged', () {
    expect(FxBillType.values.map((type) => type.value), [
      1,
      2,
      3,
      4,
      7,
      8,
      9,
      10,
      11,
      12,
    ]);
    expect(FxBillType.recurringSelectable.map((type) => type.value), [1, 2, 3]);
    expect(FxBillType.selectable.map((type) => type.value), containsAll([
      9,
      10,
      11,
      12,
    ]));
  });

  test('matches backend status and action enums', () {
    expect(FinanceOrderStatus.values.map((status) => status.value), [
      100,
      200,
      1000,
    ]);
    expect(FinanceOrderTransitionAction.using.value, 'using');
    expect(FinanceOrderTransitionAction.close.value, 'close');
    expect(FinanceOrderTransitionAction.reopen.value, 'reopen');
    expect(FinanceOrderEntryAction.confirm.value, 'confirm');
    expect(FinanceOrderEntryAction.unconfirm.value, 'unconfirm');
    expect(FinanceOrderEntryAction.voidEntry.value, 'void');
    expect(FinanceOrderEntryAction.restore.value, 'restore');
  });

  test('parses a complete V2 detail fixture with string amounts', () {
    final detail = FinanceOrderDetail.fromJson(const {
      'orderId': '1001',
      'bookId': 20,
      'title': '张三借款',
      'type': 2,
      'typeDesc': '债权单',
      'status': 200,
      'statusDesc': '进行中',
      'counterpartyId': '31',
      'counterpartyName': '张三',
      'currencyCode': 'CNY',
      'dueDate': '2026-10-07',
      'submitTime': '2026-10-01 09:00:00',
      'closeTime': null,
      'remark': '周转',
      'version': '7',
      'reconciliationStatus': 'READY',
      'reconciliationNote': null,
      'outAmount': '1000.00',
      'inAmount': '400.00',
      'issuedAmount': '1000.00',
      'settledAmount': '400.00',
      'adjustedAmount': '0.00',
      'pendingAmount': '600.00',
      'interestIncome': '20.00',
      'interestExpense': '0.00',
      'feeAmount': '5.00',
      'netCostOrIncome': '15.00',
      'settlementState': 'PARTIAL',
      'pendingEntryCount': 1,
      'overdue': true,
      'canEdit': true,
      'canDelete': false,
      'canClose': false,
      'canReopen': false,
      'allowedEntryActions': ['LOAN_RECOVER', 'INTEREST_IN', 'FEE'],
      'readOnlyReason': null,
    });

    expect(detail.orderId, 1001);
    expect(detail.bookId, 20);
    expect(detail.type, FinanceOrderType.receivable);
    expect(detail.counterpartyId, 31);
    expect(detail.version, 7);
    expect(detail.pendingAmount!.toApiString(), '600.00');
    expect(detail.netCostOrIncome!.toApiString(), '15.00');
    expect(detail.allowedEntryActions, contains('LOAN_RECOVER'));
    expect(detail.overdue, isTrue);
  });

  test('REVIEW_REQUIRED null amounts stay null and invalid amounts fail', () {
    final detail = FinanceOrderDetail.fromJson(const {
      'orderId': 1,
      'bookId': 2,
      'type': 1,
      'version': 0,
      'reconciliationStatus': 'REVIEW_REQUIRED',
      'pendingAmount': null,
      'netCostOrIncome': null,
    });

    expect(detail.pendingAmount, isNull);
    expect(detail.netCostOrIncome, isNull);
    expect(
      () => FinanceOrderDetail.fromJson(const {'orderId': 1, 'outAmount': 'x'}),
      throwsA(isA<FxFailure>()),
    );
  });

  test('parses entry, audit, mutation, summary and reconciliation fixtures', () {
    final entry = FinanceOrderEntry.fromJson(const {
      'billId': '9001',
      'bookId': 20,
      'orderId': 1001,
      'title': '收回本金',
      'tradeTime': '2026-10-02 10:30:00',
      'accountId': 50,
      'accountName': '现金',
      'amount': '400.00',
      'convertedAmount': '400.00',
      'billType': 10,
      'confirm': true,
      'include': false,
      'hasFile': true,
      'categoryAmountPair': <dynamic>[],
      'orderComponent': 'PRINCIPAL',
      'orderLedgerVersion': 1,
      'recycleBin': false,
      'allowedActions': ['EDIT', 'VOID'],
      'readOnlyReason': null,
    });
    expect(entry.amount!.toApiString(), '400.00');
    expect(entry.orderComponent, FinanceOrderComponent.principal);
    expect(entry.orderLedgerVersion, 1);

    final mutation = FinanceOrderMutationResult.fromJson(const {
      'orderId': 1001,
      'billId': 9002,
      'version': 8,
      'replayed': false,
    });
    expect(mutation.orderId, 1001);
    expect(mutation.billId, 9002);

    final summary = FinanceOrderSummary.fromJson(const {
      'currencyCode': 'CNY',
      'receivableAmount': '600.00',
      'payableAmount': '200.00',
      'reimbursementAmount': '0.00',
      'overdueReceivableAmount': '100.00',
      'overduePayableAmount': '0.00',
      'overdueReimbursementAmount': '0.00',
      'receivableCount': 2,
      'payableCount': 1,
      'reimbursementCount': 0,
      'pendingEntryCount': 1,
      'reviewRequiredCount': 0,
      'orphanLegacyBillCount': 0,
      'asOfDate': '2026-10-08',
    });
    expect(summary.receivableAmount!.toApiString(), '600.00');
    expect(summary.reviewRequiredCount, 0);

    final audit = FinanceOrderAudit.fromJson(const {
      'id': 1,
      'orderId': 1001,
      'billId': 9001,
      'action': 'ENTRY_ADD',
      'creatorId': 7,
      'createTime': '2026-10-02 10:30:01',
      'beforeJson': null,
      'afterJson': '{}',
    });
    expect(audit.action, 'ENTRY_ADD');

    final reconciliation = FinanceOrderReconciliation.fromJson(const {
      'orderId': 1001,
      'billId': null,
      'bookId': 20,
      'issueCodes': ['LEGACY_LOAN_ISOLATED'],
      'originalStatus': 200,
      'originalOutAmount': '1000.00',
      'originalInAmount': '400.00',
      'candidateIssuedAmount': null,
      'candidateSettledAmount': null,
      'candidatePendingAmount': null,
      'accountIds': [50],
      'currencyCodes': ['CNY'],
      'cashEffectKnown': false,
      'note': '历史现金效果未知',
    });
    expect(reconciliation.issueCodes, ['LEGACY_LOAN_ISOLATED']);
    expect(reconciliation.candidatePendingAmount, isNull);

    // 多位小数 / 异常 accountIds / list 分页键，不应拖垮整页解析。
    final messy = FinanceOrderReconciliationPage.fromJson({
      'list': [
        {
          'orderId': 1002,
          'issueCodes': 'LEGACY_LOAN_ISOLATED',
          'originalOutAmount': '1000.0000',
          'originalInAmount': {'amount': '400.50'},
          'candidatePendingAmount': 'not-a-money',
          'accountIds': '',
          'currencyCodes': ['CNY'],
        },
      ],
      'total': 1,
    });
    expect(messy.total, 1);
    expect(messy.rows, hasLength(1));
    expect(messy.rows.single.originalOutAmount?.cents, 100000);
    expect(messy.rows.single.originalInAmount?.cents, 40050);
    expect(messy.rows.single.candidatePendingAmount, isNull);
    expect(messy.rows.single.accountIds, isEmpty);
    expect(messy.rows.single.issueCodes, ['LEGACY_LOAN_ISOLATED']);
  });

  test('maps entry components from the fixed whitelist', () {
    expect(
      FinanceOrderComponent.fromValue('PRINCIPAL'),
      FinanceOrderComponent.principal,
    );
    expect(
      FinanceOrderComponent.fromValue('INTEREST'),
      FinanceOrderComponent.interest,
    );
    expect(FinanceOrderComponent.fromValue('FEE'), FinanceOrderComponent.fee);
    expect(
      FinanceOrderComponent.fromValue('WRITE_OFF'),
      FinanceOrderComponent.writeOff,
    );
    expect(FinanceOrderComponent.fromValue('OTHER'), isNull);
  });

  test('legacy bill VO does not default a missing V2 amount to zero', () {
    expect(
      () => FortuneBillVo.fromJson(const {'billId': 1, 'amount': null}),
      throwsA(isA<FxFailure>()),
    );
  });
}
