import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_line_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
            FxCardLabel(S.of(context).dashboardExpenseTrend),
            const SizedBox(height: FxSpacing.sm),
            Expanded(
              child: points.length < 2
                  ? Center(
                      child: Text(
                        S.of(context).dashboardInsufficientData,
                        style: FxTypography.caption.copyWith(
                          color: FxPalette.of(context).textTertiary,
                        ),
                      ),
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
    final palette = FxPalette.of(context);
    return FxLineChart(
      height: 120,
      showAxes: false,
      series: [
        FxLineSeries(
          points: [
            for (final point in points)
              FxLinePoint(name: point.name, value: point.value),
          ],
          color: palette.primary,
          label: S.of(context).dashboardExpenseTrend,
        ),
      ],
    );
  }
}
