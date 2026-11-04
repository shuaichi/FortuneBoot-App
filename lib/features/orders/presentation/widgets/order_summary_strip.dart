import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 全账本三项余额摘要。金额来自 V2 summary，不根据当前 20 行累加。
class OrderSummaryStrip extends StatelessWidget {
  final FinanceOrderSummary? summary;
  final String? currencyCode;
  final bool hideAmounts;

  const OrderSummaryStrip({
    super.key,
    required this.summary,
    required this.currencyCode,
    this.hideAmounts = false,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: _metric(
              context,
              label: S.of(context).ordersPendingReceivable,
              amount: summary?.receivableAmount?.cents,
              count: summary?.receivableCount ?? 0,
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: _metric(
              context,
              label: S.of(context).ordersPendingPayable,
              amount: summary?.payableAmount?.cents,
              count: summary?.payableCount ?? 0,
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: _metric(
              context,
              label: S.of(context).ordersPendingReimbursement,
              amount: summary?.reimbursementAmount?.cents,
              count: summary?.reimbursementCount ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context, {
    required String label,
    required int? amount,
    required int count,
  }) {
    return Semantics(
      label: '$label ${amount == null ? '-' : (amount / 100).toString()}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: FxSpacing.xs),
          if (amount == null)
            Text(
              hideAmounts ? '****' : '-',
              style: FxTypography.money.copyWith(fontSize: 18),
            )
          else
            FxMoneyText(
              amount: amount / 100,
              currencyCode: currencyCode,
              masked: hideAmounts,
              compactWhenNeeded: true,
            ),
          Text(
            S.of(context).ordersMetricCount(count),
            style: FxTypography.caption,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
