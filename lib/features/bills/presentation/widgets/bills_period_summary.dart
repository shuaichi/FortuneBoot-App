import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 当前账期与历史账期共用的汇总表面。
class BillsPeriodSummary extends StatelessWidget {
  const BillsPeriodSummary({
    super.key,
    required this.statistics,
    required this.masked,
  });

  final BillStatistics statistics;
  final bool masked;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Container(
      key: const ValueKey('bills-period-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: FxRadius.cardBorder,
        border: Border.all(color: palette.border, width: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 280 || textScale > 1.3;
          if (stacked) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stackedItem(
                  context,
                  S.of(context).billsExpense,
                  statistics.expense,
                ),
                const SizedBox(height: FxSpacing.md),
                _stackedItem(
                  context,
                  S.of(context).billsIncome,
                  statistics.income,
                ),
                const SizedBox(height: FxSpacing.md),
                _stackedItem(
                  context,
                  S.of(context).billsBalance,
                  statistics.surplus,
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _item(context, S.of(context).billsExpense, statistics.expense),
              _divider(context),
              _item(context, S.of(context).billsIncome, statistics.income),
              _divider(context),
              _item(context, S.of(context).billsBalance, statistics.surplus),
            ],
          );
        },
      ),
    );
  }

  Widget _item(BuildContext context, String label, double amount) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(amount: amount, masked: masked),
        ],
      ),
    );
  }

  Widget _stackedItem(BuildContext context, String label, double amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ),
        const SizedBox(width: FxSpacing.md),
        Flexible(
          flex: 2,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FxMoneyText(amount: amount, masked: masked),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
    width: 0.5,
    height: 44,
    margin: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
    color: FxPalette.of(context).separator,
  );
}
