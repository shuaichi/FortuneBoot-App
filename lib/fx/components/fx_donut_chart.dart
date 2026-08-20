import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/fx/components/fx_chart_palette.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class FxDonutSlice {
  final String name;
  final double value;
  final double percent;
  final int? count;
  final Color? color;

  const FxDonutSlice({
    required this.name,
    required this.value,
    required this.percent,
    this.count,
    this.color,
  });
}

/// Shared donut chart with an optional ranked detail list.
class FxDonutChart extends StatelessWidget {
  final List<FxDonutSlice> slices;
  final String? currencyCode;
  final double chartSize;
  final double radius;
  final double centerSpaceRadius;
  final int topN;
  final bool showList;
  final String emptyName;
  final String? centerLabel;
  final double? centerAmount;

  const FxDonutChart({
    super.key,
    required this.slices,
    this.currencyCode,
    this.chartSize = 130,
    this.radius = 18,
    this.centerSpaceRadius = 34,
    this.topN = 5,
    this.showList = true,
    this.emptyName = '未分类',
    this.centerLabel,
    this.centerAmount,
  });

  @override
  Widget build(BuildContext context) {
    final positive = slices.where((s) => s.value > 0).toList();
    if (positive.isEmpty) return const SizedBox.shrink();

    final chart = SizedBox(
      width: chartSize,
      height: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: centerSpaceRadius,
              sections: [
                for (var i = 0; i < positive.length; i++)
                  PieChartSectionData(
                    value: positive[i].value,
                    color: _colorAt(i, positive[i]),
                    radius: radius,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          if (centerAmount != null || centerLabel != null)
            _CenterLabel(
              amount: centerAmount,
              label: centerLabel,
              currencyCode: currencyCode,
            ),
        ],
      ),
    );

    if (!showList) return chart;

    return Row(
      children: [
        chart,
        const SizedBox(width: FxSpacing.md),
        Expanded(
          child: _SliceList(
            slices: positive.take(topN).toList(),
            currencyCode: currencyCode,
            emptyName: emptyName,
          ),
        ),
      ],
    );
  }

  static Color _colorAt(int index, FxDonutSlice slice) =>
      slice.color ?? FxChartPalette.colorAt(index);
}

class _CenterLabel extends StatelessWidget {
  final double? amount;
  final String? label;
  final String? currencyCode;

  const _CenterLabel({this.amount, this.label, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (amount != null)
          FxMoneyText(
            amount: amount!,
            currencyCode: currencyCode,
            fontSize: 11,
            color: palette.textPrimary,
          ),
        if (label != null)
          Text(
            label!,
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _SliceList extends StatelessWidget {
  final List<FxDonutSlice> slices;
  final String? currencyCode;
  final String emptyName;

  const _SliceList({
    required this.slices,
    required this.currencyCode,
    required this.emptyName,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < slices.length; i++) ...[
          _row(context, i, slices[i], palette),
          if (i != slices.length - 1) const SizedBox(height: FxSpacing.sm),
        ],
      ],
    );
  }

  Widget _row(
    BuildContext context,
    int index,
    FxDonutSlice slice,
    FxPalette palette,
  ) {
    final color = slice.color ?? FxChartPalette.colorAt(index);
    final name = slice.name.isEmpty ? emptyName : slice.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: FxSpacing.sm),
            Expanded(
              child: Text(
                name,
                style: FxTypography.label.copyWith(color: palette.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: FxSpacing.sm),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FxMoneyText(
                  amount: slice.value,
                  currencyCode: currencyCode,
                  color: palette.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.xs),
        Row(
          children: [
            Expanded(
              child: FxProgressBar(
                value: slice.percent / 100,
                color: color,
                height: 5,
              ),
            ),
            const SizedBox(width: FxSpacing.sm),
            Text(
              FxMoneyFormatter.formatPercent(
                slice.percent,
                locale: Localizations.localeOf(context).toString(),
              ),
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
            if (slice.count != null) ...[
              const SizedBox(width: FxSpacing.xs),
              Text(
                '· ${slice.count}',
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
