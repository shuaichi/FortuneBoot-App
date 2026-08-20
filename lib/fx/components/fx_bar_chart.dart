import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/fx/components/fx_chart_palette.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class FxBarItem {
  final String name;
  final double value;
  final Color? color;

  const FxBarItem({required this.name, required this.value, this.color});
}

/// Shared ranked bar chart for tags, rankings, accounts and member summaries.
class FxBarChart extends StatelessWidget {
  final List<FxBarItem> items;
  final double height;
  final double barWidth;
  final int topN;
  final String unnamedLabel;
  final String Function(double value)? valueFormatter;
  final FxAmountVisibility visibility;
  final String? locale;

  const FxBarChart({
    super.key,
    required this.items,
    this.height = 220,
    this.barWidth = 14,
    this.topN = 10,
    this.unnamedLabel = '未命名',
    this.valueFormatter,
    this.visibility = FxAmountVisibility.visible,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final positive = items.where((item) => item.value > 0).take(topN).toList();
    if (positive.isEmpty) return const SizedBox.shrink();
    final maxV = positive.fold<double>(0, (m, e) => e.value > m ? e.value : m);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxV <= 0 ? 1 : maxV * 1.15,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxV <= 0 ? 1 : maxV / 3,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: palette.border, strokeWidth: 1),
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
                  if (i < 0 || i >= positive.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SizedBox(
                      width: 48,
                      child: Text(
                        positive[i].name.isEmpty
                            ? unnamedLabel
                            : positive[i].name,
                        style: FxTypography.caption.copyWith(
                          color: palette.textTertiary,
                        ),
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
              getTooltipColor: (_) => palette.textPrimary,
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                _formatValue(rod.toY),
                FxTypography.caption.copyWith(color: palette.surface),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < positive.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: positive[i].value,
                    color: positive[i].color ?? FxChartPalette.colorAt(i),
                    width: barWidth,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (visibility == FxAmountVisibility.hidden) {
      return FxMoneyFormatter.hiddenPlaceholder;
    }
    return valueFormatter?.call(value) ??
        FxMoneyFormatter.format(value, locale: locale, decimalDigits: 2);
  }
}
