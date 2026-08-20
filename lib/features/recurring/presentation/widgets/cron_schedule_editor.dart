import 'package:flutter/material.dart';
import 'package:fortuneboot/features/recurring/data/cron_builder.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 周期记账频率可视化编辑器：频率分段 + 时间 + 频率相关字段，
/// 实时把选择映射成 cron 字符串通过 [onChanged] 上抛，并展示人类可读摘要。
class CronScheduleEditor extends StatelessWidget {
  const CronScheduleEditor({
    super.key,
    required this.spec,
    required this.onChanged,
  });

  final CronSpec spec;
  final ValueChanged<CronSpec> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FxSegmented<CronFrequency>(
          value: spec.frequency,
          onChanged: (f) => onChanged(spec.copyWith(frequency: f)),
          segments: [
            FxSegment(CronFrequency.daily, S.of(context).recurringFreqDaily),
            FxSegment(CronFrequency.weekly, S.of(context).recurringFreqWeekly),
            FxSegment(
              CronFrequency.monthly,
              S.of(context).recurringFreqMonthly,
            ),
            FxSegment(CronFrequency.yearly, S.of(context).recurringFreqYearly),
          ],
        ),
        const SizedBox(height: FxSpacing.md),
        _timeRow(context),
        if (spec.frequency == CronFrequency.weekly) ...[
          const SizedBox(height: FxSpacing.md),
          _weekdayPicker(context),
        ],
        if (spec.frequency == CronFrequency.monthly ||
            spec.frequency == CronFrequency.yearly) ...[
          const SizedBox(height: FxSpacing.md),
          _dayOfMonthPicker(context),
        ],
        if (spec.frequency == CronFrequency.yearly) ...[
          const SizedBox(height: FxSpacing.md),
          _monthPicker(context),
        ],
        const SizedBox(height: FxSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: palette.primaryContainer,
            borderRadius: FxRadius.tileBorder,
          ),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: palette.primary),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Text(
                  summarize(context, spec),
                  style: FxTypography.label.copyWith(color: palette.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeRow(BuildContext context) {
    final palette = FxPalette.of(context);
    final label =
        '${spec.hour.toString().padLeft(2, '0')}:${spec.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Text(
          S.of(context).recurringAtTime,
          style: FxTypography.label.copyWith(color: palette.textSecondary),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: spec.hour, minute: spec.minute),
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
            );
            if (picked != null) {
              onChanged(
                spec.copyWith(hour: picked.hour, minute: picked.minute),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.md,
              vertical: FxSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: FxRadius.pillBorder,
              border: Border.all(color: palette.border),
            ),
            child: Text(
              label,
              style: FxTypography.bodyStrong.copyWith(
                color: palette.textPrimary,
                fontFamily: FxTypography.monoFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekdayPicker(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).recurringOnDays,
          style: FxTypography.label.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: FxSpacing.sm),
        Wrap(
          spacing: FxSpacing.sm,
          runSpacing: FxSpacing.sm,
          children: CronWeekday.values.map((d) {
            final selected = spec.weekdays.contains(d);
            return _chip(context, _weekdayLabel(context, d), selected, () {
              final next = {...spec.weekdays};
              if (selected) {
                if (next.length > 1) next.remove(d);
              } else {
                next.add(d);
              }
              onChanged(spec.copyWith(weekdays: next));
            }, multiSelect: true);
          }).toList(),
        ),
      ],
    );
  }

  Widget _dayOfMonthPicker(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).recurringOnDayOfMonth,
          style: FxTypography.label.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: FxSpacing.sm),
        Wrap(
          spacing: FxSpacing.xs,
          runSpacing: FxSpacing.xs,
          children: [
            for (var d = 1; d <= 31; d++)
              _chip(
                context,
                '$d',
                spec.dayOfMonth == d && !spec.lastDayOfMonth,
                () => onChanged(
                  spec.copyWith(dayOfMonth: d, lastDayOfMonth: false),
                ),
                compact: true,
              ),
            _chip(
              context,
              '31/月末',
              spec.lastDayOfMonth,
              () => onChanged(
                spec.copyWith(dayOfMonth: 31, lastDayOfMonth: true),
              ),
              compact: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _monthPicker(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).recurringOnMonth,
          style: FxTypography.label.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: FxSpacing.sm),
        Wrap(
          spacing: FxSpacing.xs,
          runSpacing: FxSpacing.xs,
          children: [
            for (var m = 1; m <= 12; m++)
              _chip(
                context,
                '$m',
                spec.month == m,
                () => onChanged(spec.copyWith(month: m)),
                compact: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap, {
    bool compact = false,
    bool multiSelect = false,
  }) {
    return FxChip(
      label: label,
      selected: selected,
      multiSelect: multiSelect,
      constraints: compact
          ? const BoxConstraints(minWidth: 40, minHeight: 44)
          : null,
      alignment: compact ? Alignment.center : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? FxSpacing.sm : FxSpacing.md,
        vertical: FxSpacing.sm,
      ),
      onTap: onTap,
    );
  }

  static String _weekdayLabel(BuildContext context, CronWeekday d) {
    final s = S.of(context);
    return switch (d) {
      CronWeekday.mon => s.recurringWeekdayMon,
      CronWeekday.tue => s.recurringWeekdayTue,
      CronWeekday.wed => s.recurringWeekdayWed,
      CronWeekday.thu => s.recurringWeekdayThu,
      CronWeekday.fri => s.recurringWeekdayFri,
      CronWeekday.sat => s.recurringWeekdaySat,
      CronWeekday.sun => s.recurringWeekdaySun,
    };
  }

  /// 生成人类可读的调度摘要。
  static String summarize(BuildContext context, CronSpec spec) {
    final s = S.of(context);
    final time =
        '${spec.hour.toString().padLeft(2, '0')}:${spec.minute.toString().padLeft(2, '0')}';
    switch (spec.frequency) {
      case CronFrequency.daily:
        return s.recurringSummaryDaily(time);
      case CronFrequency.weekly:
        final days =
            (spec.weekdays.toList()
                  ..sort((a, b) => a.isoIndex.compareTo(b.isoIndex)))
                .map((d) => _weekdayLabel(context, d))
                .join('、');
        return s.recurringSummaryWeekly(days, time);
      case CronFrequency.monthly:
        final day = spec.lastDayOfMonth ? 31 : spec.dayOfMonth;
        return s.recurringSummaryMonthly(day, time);
      case CronFrequency.yearly:
        final day = spec.lastDayOfMonth ? 31 : spec.dayOfMonth;
        return s.recurringSummaryYearly(spec.month, day, time);
    }
  }
}
