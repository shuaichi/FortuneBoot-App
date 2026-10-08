import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 统计页粘顶栏：时间区间选择（本周/本月/本年/自定义）+ 支出/收入分段。
class StatsTopBar extends StatelessWidget {
  const StatsTopBar({
    super.key,
    this.editingLayout = false,
    this.onEditLayoutToggle,
  });

  final bool editingLayout;
  final VoidCallback? onEditLayoutToggle;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StatsBloc>().state;
    final bloc = context.read<StatsBloc>();
    final locale = Localizations.localeOf(context).toString();
    final day = DateFormat.Md(locale);

    return Container(
      color: FxPalette.of(context).canvas,
      padding: EdgeInsets.only(
        left: FxSpacing.lg,
        right: FxSpacing.lg,
        top: MediaQuery.of(context).padding.top + FxSpacing.xs,
        bottom: FxSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).statsTitle,
                  style: FxTypography.titleLarge,
                ),
              ),
              if (onEditLayoutToggle != null)
                IconButton(
                  tooltip: editingLayout
                      ? S.of(context).dashboardDoneEditing
                      : S.of(context).dashboardEditLayout,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onEditLayoutToggle!();
                  },
                  icon: Icon(
                    editingLayout
                        ? Icons.check_rounded
                        : Icons.dashboard_customize_rounded,
                  ),
                ),
            ],
          ),
          if (!editingLayout) ...[
            const SizedBox(height: FxSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _RangeChip(
                    label: S.of(context).statsRangeWeek,
                    semanticsLabel: S.of(context).statsRangeWeek,
                    selected: state.range == StatsRange.week,
                    onTap: () =>
                        bloc.add(const StatsRangeChanged(StatsRange.week)),
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
                Expanded(
                  child: _RangeChip(
                    label: S.of(context).statsRangePeriod,
                    semanticsLabel: S.of(context).statsRangePeriod,
                    selected: state.range == StatsRange.month,
                    onTap: () =>
                        bloc.add(const StatsRangeChanged(StatsRange.month)),
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
                Expanded(
                  child: _RangeChip(
                    label: S.of(context).statsRangeYear,
                    semanticsLabel: S.of(context).statsRangeYear,
                    selected: state.range == StatsRange.year,
                    onTap: () =>
                        bloc.add(const StatsRangeChanged(StatsRange.year)),
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
                Expanded(
                  child: _RangeChip(
                    label:
                        state.range == StatsRange.custom &&
                            state.customStart != null &&
                            state.customEnd != null
                        ? '${day.format(state.customStart!)}-${day.format(state.customEnd!)}'
                        : S.of(context).statsRangeCustom,
                    semanticsLabel:
                        state.range == StatsRange.custom &&
                            state.customStart != null &&
                            state.customEnd != null
                        ? '${S.of(context).statsRangeCustom} ${DateFormat.yMMMd(locale).format(state.customStart!)} - ${DateFormat.yMMMd(locale).format(state.customEnd!)}'
                        : S.of(context).statsRangeCustom,
                    selected: state.range == StatsRange.custom,
                    onTap: () => _pickCustom(context, bloc),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FxSpacing.sm),
            FxSegmented<StatsType>(
              value: state.type,
              segments: [
                FxSegment(StatsType.expense, S.of(context).statsExpense),
                FxSegment(StatsType.income, S.of(context).statsIncome),
              ],
              onChanged: (t) => bloc.add(StatsTypeChanged(t)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickCustom(BuildContext context, StatsBloc bloc) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initial =
        bloc.state.customStart != null && bloc.state.customEnd != null
        ? DateTimeRange(
            start: bloc.state.customStart!,
            end: bloc.state.customEnd!,
          )
        : DateTimeRange(start: DateTime(now.year, now.month), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: initial,
    );
    if (!context.mounted || bloc.isClosed) return;
    if (picked != null) {
      bloc.add(
        StatsRangeChanged(
          StatsRange.custom,
          customStart: picked.start,
          customEnd: picked.end,
        ),
      );
    }
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: FxRadius.pillBorder,
        child: InkWell(
          borderRadius: FxRadius.pillBorder,
          onTap: () {
            if (!selected) HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 36),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.xs,
              vertical: FxSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected ? palette.primary : palette.surface,
              borderRadius: FxRadius.pillBorder,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FxTypography.label.copyWith(
                color: selected ? palette.onPrimary : palette.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
