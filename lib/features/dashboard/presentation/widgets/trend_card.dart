import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// ④ 收支趋势迷你折线（本月每日支出）。无坐标轴，点击跳统计页。
class TrendCard extends StatelessWidget {
  final DashboardSection<List<TrendPoint>> section;
  final VoidCallback onRetry;

  const TrendCard({super.key, required this.section, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return DashboardCardShell<List<TrendPoint>>(
      section: section,
      onRetry: onRetry,
      onTap: () => AppRouter.push<void>(context, Routes.stats),
      builder: (points) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FxCardLabel('支出趋势'),
            const SizedBox(height: FxSpacing.sm),
            Expanded(
              child: points.length < 2
                  ? const Center(
                      child: Text('数据不足', style: FxTypography.caption),
                    )
                  : _MiniLine(points: points),
            ),
          ],
        );
      },
    );
  }
}

class _MiniLine extends StatelessWidget {
  final List<TrendPoint> points;
  const _MiniLine({required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: FxColors.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: FxColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
