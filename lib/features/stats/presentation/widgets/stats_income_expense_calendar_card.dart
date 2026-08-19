import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

class StatsIncomeExpenseCalendarCard extends StatelessWidget {
  const StatsIncomeExpenseCalendarCard({
    super.key,
    required this.section,
    required this.view,
    required this.anchor,
    required this.currencyCode,
    required this.onViewChanged,
    required this.onNavigate,
    required this.onDrillDown,
    required this.onRetry,
  });

  final StatsSection<IncomeExpenseCalendarResponse> section;
  final IncomeExpenseCalendarView view;
  final DateTime anchor;
  final String? currencyCode;
  final ValueChanged<IncomeExpenseCalendarView> onViewChanged;
  final ValueChanged<int> onNavigate;
  final void Function(IncomeExpenseCalendarView view, DateTime anchor)
  onDrillDown;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(s.statsIncomeExpenseCalendar),
          const SizedBox(height: FxSpacing.md),
          FxSegmented<IncomeExpenseCalendarView>(
            segments: [
              FxSegment(IncomeExpenseCalendarView.month, s.statsCalendarMonth),
              FxSegment(IncomeExpenseCalendarView.year, s.statsCalendarYear),
              FxSegment(
                IncomeExpenseCalendarView.history,
                s.statsCalendarHistory,
              ),
            ],
            value: view,
            onChanged: onViewChanged,
          ),
          const SizedBox(height: FxSpacing.md),
          _CalendarNavigator(
            title: _title(context),
            onPrevious: () => onNavigate(-1),
            onNext: () => onNavigate(1),
          ),
          const SizedBox(height: FxSpacing.sm),
          switch (section.status) {
            StatsSectionStatus.loading => FxStateView.loading(),
            StatsSectionStatus.error => FxStateView.error(
              message: section.error,
              onRetry: onRetry,
            ),
            StatsSectionStatus.ready => _CalendarContent(
              response: section.data!,
              view: view,
              anchor: anchor,
              currencyCode: currencyCode,
              onDrillDown: onDrillDown,
            ),
          },
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return switch (view) {
      IncomeExpenseCalendarView.month => DateFormat.yMMMM(
        locale,
      ).format(anchor),
      IncomeExpenseCalendarView.year => DateFormat.y(locale).format(anchor),
      IncomeExpenseCalendarView.history => '${anchor.year - 4}–${anchor.year}',
    };
  }
}

class _CalendarNavigator extends StatelessWidget {
  const _CalendarNavigator({
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: S.of(context).statsCalendarPrevious,
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: FxTypography.bodyStrong.copyWith(
            color: FxPalette.of(context).textPrimary,
          ),
        ),
      ),
      IconButton(
        tooltip: S.of(context).statsCalendarNext,
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({
    required this.response,
    required this.view,
    required this.anchor,
    required this.currencyCode,
    required this.onDrillDown,
  });

  final IncomeExpenseCalendarResponse response;
  final IncomeExpenseCalendarView view;
  final DateTime anchor;
  final String? currencyCode;
  final void Function(IncomeExpenseCalendarView view, DateTime anchor)
  onDrillDown;

  @override
  Widget build(BuildContext context) {
    if (view == IncomeExpenseCalendarView.month) {
      return _MonthCalendar(
        anchor: anchor,
        items: response.items,
        currencyCode: currencyCode,
      );
    }
    return _PeriodGrid(
      items: response.items,
      view: view,
      anchor: anchor,
      currencyCode: currencyCode,
      onDrillDown: onDrillDown,
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.anchor,
    required this.items,
    required this.currencyCode,
  });

  final DateTime anchor;
  final List<IncomeExpenseCalendarBucket> items;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final days = <int, IncomeExpenseCalendarBucket>{
      for (final item in items)
        if (_dayFromPeriod(item.period) != null)
          _dayFromPeriod(item.period)!: item,
    };
    final firstWeekday = DateTime(anchor.year, anchor.month).weekday;
    final dayCount = DateTime(anchor.year, anchor.month + 1, 0).day;
    final weekdayLabels = [
      S.of(context).billsWeekdayMon,
      S.of(context).billsWeekdayTue,
      S.of(context).billsWeekdayWed,
      S.of(context).billsWeekdayThu,
      S.of(context).billsWeekdayFri,
      S.of(context).billsWeekdaySat,
      S.of(context).billsWeekdaySun,
    ];
    final slots = <Widget>[
      for (var i = 1; i < firstWeekday; i++) const SizedBox.shrink(),
      for (var day = 1; day <= dayCount; day++)
        _DayCell(
          date: DateTime(anchor.year, anchor.month, day),
          bucket: days[day] ?? const IncomeExpenseCalendarBucket(),
          currencyCode: currencyCode,
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - 24) / 7;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final minimumHeight = 72 * textScale;
        final dayCellHeight = cellWidth.clamp(minimumHeight, 96.0 * textScale);
        return Column(
          children: [
            Row(
              children: [
                for (final label in weekdayLabels)
                  Expanded(
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: FxTypography.caption.copyWith(
                          color: FxPalette.of(context).textTertiary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FxSpacing.sm),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: dayCellHeight,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              itemBuilder: (context, index) => slots[index],
            ),
          ],
        );
      },
    );
  }

  int? _dayFromPeriod(String period) {
    final date = DateTime.tryParse(period);
    if (date == null ||
        date.year != anchor.year ||
        date.month != anchor.month) {
      return null;
    }
    return date.day;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.bucket,
    required this.currencyCode,
  });

  final DateTime date;
  final IncomeExpenseCalendarBucket bucket;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    final summary =
        '${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date)}: '
        '${s.statsCalendarIncome} ${bucket.income}, '
        '${s.statsCalendarExpense} ${bucket.expense}, '
        '${s.statsCalendarTotalCount(bucket.totalCount)}';
    return Semantics(
      button: true,
      label: summary,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDaySummary(context, date, bucket, currencyCode),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bucket.totalCount == 0
                ? palette.surfaceMuted.withValues(alpha: 0.45)
                : palette.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$date'.split(' ').first.split('-').last,
                style: FxTypography.caption,
              ),
              const Spacer(),
              _CompactAmount('↑', bucket.income, finance.income),
              _CompactAmount('↓', bucket.expense, finance.expense),
              Text(
                '${bucket.totalCount}',
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactAmount extends StatelessWidget {
  const _CompactAmount(this.prefix, this.amount, this.color);

  final String prefix;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    '$prefix${amount == 0 ? '—' : amount.toStringAsFixed(0)}',
    style: FxTypography.caption.copyWith(color: color, fontSize: 9),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class _PeriodGrid extends StatelessWidget {
  const _PeriodGrid({
    required this.items,
    required this.view,
    required this.anchor,
    required this.currencyCode,
    required this.onDrillDown,
  });

  final List<IncomeExpenseCalendarBucket> items;
  final IncomeExpenseCalendarView view;
  final DateTime anchor;
  final String? currencyCode;
  final void Function(IncomeExpenseCalendarView view, DateTime anchor)
  onDrillDown;

  @override
  Widget build(BuildContext context) {
    final itemsByPeriod = {for (final item in items) item.period: item};
    final periods = view == IncomeExpenseCalendarView.year
        ? List.generate(12, (index) => DateTime(anchor.year, index + 1))
        : List.generate(5, (index) => DateTime(anchor.year - 4 + index));
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // 年度视图一排 4 个月(12 ÷ 4 = 3 排),与历史视图 3 排的纵向节奏对齐,
    // 一屏即可概览全年;历史视图保持 2 列不变。
    final crossAxisCount = view == IncomeExpenseCalendarView.year ? 4 : 2;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 96 * textScale,
        mainAxisSpacing: FxSpacing.sm,
        crossAxisSpacing: FxSpacing.sm,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        final period = periods[index];
        return _PeriodCell(
          date: period,
          bucket:
              itemsByPeriod[_periodKey(period)] ??
              const IncomeExpenseCalendarBucket(),
          currencyCode: currencyCode,
          showMonth: view == IncomeExpenseCalendarView.year,
          onTap: () => onDrillDown(
            view == IncomeExpenseCalendarView.year
                ? IncomeExpenseCalendarView.month
                : IncomeExpenseCalendarView.year,
            period,
          ),
        );
      },
    );
  }

  String _periodKey(DateTime date) => view == IncomeExpenseCalendarView.year
      ? DateFormat('yyyy-MM').format(date)
      : DateFormat('yyyy').format(date);
}

class _PeriodCell extends StatelessWidget {
  const _PeriodCell({
    required this.date,
    required this.bucket,
    required this.currencyCode,
    required this.showMonth,
    required this.onTap,
  });

  final DateTime date;
  final IncomeExpenseCalendarBucket bucket;
  final String? currencyCode;
  final bool showMonth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    final label = showMonth
        ? DateFormat.MMM(
            Localizations.localeOf(context).toString(),
          ).format(date)
        : DateFormat.y(Localizations.localeOf(context).toString()).format(date);
    return Semantics(
      button: true,
      label:
          '$label, ${S.of(context).statsCalendarIncome} ${bucket.income}, '
          '${S.of(context).statsCalendarExpense} ${bucket.expense}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(FxSpacing.sm),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: FxTypography.label),
              const Spacer(),
              _CompactAmount('↑', bucket.income, finance.income),
              _CompactAmount('↓', bucket.expense, finance.expense),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDaySummary(
  BuildContext context,
  DateTime date,
  IncomeExpenseCalendarBucket bucket,
  String? currencyCode,
) {
  final s = S.of(context);
  final finance = FxFinanceColors.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.statsCalendarDateSummary(
              DateFormat.yMMMd(
                Localizations.localeOf(context).toString(),
              ).format(date),
            ),
            style: FxTypography.title,
          ),
          const SizedBox(height: FxSpacing.lg),
          _SummaryRow(
            label: s.statsCalendarIncomeCount(bucket.incomeCount),
            amount: bucket.income,
            color: finance.income,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: FxSpacing.sm),
          _SummaryRow(
            label: s.statsCalendarExpenseCount(bucket.expenseCount),
            amount: bucket.expense,
            color: finance.expense,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: FxSpacing.md),
          Text(s.statsCalendarTotalCount(bucket.totalCount)),
        ],
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyCode,
  });

  final String label;
  final double amount;
  final Color color;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: FxTypography.body)),
      FxMoneyText(amount: amount, currencyCode: currencyCode, color: color),
    ],
  );
}
