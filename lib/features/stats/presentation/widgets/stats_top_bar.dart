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
                _RangeMenu(
                  label: _rangeLabel(context, state, day),
                  semanticsLabel: _rangeSemanticsLabel(context, state, locale),
                  onSelected: (range) {
                    HapticFeedback.selectionClick();
                    if (range == StatsRange.custom) {
                      _pickCustom(context, bloc);
                      return;
                    }
                    bloc.add(StatsRangeChanged(range));
                  },
                ),
                const SizedBox(width: FxSpacing.sm),
                Expanded(
                  child: FxSegmented<StatsType>(
                    value: state.type,
                    segments: [
                      FxSegment(StatsType.expense, S.of(context).statsExpense),
                      FxSegment(StatsType.income, S.of(context).statsIncome),
                    ],
                    onChanged: (type) => bloc.add(StatsTypeChanged(type)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _rangeLabel(BuildContext context, StatsState state, DateFormat day) {
    if (state.range == StatsRange.custom &&
        state.customStart != null &&
        state.customEnd != null) {
      return '${day.format(state.customStart!)}–${day.format(state.customEnd!)}';
    }
    return _labelForRange(context, state.range);
  }

  String _rangeSemanticsLabel(
    BuildContext context,
    StatsState state,
    String locale,
  ) {
    final s = S.of(context);
    if (state.range == StatsRange.custom &&
        state.customStart != null &&
        state.customEnd != null) {
      final start = DateFormat.yMMMd(locale).format(state.customStart!);
      final end = DateFormat.yMMMd(locale).format(state.customEnd!);
      return '${s.statsRangeCustom} $start - $end';
    }
    return _labelForRange(context, state.range);
  }

  String _labelForRange(BuildContext context, StatsRange range) {
    final s = S.of(context);
    return switch (range) {
      StatsRange.week => s.statsRangeWeek,
      StatsRange.month => s.statsRangePeriod,
      StatsRange.year => s.statsRangeYear,
      StatsRange.custom => s.statsRangeCustom,
    };
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

class _RangeMenu extends StatelessWidget {
  const _RangeMenu({
    required this.label,
    required this.semanticsLabel,
    required this.onSelected,
  });

  final String label;
  final String semanticsLabel;
  final ValueChanged<StatsRange> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 144, minHeight: 48),
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: FxRadius.tileBorder,
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: PopupMenuButton<StatsRange>(
          tooltip: semanticsLabel,
          onSelected: onSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: StatsRange.week,
              child: Text(s.statsRangeWeek),
            ),
            PopupMenuItem(
              value: StatsRange.month,
              child: Text(s.statsRangePeriod),
            ),
            PopupMenuItem(
              value: StatsRange.year,
              child: Text(s.statsRangeYear),
            ),
            PopupMenuItem(
              value: StatsRange.custom,
              child: Text(s.statsRangeCustom),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FxSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FxTypography.label.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: palette.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
