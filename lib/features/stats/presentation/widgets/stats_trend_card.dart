import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

/// ① 收支趋势折线：X 时间，Y 金额。支出红线 / 收入绿线（按当前类型）。
class StatsTrendCard extends StatelessWidget {
  final StatsSection<List<TrendPoint>> section;
  final StatsType type;
  final VoidCallback onRetry;

  const StatsTrendCard({
    super.key,
    required this.section,
    required this.type,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StatsCardShell<List<TrendPoint>>(
      label: type == StatsType.expense ? '支出趋势' : '收入趋势',
      section: section,
      onRetry: onRetry,
      builder: (points) {
        if (points.isEmpty) {
          return const _EmptyAxis();
        }
        final finance = FxFinanceColors.of(context);
        return _Line(
          points: points,
          color: type == StatsType.expense ? finance.expense : finance.income,
        );
      },
    );
  }
}

/// 空态：显示空轴 + "本期暂无记录"。
class _EmptyAxis extends StatelessWidget {
  const _EmptyAxis();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('本期暂无记录', style: FxTypography.caption));
  }
}

class _Line extends StatelessWidget {
  final List<TrendPoint> points;
  final Color color;

  const _Line({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final maxY = points.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    // X 轴仅标注首/中/末，避免拥挤。
    final labelIdx = <int>{0, points.length ~/ 2, points.length - 1};

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 1 : maxY * 1.2,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY <= 0 ? 1 : maxY / 3,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: palette.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) {
                  return const SizedBox.shrink();
                }
                return Text(_compact(value), style: FxTypography.caption);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (!labelIdx.contains(i) || i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _shortLabel(points[i].name),
                    style: FxTypography.caption,
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => palette.textPrimary,
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    NumberFormat('#,##0.##').format(s.y),
                    FxTypography.caption.copyWith(color: palette.surface),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(show: points.length <= 12),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  /// 金额紧凑显示：1234 → 1.2k。
  static String _compact(double v) {
    if (v.abs() >= 10000) return '${(v / 10000).toStringAsFixed(1)}w';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  /// 日期标签取尾段（yyyy-MM-dd → dd；yyyy-MM → MM）。
  static String _shortLabel(String name) {
    final parts = name.split('-');
    if (parts.length >= 3) return parts[2];
    if (parts.length == 2) return '${parts[1]}月';
    return name;
  }
}
