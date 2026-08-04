import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
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

  StatsBloc({
    StatsService? statsService,
    BillService? billService,
    int? bookId,
    String? currencyCode,
  }) : _statsService = statsService ?? StatsService(),
       _billService = billService ?? BillService(),
       _bookId = bookId,
       super(StatsState(hasBook: bookId != null, currencyCode: currencyCode)) {
    on<StatsBookChanged>(_onBookChanged);
    on<StatsRefreshed>(_onRefreshed);
    on<StatsRangeChanged>(_onRangeChanged);
    on<StatsTypeChanged>(_onTypeChanged);
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
    emit(_resetLoading(state.copyWith(type: event.type)));
    if (_bookId == null) return;
    await _loadAll(emit);
  }

  StatsState _resetLoading(StatsState s) => s.copyWith(
    overview: const StatsSection.loading(),
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
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1, 0);
        return _Window(start, end, 1, _noon(now));
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
  Future<void> _loadAll(Emitter<StatsState> emit) async {
    final bookId = _bookId;
    if (bookId == null) return;

    final w = _resolveWindow();
    final startStr = _day.format(w.start);
    final endStr = _day.format(w.end);
    final isExpense = state.type == StatsType.expense;

    var next = state.copyWith(hasBook: true);

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
        () => isExpense
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

    for (final r in results) {
      next = _apply(next, r);
    }
    emit(next);
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
