import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 概览条：支出 / 收入 / 结余。无数据时显示 0（getBillStatistics）。
class StatsOverviewBar extends StatelessWidget {
  final StatsSection<BillStatistics> section;
  final String? currencyCode;

  const StatsOverviewBar({
    super.key,
    required this.section,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final data = section.isReady ? section.data! : const BillStatistics();
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return FxCard(
      child: Row(
        children: [
          _cell(context, S.of(context).statsExpense, data.expense, finance.expense),
          _divider(palette),
          _cell(context, S.of(context).statsIncome, data.income, finance.income),
          _divider(palette),
          _cell(
            context,
            S.of(context).statsSurplus,
            data.surplus,
            palette.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
          ),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(
            amount: amount,
            currencyCode: currencyCode,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _divider(FxPalette palette) => Container(
    width: 1,
    height: 28,
    color: palette.border,
    margin: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
  );
}
