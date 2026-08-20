import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_card_shell.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/fx/components/fx_line_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ① 收支趋势折线：X 时间，Y 金额。支出/收入按当前类型着色。
class StatsTrendCard extends StatelessWidget {
  final StatsSection<List<TrendPoint>> section;
  final StatsType type;
  final String? currencyCode;
  final VoidCallback onRetry;

  const StatsTrendCard({
    super.key,
    required this.section,
    required this.type,
    required this.currencyCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final label = type == StatsType.expense
        ? S.of(context).statsExpenseTrend
        : S.of(context).statsIncomeTrend;
    return StatsCardShell<List<TrendPoint>>(
      label: label,
      section: section,
      onRetry: onRetry,
      builder: (points) {
        if (points.isEmpty) {
          return const _EmptyAxis();
        }
        final finance = FxFinanceColors.of(context);
        final color = type == StatsType.expense
            ? finance.expense
            : finance.income;
        final formats = StatsFormatters.of(context, currencyCode: currencyCode);
        final summary = points
            .take(3)
            .map((point) => '${point.name} ${formats.money(point.value)}')
            .join(', ');
        return Semantics(
          label: '$label: $summary',
          child: FxLineChart(
            series: [
              FxLineSeries(
                color: color,
                label: label,
                points: [
                  for (final point in points)
                    FxLinePoint(name: point.name, value: point.value),
                ],
              ),
            ],
            locale: formats.locale,
            visibility: formats.visibility,
            valueFormatter: formats.chartValue,
          ),
        );
      },
    );
  }
}

/// 空态：显示空轴 + "本期暂无记录"。
class _EmptyAxis extends StatelessWidget {
  const _EmptyAxis();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).statsNoRecordsThisPeriod,
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      ),
    );
  }
}
