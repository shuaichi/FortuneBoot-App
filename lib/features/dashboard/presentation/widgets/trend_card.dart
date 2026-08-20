import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_line_chart.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 收支趋势迷你折线。两端独立加载，任一端可用时仍展示已有曲线。
class TrendCard extends StatelessWidget {
  final DashboardSection<List<TrendPoint>> expenseSection;
  final DashboardSection<List<TrendPoint>> incomeSection;
  final VoidCallback onRetry;

  const TrendCard({
    super.key,
    required this.expenseSection,
    required this.incomeSection,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading =
        expenseSection.status == SectionStatus.loading &&
        incomeSection.status == SectionStatus.loading;
    if (isLoading) {
      return const FxCard(child: Center(child: _LoadingIndicator()));
    }

    final expense = expenseSection.isReady
        ? expenseSection.data!
        : const <TrendPoint>[];
    final income = incomeSection.isReady
        ? incomeSection.data!
        : const <TrendPoint>[];
    final trend = IncomeExpenseTrend.align(expense: expense, income: income);
    final canRender = trend.expense.length >= 2;
    final hasError =
        expenseSection.status == SectionStatus.error ||
        incomeSection.status == SectionStatus.error;

    if (!canRender && hasError) {
      return FxCard(child: _TrendError(onRetry: onRetry));
    }

    final finance = FxFinanceColors.of(context);
    final visibility = context.select<PreferencesCubit, FxAmountVisibility>(
      (cubit) => cubit.state.dashboard.hideAmounts
          ? FxAmountVisibility.hidden
          : FxAmountVisibility.visible,
    );
    return FxCard(
      onTap: canRender
          ? () => AppRouter.push<void>(context, Routes.stats)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).dashboardIncomeExpenseTrend),
          const SizedBox(height: FxSpacing.xs),
          _TrendLegend(
            expenseColor: finance.expense,
            incomeColor: finance.income,
          ),
          const SizedBox(height: FxSpacing.sm),
          Expanded(
            child: canRender
                ? FxLineChart(
                    height: 120,
                    showAxes: false,
                    visibility: visibility,
                    locale: Localizations.localeOf(context).toString(),
                    series: [
                      if (expenseSection.isReady)
                        FxLineSeries(
                          points: [
                            for (final point in trend.expense)
                              FxLinePoint(name: point.name, value: point.value),
                          ],
                          color: finance.expense,
                          label: S.of(context).statsExpense,
                        ),
                      if (incomeSection.isReady)
                        FxLineSeries(
                          points: [
                            for (final point in trend.income)
                              FxLinePoint(name: point.name, value: point.value),
                          ],
                          color: finance.income,
                          label: S.of(context).statsIncome,
                        ),
                    ],
                  )
                : Center(
                    child: Text(
                      S.of(context).dashboardInsufficientData,
                      style: FxTypography.caption.copyWith(
                        color: FxPalette.of(context).textTertiary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(strokeWidth: 2.2),
  );
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({required this.expenseColor, required this.incomeColor});

  final Color expenseColor;
  final Color incomeColor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _LegendItem(label: S.of(context).statsExpense, color: expenseColor),
      const SizedBox(width: FxSpacing.md),
      _LegendItem(label: S.of(context).statsIncome, color: incomeColor),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: FxSpacing.xs),
      Text(
        label,
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      ),
    ],
  );
}

class _TrendError extends StatelessWidget {
  const _TrendError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 22, color: palette.danger),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).dashboardLoadFailed,
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
          const SizedBox(height: FxSpacing.xs),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              S.of(context).commonRetry,
              style: FxTypography.caption.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
