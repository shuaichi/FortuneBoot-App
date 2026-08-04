import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ⑤ 资产负债环形图（资产 vs 负债），中心标净资产，点击跳账户页。
class AssetsDonutCard extends StatelessWidget {
  final DashboardSection<AssetsLiabilities> section;
  final String? currencyCode;
  final VoidCallback onRetry;

  const AssetsDonutCard({
    super.key,
    required this.section,
    required this.currencyCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCardShell<AssetsLiabilities>(
      section: section,
      onRetry: onRetry,
      onTap: () => AppRouter.push<void>(context, Routes.accounts),
      builder: (data) {
        final hasData = data.totalAssets > 0 || data.totalLiabilities > 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxCardLabel(S.of(context).dashboardAssetsLiabilities),
            const SizedBox(height: FxSpacing.sm),
            Expanded(
              child: hasData
                  ? _Donut(data: data, currencyCode: currencyCode)
                  : Center(
                      child: Text(
                        S.of(context).dashboardNoData,
                        style: FxTypography.caption.copyWith(
                          color: FxPalette.of(context).textTertiary,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Donut extends StatelessWidget {
  final AssetsLiabilities data;
  final String? currencyCode;
  const _Donut({required this.data, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: 26,
              sections: [
                PieChartSectionData(
                  value: data.totalAssets <= 0 ? 0.001 : data.totalAssets,
                  color: finance.income,
                  radius: 14,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: data.totalLiabilities <= 0
                      ? 0.001
                      : data.totalLiabilities,
                  color: finance.expense,
                  radius: 14,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: FxSpacing.lg),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).dashboardNetWorth,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              FxMoneyText(
                amount: data.netAssets,
                currencyCode: currencyCode,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
                masked: hideAmounts,
              ),
              const SizedBox(height: FxSpacing.md),
              _legendRow(
                color: finance.income,
                label: S.of(context).dashboardAssets,
                amount: data.totalAssets,
                hideAmounts: hideAmounts,
              ),
              const SizedBox(height: FxSpacing.sm),
              _legendRow(
                color: finance.expense,
                label: S.of(context).dashboardLiabilities,
                amount: data.totalLiabilities,
                hideAmounts: hideAmounts,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow({
    required Color color,
    required String label,
    required double amount,
    required bool hideAmounts,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: FxSpacing.sm),
        Text(label, style: FxTypography.caption.copyWith(color: color)),
        const SizedBox(width: FxSpacing.md),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              masked: hideAmounts,
            ),
          ),
        ),
      ],
    );
  }
}
