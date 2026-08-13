import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class FxHeatmapDay {
  final DateTime date;
  final double amount;
  final int count;

  const FxHeatmapDay({
    required this.date,
    required this.amount,
    required this.count,
  });
}

/// Lightweight calendar heatmap built from regular Flutter widgets.
class FxHeatmapGrid extends StatelessWidget {
  final List<FxHeatmapDay> days;
  final Color color;
  final ValueChanged<FxHeatmapDay>? onDayTap;
  final int columns;
  final double cellSize;
  final double cellGap;
  final String Function(DateTime date)? monthLabelBuilder;
  final String lowLabel;
  final String highLabel;

  const FxHeatmapGrid({
    super.key,
    required this.days,
    required this.color,
    this.onDayTap,
    this.columns = 7,
    this.cellSize = 14,
    this.cellGap = 3,
    this.monthLabelBuilder,
    this.lowLabel = 'Low',
    this.highLabel = 'High',
  });

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByMonth(days);
    if (grouped.isEmpty) return const SizedBox.shrink();
    final maxAmount = days.fold<double>(
      0,
      (max, day) => day.amount > max ? day.amount : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          _MonthGrid(
            month: entry.key,
            days: entry.value,
            color: color,
            maxAmount: maxAmount,
            onDayTap: onDayTap,
            columns: columns,
            cellSize: cellSize,
            cellGap: cellGap,
            labelBuilder: monthLabelBuilder,
          ),
          const SizedBox(height: FxSpacing.md),
        ],
        _Legend(color: color, lowLabel: lowLabel, highLabel: highLabel),
      ],
    );
  }

  static Map<DateTime, List<FxHeatmapDay>> _groupByMonth(
    List<FxHeatmapDay> days,
  ) {
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    final grouped = <DateTime, List<FxHeatmapDay>>{};
    for (final day in sorted) {
      final month = DateTime(day.date.year, day.date.month);
      grouped.putIfAbsent(month, () => <FxHeatmapDay>[]).add(day);
    }
    return grouped;
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final List<FxHeatmapDay> days;
  final Color color;
  final double maxAmount;
  final ValueChanged<FxHeatmapDay>? onDayTap;
  final int columns;
  final double cellSize;
  final double cellGap;
  final String Function(DateTime date)? labelBuilder;

  const _MonthGrid({
    required this.month,
    required this.days,
    required this.color,
    required this.maxAmount,
    required this.onDayTap,
    required this.columns,
    required this.cellSize,
    required this.cellGap,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final first = DateTime(month.year, month.month);
    final leading = first.weekday - 1;
    final cells = <Widget>[
      for (var i = 0; i < leading; i++)
        SizedBox(width: cellSize, height: cellSize),
      for (final day in days)
        _DayCell(
          day: day,
          color: _shade(day.amount),
          size: cellSize,
          onTap: onDayTap == null ? null : () => onDayTap!(day),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelBuilder?.call(month) ?? '${month.month}月',
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
        const SizedBox(height: FxSpacing.xs),
        Wrap(spacing: cellGap, runSpacing: cellGap, children: cells),
      ],
    );
  }

  Color _shade(double amount) {
    if (amount <= 0 || maxAmount <= 0) return color.withValues(alpha: 0.08);
    final ratio = (amount / maxAmount).clamp(0.0, 1.0);
    final alpha = ratio <= 0.25
        ? 0.22
        : ratio <= 0.50
        ? 0.38
        : ratio <= 0.75
        ? 0.58
        : 0.82;
    return color.withValues(alpha: alpha);
  }
}

class _DayCell extends StatelessWidget {
  final FxHeatmapDay day;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cell = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(FxRadius.tile / 3),
      ),
    );
    if (onTap == null) return cell;
    return Tooltip(
      message: '${day.date.month}/${day.date.day} · ${day.count}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FxRadius.tile / 3),
        child: cell,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String lowLabel;
  final String highLabel;

  const _Legend({
    required this.color,
    required this.lowLabel,
    required this.highLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final colors = [
      color.withValues(alpha: 0.08),
      color.withValues(alpha: 0.22),
      color.withValues(alpha: 0.38),
      color.withValues(alpha: 0.58),
      color.withValues(alpha: 0.82),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          lowLabel,
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
        const SizedBox(width: FxSpacing.xs),
        for (final c in colors) ...[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: FxSpacing.xs),
        Text(
          highLabel,
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
      ],
    );
  }
}
