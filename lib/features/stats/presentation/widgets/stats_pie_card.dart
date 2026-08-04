import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_palette.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
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
      builder: (slices) {
        final positive = slices.where((s) => s.value > 0).toList();
        if (positive.isEmpty) {
          return Center(
            child: Text(
              S.of(context).statsNoRecordsThisPeriod,
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textTertiary,
              ),
            ),
          );
        }
        final top = positive.take(5).toList();
        return Row(
          children: [
            SizedBox(width: 130, child: _Donut(slices: positive)),
            const SizedBox(width: FxSpacing.md),
            Expanded(
              child: _TopList(top: top, currencyCode: currencyCode),
            ),
          ],
        );
      },
    );
  }
}

class _Donut extends StatelessWidget {
  final List<PieSlice> slices;
  const _Donut({required this.slices});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          startDegreeOffset: -90,
          sectionsSpace: 2,
          centerSpaceRadius: 34,
          sections: [
            for (var i = 0; i < slices.length; i++)
              PieChartSectionData(
                value: slices[i].value,
                color: StatsPalette.colorAt(i),
                radius: 18,
                showTitle: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _TopList extends StatelessWidget {
  final List<PieSlice> top;
  final String? currencyCode;
  const _TopList({required this.top, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < top.length; i++) ...[
          _row(context, i, top[i], palette),
          if (i != top.length - 1) const SizedBox(height: FxSpacing.sm),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, int index, PieSlice s, FxPalette palette) {
    final color = StatsPalette.colorAt(index);
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
                s.name.isEmpty ? S.of(context).statsUncategorized : s.name,
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
                  amount: s.value,
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
                value: s.percent / 100,
                color: color,
                height: 5,
              ),
            ),
            const SizedBox(width: FxSpacing.sm),
            Text(
              '${s.percent.toStringAsFixed(0)}%',
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}
