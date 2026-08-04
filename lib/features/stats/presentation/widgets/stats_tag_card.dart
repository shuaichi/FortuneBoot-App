import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_palette.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

/// ③ 标签柱图：横向柱状，Top N（默认 10）。
class StatsTagCard extends StatelessWidget {
  final StatsSection<List<BarItem>> section;
  final VoidCallback onRetry;

  static const int _topN = 10;

  const StatsTagCard({super.key, required this.section, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StatsCardShell<List<BarItem>>(
      label: '标签',
      section: section,
      onRetry: onRetry,
      height: 260,
      builder: (items) {
        final positive = items.where((e) => e.value > 0).take(_topN).toList();
        if (positive.isEmpty) {
          return const Center(
            child: Text('本期暂无记录', style: FxTypography.caption),
          );
        }
        return _Bars(items: positive);
      },
    );
  }
}

/// 横向柱状：用竖向 BarChart + rotateAngle 分类名，简单稳妥。
class _Bars extends StatelessWidget {
  final List<BarItem> items;
  const _Bars({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxV = items.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxV <= 0 ? 1 : maxV * 1.15,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxV <= 0 ? 1 : maxV / 3,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: FxColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= items.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: 48,
                    child: Text(
                      items[i].name.isEmpty ? '未命名' : items[i].name,
                      style: FxTypography.caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => FxColors.textPrimary,
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              NumberFormat('#,##0.##').format(rod.toY),
              FxTypography.caption.copyWith(color: FxColors.surface),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < items.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: items[i].value,
                  color: StatsPalette.colorAt(i),
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
