import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_donut_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
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
        return FxDonutChart(
          slices: [
            for (final slice in positive)
              FxDonutSlice(
                name: slice.name,
                value: slice.value,
                percent: slice.percent,
              ),
          ],
          currencyCode: currencyCode,
          emptyName: S.of(context).statsUncategorized,
        );
      },
    );
  }
}
