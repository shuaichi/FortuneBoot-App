import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ② 本账期支出 / ③ 本账期收入（各 1 格）。支出红、收入绿。
class MonthStatCard extends StatelessWidget {
  final DashboardSection<BillStatistics> section;
  final String? currencyCode;
  final bool isExpense;
  final VoidCallback onRetry;

  const MonthStatCard({
    super.key,
    required this.section,
    required this.currencyCode,
    required this.isExpense,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final label = isExpense
        ? S.of(context).dashboardPeriodExpense
        : S.of(context).dashboardPeriodIncome;
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    final color = isExpense ? finance.expense : finance.income;
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    final icon = isExpense
        ? Icons.trending_down_rounded
        : Icons.trending_up_rounded;

    return DashboardCardShell<BillStatistics>(
      section: section,
      onRetry: onRetry,
      builder: (data) {
        final amount = isExpense ? data.expense : data.income;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxCardLabel(label, trailing: Icon(icon, size: 16, color: color)),
            FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
              masked: hideAmounts,
              compactWhenNeeded: true,
            ),
            const SizedBox(height: FxSpacing.xs),
          ],
        );
      },
    );
  }
}
