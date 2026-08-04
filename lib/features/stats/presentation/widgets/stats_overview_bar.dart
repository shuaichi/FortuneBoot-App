import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
    return FxCard(
      child: Row(
        children: [
          _cell('支出', data.expense, FxColors.expense),
          _divider(),
          _cell('收入', data.income, FxColors.income),
          _divider(),
          _cell('结余', data.surplus, FxColors.textPrimary),
        ],
      ),
    );
  }

  Widget _cell(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: FxTypography.caption),
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

  Widget _divider() => Container(
    width: 1,
    height: 28,
    color: FxColors.border,
    margin: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
  );
}
