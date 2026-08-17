import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/billing_preferences.dart';
import 'package:fortuneboot/core/time/month_window_resolver.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
import 'package:intl/intl.dart';

part 'stats_event.dart';
part 'stats_state.dart';

/// 已解析的区间：起止日期 + 趋势粒度 + 代表时间点。
class _Window {
  final DateTime start;
  final DateTime end;
  final int granularity; // 日1 / 月3
  final DateTime timePoint;
  const _Window(this.start, this.end, this.granularity, this.timePoint);
}

/// 统计页 Bloc：切区间/类型/账本时并发重拉（趋势+分类+标签+交易对象+概览）。
///
/// 每组结果落入独立的 [StatsSection]，任一失败仅该卡兜底，不拖垮整页。
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsService _statsService;
  final BillService _billService;

  int? _bookId;
  static const int _minCalendarYear = 1900;
  static const int _maxCalendarYear = 2100;
  static const int _historyYearSpan = 5;

  int _monthStartDay;
  int _loadVersion = 0;
  int _calendarLoadVersion = 0;

  StatsBloc({
    StatsService? statsService,
    BillService? billService,
    int? bookId,
    String? currencyCode,
    int monthStartDay = BillingPreferences.defaultMonthStartDay,
  }) : _statsService = statsService ?? StatsService(),
       _billService = billService ?? BillService(),
       _bookId = bookId,
       _monthStartDay = BillingPreferences.normalizeMonthStartDay(
         monthStartDay,
       ),
       super(StatsState(hasBook: bookId != null, currencyCode: currencyCode)) {
    on<StatsBookChanged>(_onBookChanged, transformer: restartable());
    on<StatsRefreshed>(_onRefreshed, transformer: restartable());
    on<StatsRangeChanged>(_onRangeChanged, transformer: restartable());
    on<StatsTypeChanged>(_onTypeChanged, transformer: restartable());
    on<StatsMonthStartDayChanged>(
      _onMonthStartDayChanged,
      transformer: restartable(),
    );
    on<StatsCalendarViewChanged>(
      _onCalendarViewChanged,
      transformer: restartable(),
    );
    on<StatsCalendarNavigate>(_onCalendarNavigate, transformer: restartable());
    on<StatsCalendarDrilledDown>(
      _onCalendarDrilledDown,
      transformer: restartable(),
    );
    on<StatsCalendarRetried>(_onCalendarRetried, transformer: restartable());
  }

  Future<void> _onBookChanged(
    StatsBookChanged event,
    Emitter<StatsState> emit,
  ) async {
    _bookId = event.bookId;
    if (_bookId == null) {
      emit(
        state.copyWith(
          hasBook: false,
          overview: const StatsSection.loading(),
          trends: const StatsSection.loading(),
          categories: const StatsSection.loading(),
          tags: const StatsSection.loading(),
          payees: const StatsSection.loading(),
          calendar: const StatsSection.loading(),
        ),
      );
      return;
    }
    emit(_resetLoading(state.copyWith(hasBook: true)));
    await _loadAll(emit);
  }

  Future<void> _onRefreshed(
    StatsRefreshed event,
    Emitter<StatsState> emit,
  ) async {
    if (_bookId == null) return;
    await _loadAll(emit);
  }

  Future<void> _onRangeChanged(
    StatsRangeChanged event,
    Emitter<StatsState> emit,
  ) async {
    emit(
      _resetLoading(
        state.copyWith(
          range: event.range,
          customStart: event.customStart,
          customEnd: event.customEnd,
        ),
      ),
    );
    if (_bookId == null) return;
    await _loadAll(emit);
  }

  Future<void> _onTypeChanged(
    StatsTypeChanged event,
    Emitter<StatsState> emit,
  ) async {
    if (event.type == state.type) return;
    final shouldReloadCalendar =
        state.calendar.status == StatsSectionStatus.loading;
    emit(_resetAnalyticsLoading(state.copyWith(type: event.type)));
    if (_bookId == null) return;
    if (shouldReloadCalendar) {
      await Future.wait([_loadAnalytics(emit), _loadCalendar(emit)]);
      return;
    }
    await _loadAnalytics(emit);
  }

  Future<void> _onMonthStartDayChanged(
    StatsMonthStartDayChanged event,
    Emitter<StatsState> emit,
  ) async {
    final day = BillingPreferences.normalizeMonthStartDay(event.day);
    if (day == _monthStartDay) return;
    _monthStartDay = day;
    if (_bookId == null || state.range != StatsRange.month) return;
    emit(_resetLoading(state, includeCalendar: false));
    await _loadAll(emit, includeCalendar: false);
  }

  Future<void> _onCalendarViewChanged(
    StatsCalendarViewChanged event,
    Emitter<StatsState> emit,
  ) async {
    if (event.view == state.calendarView) return;
    final anchor = _normalizeCalendarAnchor(state.calendarAnchor, event.view);
    emit(
      state.copyWith(
        calendarView: event.view,
        calendarAnchor: anchor,
        calendar: const StatsSection.loading(),
      ),
    );
    await _loadCalendar(emit);
  }

  Future<void> _onCalendarNavigate(
    StatsCalendarNavigate event,
    Emitter<StatsState> emit,
  ) async {
    final anchor = switch (state.calendarView) {
      IncomeExpenseCalendarView.month => DateTime(
        state.calendarAnchor.year,
        state.calendarAnchor.month + event.delta,
      ),
      IncomeExpenseCalendarView.year => DateTime(
        state.calendarAnchor.year + event.delta,
      ),
      IncomeExpenseCalendarView.history => DateTime(
        state.calendarAnchor.year + event.delta * _historyYearSpan,
      ),
    };
    if (!_isValidCalendarAnchor(anchor, state.calendarView)) return;
    emit(
      state.copyWith(
        calendarAnchor: anchor,
        calendar: const StatsSection.loading(),
      ),
    );
    await _loadCalendar(emit);
  }

  Future<void> _onCalendarDrilledDown(
    StatsCalendarDrilledDown event,
    Emitter<StatsState> emit,
  ) async {
    if (!_isValidCalendarAnchor(event.anchor, event.view)) return;
    emit(
      state.copyWith(
        calendarView: event.view,
        calendarAnchor: event.anchor,
        calendar: const StatsSection.loading(),
      ),
    );
    await _loadCalendar(emit);
  }

  Future<void> _onCalendarRetried(
    StatsCalendarRetried event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(calendar: const StatsSection.loading()));
    await _loadCalendar(emit);
  }

  StatsState _resetLoading(StatsState s, {bool includeCalendar = true}) =>
      s.copyWith(
        overview: const StatsSection.loading(),
        trends: const StatsSection.loading(),
        categories: const StatsSection.loading(),
        tags: const StatsSection.loading(),
        payees: const StatsSection.loading(),
        calendar: includeCalendar ? const StatsSection.loading() : s.calendar,
      );

  StatsState _resetAnalyticsLoading(StatsState s) => s.copyWith(
    trends: const StatsSection.loading(),
    categories: const StatsSection.loading(),
    tags: const StatsSection.loading(),
    payees: const StatsSection.loading(),
  );

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  /// 依当前区间算起止 + 粒度 + 代表时间点。
  _Window _resolveWindow() {
    final now = DateTime.now();
    switch (state.range) {
      case StatsRange.week:
        // 周一 ~ 周日（本周）。DateTime.weekday: 周一=1..周日=7。
        final monday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return _Window(monday, sunday, 1, _noon(now));
      case StatsRange.month:
        final window = MonthWindowResolver.resolveCurrent(now, _monthStartDay);
        return _Window(window.start, window.end, 1, _noon(now));
      case StatsRange.year:
        final start = DateTime(now.year);
        final end = DateTime(now.year, 12, 31);
        return _Window(start, end, 3, _noon(now));
      case StatsRange.custom:
        final start = state.customStart ?? DateTime(now.year, now.month);
        final end = state.customEnd ?? DateTime(now.year, now.month + 1, 0);
        // 自定义跨度超 90 天用月粒度，否则日粒度。
        final span = end.difference(start).inDays;
        final granularity = span > 90 ? 3 : 1;
        final mid = start.add(Duration(days: span ~/ 2));
        return _Window(start, end, granularity, _noon(mid));
    }
  }

  DateTime _noon(DateTime d) => DateTime(d.year, d.month, d.day, 12);

  /// 并发拉取全部；各任务捕获自身异常写入对应 section。
  Future<void> _loadAll(
    Emitter<StatsState> emit, {
    bool includeCalendar = true,
  }) async {
    final version = ++_loadVersion;
    final bookId = _bookId;
    if (bookId == null) return;

    final w = _resolveWindow();
    final startStr = _day.format(w.start);
    final endStr = _day.format(w.end);
    final isExpense = state.type == StatsType.expense;
    final calendarVersion = includeCalendar ? ++_calendarLoadVersion : null;
    final calendarFuture = includeCalendar
        ? _calendarSection(
            bookId: bookId,
            view: state.calendarView,
            anchor: state.calendarAnchor,
          )
        : null;

    final results = await Future.wait<_SectionResult>([
      _guard<BillStatistics>(
        () => _billService.getStatistics(
          bookId: bookId,
          tradeTimeStartTime: startStr,
          tradeTimeEndTime: endStr,
        ),
        _SectionKey.overview,
      ),
      _guard<List<TrendPoint>>(
        () => state.range == StatsRange.month
            ? _buildMonthlyTrend(
                bookId: bookId,
                start: w.start,
                end: w.end,
                billType: isExpense
                    ? FxBillType.expense.value
                    : FxBillType.income.value,
              )
            : isExpense
            ? _statsService.getExpenseTrends(
                bookId: bookId,
                timeGranularity: w.granularity,
                timePoint: w.timePoint,
              )
            : _statsService.getIncomeTrends(
                bookId: bookId,
                timeGranularity: w.granularity,
                timePoint: w.timePoint,
              ),
        _SectionKey.trends,
      ),
      _guard<List<PieSlice>>(
        () => isExpense
            ? _statsService.getCategoryExpense(
                bookId: bookId,
                start: w.start,
                end: w.end,
              )
            : _statsService.getCategoryIncome(
                bookId: bookId,
                start: w.start,
                end: w.end,
              ),
        _SectionKey.categories,
      ),
      _guard<List<BarItem>>(
        () => isExpense
            ? _statsService.getTagExpense(
                bookId: bookId,
                start: w.start,
                end: w.end,
              )
            : _statsService.getTagIncome(
                bookId: bookId,
                start: w.start,
                end: w.end,
              ),
        _SectionKey.tags,
      ),
      _guard<List<PieSlice>>(
        () => isExpense
            ? _statsService.getPayeeExpense(
                bookId: bookId,
                start: w.start,
                end: w.end,
              )
            : _statsService.getPayeeIncome(
                bookId: bookId,
                start: w.start,
                end: w.end,
              ),
        _SectionKey.payees,
      ),
    ]);

    if (version != _loadVersion) return;
    final calendar = calendarFuture == null ? null : await calendarFuture;
    if (version != _loadVersion || bookId != _bookId) return;

    var next = state.copyWith(hasBook: true);
    for (final r in results) {
      next = _apply(next, r);
    }
    if (calendar != null && calendarVersion == _calendarLoadVersion) {
      next = next.copyWith(calendar: calendar);
    }
    emit(next);
  }

  Future<void> _loadAnalytics(Emitter<StatsState> emit) async {
    final version = ++_loadVersion;
    final bookId = _bookId;
    if (bookId == null) return;

    final window = _resolveWindow();
    final isExpense = state.type == StatsType.expense;
    final results = await Future.wait<_SectionResult>([
      _guard<List<TrendPoint>>(
        () => state.range == StatsRange.month
            ? _buildMonthlyTrend(
                bookId: bookId,
                start: window.start,
                end: window.end,
                billType: isExpense
                    ? FxBillType.expense.value
                    : FxBillType.income.value,
              )
            : isExpense
            ? _statsService.getExpenseTrends(
                bookId: bookId,
                timeGranularity: window.granularity,
                timePoint: window.timePoint,
              )
            : _statsService.getIncomeTrends(
                bookId: bookId,
                timeGranularity: window.granularity,
                timePoint: window.timePoint,
              ),
        _SectionKey.trends,
      ),
      _guard<List<PieSlice>>(
        () => isExpense
            ? _statsService.getCategoryExpense(
                bookId: bookId,
                start: window.start,
                end: window.end,
              )
            : _statsService.getCategoryIncome(
                bookId: bookId,
                start: window.start,
                end: window.end,
              ),
        _SectionKey.categories,
      ),
      _guard<List<BarItem>>(
        () => isExpense
            ? _statsService.getTagExpense(
                bookId: bookId,
                start: window.start,
                end: window.end,
              )
            : _statsService.getTagIncome(
                bookId: bookId,
                start: window.start,
                end: window.end,
              ),
        _SectionKey.tags,
      ),
      _guard<List<PieSlice>>(
        () => isExpense
            ? _statsService.getPayeeExpense(
                bookId: bookId,
                start: window.start,
                end: window.end,
              )
            : _statsService.getPayeeIncome(
                bookId: bookId,
                start: window.start,
                end: window.end,
              ),
        _SectionKey.payees,
      ),
    ]);

    if (version != _loadVersion || bookId != _bookId) return;
    var next = state;
    for (final result in results) {
      next = _apply(next, result);
    }
    emit(next);
  }

  DateTime _normalizeCalendarAnchor(
    DateTime anchor,
    IncomeExpenseCalendarView view,
  ) {
    final minYear = view == IncomeExpenseCalendarView.history
        ? _minCalendarYear + _historyYearSpan - 1
        : _minCalendarYear;
    return DateTime(anchor.year.clamp(minYear, _maxCalendarYear), anchor.month);
  }

  bool _isValidCalendarAnchor(
    DateTime anchor,
    IncomeExpenseCalendarView view,
  ) => switch (view) {
    IncomeExpenseCalendarView.month || IncomeExpenseCalendarView.year =>
      anchor.year >= _minCalendarYear && anchor.year <= _maxCalendarYear,
    IncomeExpenseCalendarView.history =>
      anchor.year - (_historyYearSpan - 1) >= _minCalendarYear &&
          anchor.year <= _maxCalendarYear,
  };

  Future<void> _loadCalendar(Emitter<StatsState> emit) async {
    final version = ++_calendarLoadVersion;
    final bookId = _bookId;
    if (bookId == null) return;
    final section = await _calendarSection(
      bookId: bookId,
      view: state.calendarView,
      anchor: state.calendarAnchor,
    );
    if (version != _calendarLoadVersion || bookId != _bookId) return;
    emit(state.copyWith(calendar: section));
  }

  Future<StatsSection<IncomeExpenseCalendarResponse>> _calendarSection({
    required int bookId,
    required IncomeExpenseCalendarView view,
    required DateTime anchor,
  }) async {
    final request = switch (view) {
      IncomeExpenseCalendarView.month => IncomeExpenseCalendarRequest.month(
        bookId: bookId,
        year: anchor.year,
        month: anchor.month,
      ),
      IncomeExpenseCalendarView.year => IncomeExpenseCalendarRequest.year(
        bookId: bookId,
        year: anchor.year,
      ),
      IncomeExpenseCalendarView.history => IncomeExpenseCalendarRequest.history(
        bookId: bookId,
        startYear: anchor.year - (_historyYearSpan - 1),
        endYear: anchor.year,
      ),
    };
    try {
      final response = await _statsService.getIncomeExpenseCalendar(
        request: request,
      );
      return StatsSection.ready(response);
    } on FxApiException catch (e) {
      return StatsSection.error(e.message);
    } on Object catch (e) {
      return StatsSection.error(e.toString());
    }
  }

  Future<List<TrendPoint>> _buildMonthlyTrend({
    required int bookId,
    required DateTime start,
    required DateTime end,
    required int billType,
  }) async {
    final daily = <DateTime, double>{};
    var pageNum = 1;
    var loaded = 0;
    while (true) {
      final page = await _billService.getPage(
        BillQuery(
          bookId: bookId,
          pageNum: pageNum,
          pageSize: 500,
          billTypes: [billType],
          tradeTimeStartTime: _day.format(start),
          tradeTimeEndTime: _day.format(end),
          include: true,
        ),
      );
      loaded += page.rows.length;
      for (final bill in page.rows) {
        final tradeTime = bill.tradeTime;
        if (tradeTime == null) continue;
        final day = DateTime(tradeTime.year, tradeTime.month, tradeTime.day);
        daily[day] = (daily[day] ?? 0) + bill.displayAmount.abs();
      }
      if (page.rows.isEmpty || loaded >= page.total) break;
      pageNum++;
    }
    final days = daily.keys.toList()..sort();
    return [
      for (final day in days)
        TrendPoint(name: '${day.month}/${day.day}', value: daily[day] ?? 0),
    ];
  }

  /// 执行单个拉取任务并封装为成功/失败结果，绝不抛出。
  Future<_SectionResult> _guard<T>(
    Future<T> Function() task,
    _SectionKey key,
  ) async {
    try {
      final value = await task();
      return _SectionResult(key: key, value: value);
    } on FxApiException catch (e) {
      return _SectionResult(key: key, error: e.message);
    } on Object catch (e) {
      return _SectionResult(key: key, error: e.toString());
    }
  }

  StatsState _apply(StatsState s, _SectionResult r) {
    final err = r.error;
    switch (r.key) {
      case _SectionKey.overview:
        return s.copyWith(
          overview: err != null
              ? StatsSection<BillStatistics>.error(err)
              : StatsSection<BillStatistics>.ready(r.value! as BillStatistics),
        );
      case _SectionKey.trends:
        return s.copyWith(
          trends: err != null
              ? StatsSection<List<TrendPoint>>.error(err)
              : StatsSection<List<TrendPoint>>.ready(
                  r.value! as List<TrendPoint>,
                ),
        );
      case _SectionKey.categories:
        return s.copyWith(
          categories: err != null
              ? StatsSection<List<PieSlice>>.error(err)
              : StatsSection<List<PieSlice>>.ready(r.value! as List<PieSlice>),
        );
      case _SectionKey.tags:
        return s.copyWith(
          tags: err != null
              ? StatsSection<List<BarItem>>.error(err)
              : StatsSection<List<BarItem>>.ready(r.value! as List<BarItem>),
        );
      case _SectionKey.payees:
        return s.copyWith(
          payees: err != null
              ? StatsSection<List<PieSlice>>.error(err)
              : StatsSection<List<PieSlice>>.ready(r.value! as List<PieSlice>),
        );
    }
  }
}

enum _SectionKey { overview, trends, categories, tags, payees }

class _SectionResult {
  final _SectionKey key;
  final Object? value;
  final String? error;
  const _SectionResult({required this.key, this.value, this.error});
}
