import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_ledger_row.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据列表卡片。主金额始终使用服务端 pendingAmount。
class OrderCard extends StatelessWidget {
  final FinanceOrderDetail order;
  final String? currencyCode;
  final bool hideAmounts;
  final VoidCallback? onTap;
  final VoidCallback? onReport;

  const OrderCard({
    super.key,
    required this.order,
    required this.currencyCode,
    required this.hideAmounts,
    this.onTap,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = order.title?.isNotEmpty == true ? order.title : null;
    return FxLedgerRow(
      title: order.counterpartyName ?? order.title ?? '',
      subtitle: metadata,
      onTap: onTap,
      amount: order.pendingAmount == null
          ? Text(hideAmounts ? '****' : '-', style: FxTypography.bodyStrong)
          : FxMoneyText(
              amount: order.pendingAmount!.cents / 100,
              currencyCode: order.currencyCode ?? currencyCode,
              fontSize: 18,
              masked: hideAmounts,
              compactWhenNeeded: true,
            ),
      amountCaption: _pendingLabel(context),
      details: Wrap(
        spacing: FxSpacing.sm,
        runSpacing: FxSpacing.xs,
        children: [
          if (order.issuedAmount != null)
            _moneyChip(
              context,
              label: _issuedLabel(context),
              amount: order.issuedAmount?.cents,
            ),
          if (order.settledAmount != null)
            _moneyChip(
              context,
              label: _settledLabel(context),
              amount: order.settledAmount?.cents,
            ),
          if (order.overdue) _tag(S.of(context).ordersOverdue),
          if (order.settlementState == 'PARTIAL')
            _tag(S.of(context).ordersPartiallySettled),
          if (order.settlementState == 'SETTLED')
            _tag(S.of(context).ordersSettledTag),
          if (order.pendingEntryCount > 0)
            _tag(
              S.of(context).ordersPendingEntryCount(order.pendingEntryCount),
            ),
          if (order.isReviewRequired)
            _tag(S.of(context).ordersReviewRequired, onTap: onTap),
          if (onReport != null)
            _tag(S.of(context).ordersViewReconciliation, onTap: onReport),
        ],
      ),
    );
  }

  String _pendingLabel(BuildContext context) => switch (order.type) {
    FinanceOrderType.receivable => S.of(context).ordersPendingReceivable,
    FinanceOrderType.payable => S.of(context).ordersPendingPayable,
    FinanceOrderType.reimbursement => S.of(context).ordersPendingReimbursement,
    null => S.of(context).ordersPendingReceivable,
  };

  Widget _moneyChip(
    BuildContext context, {
    required String label,
    required int? amount,
  }) {
    if (amount == null) return const SizedBox.shrink();
    return _tag('$label ${(amount / 100).toStringAsFixed(2)}');
  }

  /// 无 [onTap] 的状态标签不拦截手势，点到标签仍落到卡片打开详情。
  Widget _tag(String label, {VoidCallback? onTap}) {
    final chip = FxChip(
      label: label,
      selected: false,
      isAction: onTap != null,
      onTap: onTap ?? () {},
    );
    if (onTap != null) return chip;
    return IgnorePointer(child: chip);
  }

  String _issuedLabel(BuildContext context) => switch (order.type) {
    FinanceOrderType.receivable => S.of(context).ordersIssuedLoanOut,
    FinanceOrderType.payable => S.of(context).ordersIssuedLoanIn,
    FinanceOrderType.reimbursement => S.of(context).ordersIssuedAdvance,
    null => '',
  };

  String _settledLabel(BuildContext context) => switch (order.type) {
    FinanceOrderType.receivable => S.of(context).ordersSettledRecovered,
    FinanceOrderType.payable => S.of(context).ordersSettledRepaid,
    FinanceOrderType.reimbursement => S.of(context).ordersSettledReimbursed,
    null => '',
  };
}
