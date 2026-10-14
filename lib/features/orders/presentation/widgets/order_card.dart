import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
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
    final palette = FxPalette.of(context);
    return FxCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.counterpartyName ?? order.title ?? '',
                  style: FxTypography.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              if (order.pendingAmount == null)
                Text(
                  hideAmounts ? '****' : '-',
                  style: FxTypography.money.copyWith(fontSize: 28),
                )
              else
                FxMoneyText(
                  amount: order.pendingAmount!.cents / 100,
                  currencyCode: order.currencyCode ?? currencyCode,
                  fontSize: 28,
                  masked: hideAmounts,
                ),
            ],
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            order.title ?? '',
            style: FxTypography.body.copyWith(color: palette.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: FxSpacing.sm),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.xs,
            children: [
              _moneyChip(
                context,
                label: _issuedLabel(context),
                amount: order.issuedAmount?.cents,
              ),
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
                  S
                      .of(context)
                      .ordersPendingEntryCount(order.pendingEntryCount),
                ),
              if (order.isReviewRequired)
                _tag(S.of(context).ordersReviewRequired),
              if (onReport != null)
                _tag(S.of(context).ordersViewReconciliation, onTap: onReport),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moneyChip(
    BuildContext context, {
    required String label,
    required int? amount,
  }) {
    if (amount == null) return const SizedBox.shrink();
    return _tag('$label ${(amount / 100).toStringAsFixed(2)}');
  }

  Widget _tag(String label, {VoidCallback? onTap}) => FxChip(
    label: label,
    selected: false,
    isAction: true,
    onTap: onTap ?? () {},
  );

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
