import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_palette.dart';
import 'package:fortuneboot/fx/components/fx_bar_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ③ 标签柱图：Top N（默认 10）。
class StatsTagCard extends StatelessWidget {
  final String label;
  final StatsSection<List<BarItem>> section;
  final String? currencyCode;
  final VoidCallback onRetry;

  static const int _topN = 10;

  const StatsTagCard({
    super.key,
    required this.label,
    required this.section,
    required this.currencyCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StatsCardShell<List<BarItem>>(
      label: label,
      section: section,
      onRetry: onRetry,
      height: 260,
      builder: (items) {
        final positive = items.where((e) => e.value > 0).take(_topN).toList();
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
        final formats = StatsFormatters.of(context, currencyCode: currencyCode);
        final chartItems = [
          for (final item in positive)
            FxBarItem(
              name: item.name,
              value: item.value,
              color: StatsPalette.stableFor(item.name, id: item.id),
            ),
        ];
        final summary = chartItems
            .map(
              (item) =>
                  '${item.name.isEmpty ? S.of(context).statsUnnamed : item.name} '
                  '${formats.money(item.value)}',
            )
            .join(', ');
        return Semantics(
          label: '$label: $summary',
          child: FxBarChart(
            items: chartItems,
            unnamedLabel: S.of(context).statsUnnamed,
            locale: formats.locale,
            visibility: formats.visibility,
            valueFormatter: formats.chartValue,
          ),
        );
      },
    );
  }
}
