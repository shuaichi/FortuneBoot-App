import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

class FxLinePoint {
  final String name;
  final double value;

  const FxLinePoint({required this.name, required this.value});
}

class FxLineSeries {
  final List<FxLinePoint> points;
  final Color color;
  final String? label;

  const FxLineSeries({required this.points, required this.color, this.label});
}

/// Shared line chart for single or multiple financial trend series.
class FxLineChart extends StatelessWidget {
  final List<FxLineSeries> series;
  final double height;
  final bool showDots;
  final bool showArea;
  final bool showAxes;
  final bool curved;
  final String Function(String name)? labelBuilder;
  final String Function(double value)? valueFormatter;

  const FxLineChart({
    super.key,
    required this.series,
    this.height = 180,
    this.showDots = false,
    this.showArea = true,
    this.showAxes = true,
    this.curved = true,
    this.labelBuilder,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final points = series.expand((s) => s.points).toList();
    final maxY = points.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    final maxLen = series.fold<int>(
      0,
      (m, s) => s.points.length > m ? s.points.length : m,
    );
    final labelIdx = <int>{
      if (maxLen > 0) 0,
      if (maxLen > 2) maxLen ~/ 2,
      if (maxLen > 1) maxLen - 1,
    };

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(
            show: showAxes,
            drawVerticalLine: false,
            horizontalInterval: maxY <= 0 ? 1 : maxY / 3,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: palette.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: showAxes
              ? _titles(palette, labelIdx, maxLen)
              : const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => palette.textPrimary,
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      _formatValue(spot.y),
                      FxTypography.caption.copyWith(color: palette.surface),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            for (final s in series)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < s.points.length; i++)
                    FlSpot(i.toDouble(), s.points[i].value),
                ],
                isCurved: curved,
                preventCurveOverShooting: true,
                color: s.color,
                barWidth: 2.5,
                dotData: FlDotData(show: showDots || s.points.length <= 12),
                belowBarData: BarAreaData(
                  show: showArea,
                  color: s.color.withValues(alpha: 0.12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _titles(FxPalette palette, Set<int> labelIdx, int maxLen) {
    final names = series.isEmpty ? const <FxLinePoint>[] : series.first.points;
    return FlTitlesData(
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
            return Text(
              _compact(value),
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final i = value.round();
            if (!labelIdx.contains(i) ||
                i < 0 ||
                i >= maxLen ||
                i >= names.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                labelBuilder?.call(names[i].name) ?? _shortLabel(names[i].name),
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatValue(double value) =>
      valueFormatter?.call(value) ?? NumberFormat('#,##0.##').format(value);

  static String _compact(double v) {
    if (v.abs() >= 10000) return '${(v / 10000).toStringAsFixed(1)}w';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  static String _shortLabel(String name) {
    final parts = name.split('-');
    if (parts.length >= 3) return parts[2];
    if (parts.length == 2) return '${parts[1]}月';
    return name;
  }
}
