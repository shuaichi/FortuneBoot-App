import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

/// 统计页粘顶栏：时间区间选择（本周/本月/本年/自定义）+ 支出/收入分段。
class StatsTopBar extends StatelessWidget {
  const StatsTopBar({super.key});

  static final DateFormat _day = DateFormat('M月d日');

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StatsBloc>().state;
    final bloc = context.read<StatsBloc>();

    return Container(
      color: FxPalette.of(context).canvas,
      padding: EdgeInsets.only(
        left: FxSpacing.lg,
        right: FxSpacing.lg,
        top: MediaQuery.of(context).padding.top + FxSpacing.sm,
        bottom: FxSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('统计', style: FxTypography.titleLarge),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              _RangeChip(
                label: '本周',
                selected: state.range == StatsRange.week,
                onTap: () => bloc.add(const StatsRangeChanged(StatsRange.week)),
              ),
              const SizedBox(width: FxSpacing.sm),
              _RangeChip(
                label: '本账期',
                selected: state.range == StatsRange.month,
                onTap: () =>
                    bloc.add(const StatsRangeChanged(StatsRange.month)),
              ),
              const SizedBox(width: FxSpacing.sm),
              _RangeChip(
                label: '本年',
                selected: state.range == StatsRange.year,
                onTap: () => bloc.add(const StatsRangeChanged(StatsRange.year)),
              ),
              const SizedBox(width: FxSpacing.sm),
              _RangeChip(
                label:
                    state.range == StatsRange.custom &&
                        state.customStart != null &&
                        state.customEnd != null
                    ? '${_day.format(state.customStart!)}-${_day.format(state.customEnd!)}'
                    : '自定义',
                selected: state.range == StatsRange.custom,
                onTap: () => _pickCustom(context, bloc),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          FxSegmented<StatsType>(
            value: state.type,
            segments: const [
              FxSegment(StatsType.expense, '支出'),
              FxSegment(StatsType.income, '收入'),
            ],
            onChanged: (t) => bloc.add(StatsTypeChanged(t)),
          ),
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
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return GestureDetector(
      onTap: () {
        if (!selected) HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? palette.primary : palette.surface,
          borderRadius: FxRadius.pillBorder,
        ),
        child: Text(
          label,
          style: FxTypography.label.copyWith(
            color: selected ? palette.onPrimary : palette.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
