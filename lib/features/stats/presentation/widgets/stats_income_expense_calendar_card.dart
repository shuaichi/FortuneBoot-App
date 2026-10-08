import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/chinese_calendar_day.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/calendar_day_summary_sheet.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
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
    required this.onBillsRequested,
    required this.onRetry,
    this.bookId,
  });

  final StatsSection<IncomeExpenseCalendarResponse> section;
  final IncomeExpenseCalendarView view;
  final DateTime anchor;
  final String? currencyCode;
  final int? bookId;
  final ValueChanged<IncomeExpenseCalendarView> onViewChanged;
  final ValueChanged<int> onNavigate;
  final void Function(IncomeExpenseCalendarView view, DateTime anchor)
  onDrillDown;
  final ValueChanged<DateTime> onBillsRequested;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.statsIncomeExpenseCalendar,
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
            StatsSectionStatus.loading => FxStateView.loading(compact: true),
            StatsSectionStatus.error => FxStateView.error(
              message: section.error,
              onRetry: onRetry,
              retryLabel: S.of(context).commonRetry,
              compact: true,
            ),
            StatsSectionStatus.ready => _CalendarContent(
              response: section.data!,
              view: view,
              anchor: anchor,
              currencyCode: currencyCode,
              bookId: bookId,
              onDrillDown: onDrillDown,
              onBillsRequested: onBillsRequested,
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
    required this.onBillsRequested,
    this.bookId,
  });

  final IncomeExpenseCalendarResponse response;
  final IncomeExpenseCalendarView view;
  final DateTime anchor;
  final String? currencyCode;
  final int? bookId;
  final void Function(IncomeExpenseCalendarView view, DateTime anchor)
  onDrillDown;
  final ValueChanged<DateTime> onBillsRequested;

  @override
  Widget build(BuildContext context) {
    if (view == IncomeExpenseCalendarView.month) {
      return _MonthCalendar(
        anchor: anchor,
        items: response.items,
        currencyCode: currencyCode,
        bookId: bookId,
        onBillsRequested: onBillsRequested,
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

class _MonthCalendar extends StatefulWidget {
  const _MonthCalendar({
    required this.anchor,
    required this.items,
    required this.currencyCode,
    required this.onBillsRequested,
    this.bookId,
  });

  final DateTime anchor;
  final List<IncomeExpenseCalendarBucket> items;
  final String? currencyCode;
  final int? bookId;
  final ValueChanged<DateTime> onBillsRequested;

  @override
  State<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<_MonthCalendar> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = _defaultSelected(widget.anchor);
  }

  @override
  void didUpdateWidget(covariant _MonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchor.year != widget.anchor.year ||
        oldWidget.anchor.month != widget.anchor.month) {
      _selected = _defaultSelected(widget.anchor);
    }
  }

  DateTime _defaultSelected(DateTime anchor) {
    final now = DateTime.now();
    if (now.year == anchor.year && now.month == anchor.month) {
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(anchor.year, anchor.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final days = _mergeDayBuckets(widget.items);
    final firstWeekday = DateTime(widget.anchor.year, widget.anchor.month).weekday;
    final dayCount = DateTime(widget.anchor.year, widget.anchor.month + 1, 0).day;
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
          date: DateTime(widget.anchor.year, widget.anchor.month, day),
          bucket: days[day] ?? const IncomeExpenseCalendarBucket(),
          currencyCode: widget.currencyCode,
          selected: day == _selected.day,
          bookId: widget.bookId,
          onSelected: (date) => setState(() => _selected = date),
          onBillsRequested: widget.onBillsRequested,
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - 24) / 7;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        // 公历 + 农历 + 收支三行；高度跟内容走，避免格子底部空一大截。
        final minimumHeight = 60 * textScale;
        final maxHeight = 84.0 * textScale;
        final dayCellHeight = cellWidth.clamp(minimumHeight, maxHeight);
        return Column(
          children: [
            _CalendarDayHeader(date: _selected),
            const SizedBox(height: FxSpacing.lg),
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
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: dayCellHeight,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
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

  Map<int, IncomeExpenseCalendarBucket> _mergeDayBuckets(
    List<IncomeExpenseCalendarBucket> items,
  ) {
    final merged = <int, IncomeExpenseCalendarBucket>{};
    for (final item in items) {
      final day = _dayFromPeriod(item.period);
      if (day == null) continue;
      final existing = merged[day];
      merged[day] = existing == null
          ? item
          : IncomeExpenseCalendarBucket(
              period: item.period,
              income: existing.income + item.income,
              expense: existing.expense + item.expense,
              incomeCount: existing.incomeCount + item.incomeCount,
              expenseCount: existing.expenseCount + item.expenseCount,
            );
    }
    return merged;
  }

  int? _dayFromPeriod(String period) {
    final parts = period.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year != widget.anchor.year ||
        month != widget.anchor.month ||
        day == null) {
      return null;
    }
    final maxDay =
        DateTime(widget.anchor.year, widget.anchor.month + 1, 0).day;
    if (day < 1 || day > maxDay) return null;
    return day;
  }
}

/// 月视图顶部：大号公历日 + 干支年 | 农历 星期。
class _CalendarDayHeader extends StatelessWidget {
  const _CalendarDayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final calendar = ChineseCalendarDay.of(date);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: FxTypography.display.copyWith(
              fontSize: 56,
              fontWeight: FontWeight.w600,
              height: 1.0,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            calendar.headerDetail,
            textAlign: TextAlign.center,
            style: FxTypography.body.copyWith(
              color: palette.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.bucket,
    required this.currencyCode,
    required this.selected,
    required this.onSelected,
    required this.onBillsRequested,
    this.bookId,
  });

  final DateTime date;
  final IncomeExpenseCalendarBucket bucket;
  final String? currencyCode;
  final bool selected;
  final int? bookId;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<DateTime> onBillsRequested;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    final locale = Localizations.localeOf(context).toString();
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final calendar = ChineseCalendarDay.of(date);
    final workRest = calendar.workRestLabel;
    final summary =
        '${DateFormat.yMMMd(locale).format(date)} ${calendar.subtitle}'
        '${workRest == null ? '' : ' $workRest'}: '
        '${s.statsCalendarIncome} ${formats.money(bucket.income)}, '
        '${s.statsCalendarExpense} ${formats.money(bucket.expense)}, '
        '${s.statsCalendarTotalCount(bucket.totalCount)}';
    final workRestColor = calendar.isRest
        ? finance.rest
        : calendar.isWorkdayMakeup
        ? finance.work
        : palette.textTertiary;
    final Color fill = selected
        ? palette.primary.withValues(alpha: 0.16)
        : Colors.transparent;
    return Semantics(
      button: true,
      selected: selected,
      label: summary,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onSelected(date);
          final id = bookId;
          if (id == null) {
            onBillsRequested(date);
            return;
          }
          showCalendarDaySummarySheet(
            context,
            date: date,
            bucket: bucket,
            bookId: id,
            currencyCode: currencyCode,
            onViewAllBills: () => onBillsRequested(date),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: palette.primary.withValues(alpha: 0.45))
                : null,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    // 给右上角「班/休」留出固定空位，避免被日期挤掉。
                    padding: EdgeInsets.only(right: workRest == null ? 0 : 12),
                    child: Text(
                      '${date.day}',
                      textAlign: TextAlign.center,
                      style: FxTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    calendar.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: FxTypography.caption.copyWith(
                      color: calendar.isFestivalOrTerm
                          ? finance.holiday
                          : palette.textTertiary,
                      fontSize: 9,
                      height: 1.0,
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CompactAmount(
                            '↑',
                            bucket.income,
                            currencyCode,
                            finance.income,
                          ),
                          _CompactAmount(
                            '↓',
                            bucket.expense,
                            currencyCode,
                            finance.expense,
                          ),
                          Text(
                            '${bucket.totalCount}',
                            style: FxTypography.caption.copyWith(
                              color: palette.textTertiary,
                              fontSize: 9,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (workRest != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    workRest,
                    style: FxTypography.caption.copyWith(
                      color: workRestColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
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
  const _CompactAmount(this.prefix, this.amount, this.currencyCode, this.color);

  final String prefix;
  final double amount;
  final String? currencyCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final value = amount == 0 ? '—' : formats.compact(amount);
    return Text(
      '$prefix$value',
      style: FxTypography.caption.copyWith(
        color: color,
        fontSize: 9,
        height: 1.0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
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
    final itemsByPeriod = _mergeBucketsByPeriod(items);
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

  Map<String, IncomeExpenseCalendarBucket> _mergeBucketsByPeriod(
    List<IncomeExpenseCalendarBucket> items,
  ) {
    final merged = <String, IncomeExpenseCalendarBucket>{};
    for (final item in items) {
      if (!_isValidPeriod(item.period)) continue;
      final existing = merged[item.period];
      merged[item.period] = existing == null
          ? item
          : IncomeExpenseCalendarBucket(
              period: item.period,
              income: existing.income + item.income,
              expense: existing.expense + item.expense,
              incomeCount: existing.incomeCount + item.incomeCount,
              expenseCount: existing.expenseCount + item.expenseCount,
            );
    }
    return merged;
  }

  bool _isValidPeriod(String period) {
    if (view == IncomeExpenseCalendarView.year) {
      final parts = period.split('-');
      if (parts.length != 2) return false;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      return year == anchor.year && month != null && month >= 1 && month <= 12;
    }
    final year = int.tryParse(period);
    return year != null && year >= anchor.year - 4 && year <= anchor.year;
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
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    return Semantics(
      button: true,
      label:
          '$label, ${S.of(context).statsCalendarIncome} ${formats.money(bucket.income)}, '
          '${S.of(context).statsCalendarExpense} ${formats.money(bucket.expense)}',
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
              _CompactAmount('↑', bucket.income, currencyCode, finance.income),
              _CompactAmount(
                '↓',
                bucket.expense,
                currencyCode,
                finance.expense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
