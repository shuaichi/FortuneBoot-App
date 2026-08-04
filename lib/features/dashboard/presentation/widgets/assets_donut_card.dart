import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
            const FxCardLabel('资产负债'),
            const SizedBox(height: FxSpacing.sm),
            Expanded(
              child: hasData
                  ? _Donut(data: data, currencyCode: currencyCode)
                  : const Center(
                      child: Text('暂无数据', style: FxTypography.caption),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 2,
            centerSpaceRadius: 28,
            sections: [
              PieChartSectionData(
                value: data.totalAssets <= 0 ? 0.001 : data.totalAssets,
                color: FxColors.income,
                radius: 12,
                showTitle: false,
              ),
              PieChartSectionData(
                value: data.totalLiabilities <= 0
                    ? 0.001
                    : data.totalLiabilities,
                color: FxColors.expense,
                radius: 12,
                showTitle: false,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('净资产', style: FxTypography.caption),
            FxMoneyText(
              amount: data.netAssets,
              currencyCode: currencyCode,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: FxColors.textPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
