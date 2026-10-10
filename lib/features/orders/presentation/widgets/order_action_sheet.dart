import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_action_sheet.dart';

enum FinanceOrderEntryActionKind {
  advance('ADVANCE', 7),
  reimburse('REIMBURSE', 8),
  loanOut('LOAN_OUT', 9),
  loanRecover('LOAN_RECOVER', 10),
  loanIn('LOAN_IN', 11),
  loanRepay('LOAN_REPAY', 12),
  interestIn('INTEREST_IN', 2),
  interestOut('INTEREST_OUT', 1),
  fee('FEE', 1);

  const FinanceOrderEntryActionKind(this.code, this.billType);

  final String code;
  final int billType;
}

/// 根据 allowedEntryActions 构造入口。客户端不自行推断越权动作。
class OrderActionSheet {
  const OrderActionSheet._();

  static List<FinanceOrderEntryActionKind> actions(FinanceOrderDetail detail) {
    return FinanceOrderEntryActionKind.values
        .where((action) => detail.allowedEntryActions.contains(action.code))
        .toList();
  }

  static void show(
    BuildContext context,
    FinanceOrderDetail detail,
    ValueChanged<FinanceOrderEntryActionKind> onSelect,
  ) {
    final actions = OrderActionSheet.actions(detail);
    FxActionSheet.show(
      context,
      title: '记一笔',
      actions: [
        for (final action in actions)
          FxSheetAction(label: action.code, onPressed: () => onSelect(action)),
      ],
    );
  }
}
