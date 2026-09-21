import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
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
    required this.onBillsRequested,
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
  });

  final IncomeExpenseCalendarResponse response;
  final IncomeExpenseCalendarView view;
  final DateTime anchor;
  final String? currencyCode;
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

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.anchor,
    required this.items,
    required this.currencyCode,
    required this.onBillsRequested,
  });

  final DateTime anchor;
  final List<IncomeExpenseCalendarBucket> items;
  final String? currencyCode;
  final ValueChanged<DateTime> onBillsRequested;

  @override
  Widget build(BuildContext context) {
    final days = _mergeDayBuckets(items);
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
          onBillsRequested: onBillsRequested,
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - 24) / 7;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final minimumHeight = 72 * textScale;
        final maxHeight = 120.0 * textScale;
        final dayCellHeight = cellWidth.clamp(minimumHeight, maxHeight);
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
    if (year != anchor.year || month != anchor.month || day == null) {
      return null;
    }
    final maxDay = DateTime(anchor.year, anchor.month + 1, 0).day;
    if (day < 1 || day > maxDay) return null;
    return day;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.bucket,
    required this.currencyCode,
    required this.onBillsRequested,
  });

  final DateTime date;
  final IncomeExpenseCalendarBucket bucket;
  final String? currencyCode;
  final ValueChanged<DateTime> onBillsRequested;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    final locale = Localizations.localeOf(context).toString();
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final summary =
        '${DateFormat.yMMMd(locale).format(date)}: '
        '${s.statsCalendarIncome} ${formats.money(bucket.income)}, '
        '${s.statsCalendarExpense} ${formats.money(bucket.expense)}, '
        '${s.statsCalendarTotalCount(bucket.totalCount)}';
    return Semantics(
      button: true,
      label: summary,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDaySummary(
          context,
          date,
          bucket,
          currencyCode,
          onBillsRequested,
        ),
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
                DateFormat.d(locale).format(date),
                style: FxTypography.caption,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
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
                          ),
                        ),
                      ],
                    ),
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
      style: FxTypography.caption.copyWith(color: color, fontSize: 9),
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

void _showDaySummary(
  BuildContext context,
  DateTime date,
  IncomeExpenseCalendarBucket bucket,
  String? currencyCode,
  ValueChanged<DateTime> onBillsRequested,
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
          const SizedBox(height: FxSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onBillsRequested(date);
              },
              child: Text(s.statsCalendarViewBills),
            ),
          ),
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
  Widget build(BuildContext context) {
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    return Row(
      children: [
        Expanded(child: Text(label, style: FxTypography.body)),
        FxMoneyText(
          amount: amount,
          currencyCode: currencyCode,
          color: color,
          masked: formats.masked,
        ),
      ],
    );
  }
}
