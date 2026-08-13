import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_bar_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ③ 标签柱图：Top N（默认 10）。
class StatsTagCard extends StatelessWidget {
  final StatsSection<List<BarItem>> section;
  final VoidCallback onRetry;

  static const int _topN = 10;

  const StatsTagCard({super.key, required this.section, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StatsCardShell<List<BarItem>>(
      label: S.of(context).statsTags,
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
        return FxBarChart(
          items: [
            for (final item in positive)
              FxBarItem(name: item.name, value: item.value),
          ],
          unnamedLabel: S.of(context).statsUnnamed,
        );
      },
    );
  }
}
