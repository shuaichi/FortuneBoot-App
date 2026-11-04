import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_chart_table_toggle.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_palette.dart';
import 'package:fortuneboot/fx/components/fx_donut_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 占比饼图卡（分类 / 交易对象通用）：环形饼图 + Top5 列表。
class StatsPieCard extends StatelessWidget {
  final String label;
  final StatsSection<List<PieSlice>> section;
  final String? currencyCode;
  final VoidCallback onRetry;

  const StatsPieCard({
    super.key,
    required this.label,
    required this.section,
    required this.currencyCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StatsCardShell<List<PieSlice>>(
      label: label,
      section: section,
      onRetry: onRetry,
      height: 240,
      isEmpty: (slices) => slices.every((slice) => slice.value <= 0),
      builder: (slices) {
        final positive = slices.where((s) => s.value > 0).toList();
        final formats = StatsFormatters.of(context, currencyCode: currencyCode);
        final chartSlices = [
          for (final slice in positive)
            FxDonutSlice(
              name: slice.name,
              value: slice.value,
              percent: slice.percent,
              count: slice.billCount,
              color: StatsPalette.stableFor(slice.name, id: slice.id),
            ),
        ];
        final labels = [
          for (final slice in chartSlices)
            '${slice.name.isEmpty ? S.of(context).statsUncategorized : slice.name}: '
                '${formats.money(slice.value)}, ${formats.percent(slice.percent)}',
        ];
        final rows = [
          for (final slice in chartSlices.take(5))
            StatsChartTableRow(
              label: slice.name.isEmpty
                  ? S.of(context).statsUncategorized
                  : slice.name,
              value: formats.money(slice.value),
              percent: formats.percent(slice.percent),
              detail: slice.count == null
                  ? null
                  : S.of(context).statsBillCount(slice.count!),
              color: slice.color,
              icon: Icons.donut_large_rounded,
            ),
        ];
        return StatsChartTableToggle(
          rows: rows,
          chart: formats.masked
              ? _MaskedPieLegend(
                  slices: chartSlices,
                  formats: formats,
                  emptyName: S.of(context).statsUncategorized,
                )
              : FxDonutChart(
                  slices: chartSlices,
                  currencyCode: currencyCode,
                  emptyName: S.of(context).statsUncategorized,
                  accessibilityLabels: labels,
                ),
        );
      },
    );
  }
}

class _MaskedPieLegend extends StatelessWidget {
  const _MaskedPieLegend({
    required this.slices,
    required this.formats,
    required this.emptyName,
  });

  final List<FxDonutSlice> slices;
  final StatsFormatters formats;
  final String emptyName;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final slice in slices.take(5)) ...[
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: slice.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Text(
                  slice.name.isEmpty ? emptyName : slice.name,
                  style: FxTypography.label.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Text(
                '${formats.money(slice.value)} · ${formats.percent(slice.percent)}',
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
        ],
      ],
    );
  }
}
