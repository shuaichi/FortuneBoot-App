import 'package:flutter/material.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_ledger_row.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/currency_symbol.dart';

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
    final metadata = _metadata(context);
    final status = <String>[
      if (order.overdue) S.of(context).ordersOverdue,
      if (order.settlementState == 'PARTIAL')
        S.of(context).ordersPartiallySettled,
      if (order.settlementState == 'SETTLED') S.of(context).ordersSettledTag,
      if (order.pendingEntryCount > 0)
        S.of(context).ordersPendingEntryCount(order.pendingEntryCount),
      if (order.isReviewRequired) S.of(context).ordersReviewRequired,
    ];
    final detailChildren = <Widget>[
      if (metadata.isNotEmpty)
        Text(
          metadata,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).textSecondary,
          ),
        ),
      if (status.isNotEmpty) ...[
        if (metadata.isNotEmpty) const SizedBox(height: FxSpacing.xs),
        Text(
          status.join(' · '),
          style: FxTypography.caption.copyWith(
            color: order.overdue
                ? FxPalette.of(context).danger
                : FxPalette.of(context).textSecondary,
          ),
        ),
      ],
      if (onReport != null) ...[
        if (metadata.isNotEmpty || status.isNotEmpty)
          const SizedBox(height: FxSpacing.xs),
        InkWell(
          onTap: onReport,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FxSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).ordersViewReconciliation,
                  style: FxTypography.label.copyWith(
                    color: FxPalette.of(context).primary,
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: FxPalette.of(context).primary,
                ),
              ],
            ),
          ),
        ),
      ],
    ];
    return FxLedgerRow(
      title: _displayTitle(context),
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
      details: detailChildren.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detailChildren,
            ),
    );
  }

  String _displayTitle(BuildContext context) {
    final counterparty = order.counterpartyName?.trim();
    if (counterparty?.isNotEmpty == true) return counterparty!;
    final title = order.title?.trim();
    if (title?.isNotEmpty == true) return title!;
    return switch (order.type) {
      FinanceOrderType.receivable => '未命名${S.of(context).ordersTypeReceivable}',
      FinanceOrderType.payable => '未命名${S.of(context).ordersTypePayable}',
      FinanceOrderType.reimbursement ||
      null => S.of(context).ordersUnnamedOrder,
    };
  }

  String _metadata(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final parts = <String>[
      if (order.title?.trim().isNotEmpty == true &&
          order.title!.trim() != _displayTitle(context))
        order.title!.trim(),
      if (order.issuedAmount case final issued?)
        '${_issuedLabel(context)} ${_money(context, issued.cents, locale)}',
      if (order.settledAmount case final settled?)
        '${_settledLabel(context)} ${_money(context, settled.cents, locale)}',
    ];
    return parts.join(' · ');
  }

  String _money(BuildContext context, int cents, String locale) =>
      FxMoneyFormatter.format(
        cents / 100,
        locale: locale,
        currencySymbol: getCurrencySymbol(
          order.currencyCode ?? currencyCode ?? '',
        ),
        visibility: hideAmounts
            ? FxAmountVisibility.hidden
            : FxAmountVisibility.visible,
      );

  String _pendingLabel(BuildContext context) => switch (order.type) {
    FinanceOrderType.receivable => S.of(context).ordersPendingReceivable,
    FinanceOrderType.payable => S.of(context).ordersPendingPayable,
    FinanceOrderType.reimbursement => S.of(context).ordersPendingReimbursement,
    null => S.of(context).ordersPendingReceivable,
  };

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
