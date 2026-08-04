import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/billing_preferences.dart';
import 'package:fortuneboot/core/time/month_window_resolver.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_service.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:intl/intl.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// 看板 Bloc：启动/切账本/下拉刷新时并发拉取 5 组数据。
///
/// 每组结果落入独立的 [DashboardSection]，任一失败仅该卡片兜底，不拖垮整页。
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;
  final BillService _billService;

  int? _bookId;
  int? _groupId;
  int _monthStartDay;
  int _loadVersion = 0;

  DashboardBloc({
    DashboardService? dashboardService,
    BillService? billService,
    int? bookId,
    int? groupId,
    String? currencyCode,
    int monthStartDay = BillingPreferences.defaultMonthStartDay,
  }) : _dashboardService = dashboardService ?? DashboardService(),
       _billService = billService ?? BillService(),
       _bookId = bookId,
       _groupId = groupId,
       _monthStartDay = BillingPreferences.normalizeMonthStartDay(
         monthStartDay,
       ),
       super(
         DashboardState(hasBook: bookId != null, currencyCode: currencyCode),
       ) {
    on<DashboardBookChanged>(_onBookChanged, transformer: restartable());
    on<DashboardRefreshed>(_onRefreshed, transformer: restartable());
    on<DashboardMonthStartDayChanged>(
      _onMonthStartDayChanged,
      transformer: restartable(),
    );
  }

  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  Future<void> _onBookChanged(
    DashboardBookChanged event,
    Emitter<DashboardState> emit,
  ) async {
    _bookId = event.bookId;
    _groupId = event.groupId;
    if (_bookId == null) {
      emit(const DashboardState());
      return;
    }
    // 重置为全 loading 后并发拉取。
    emit(
      state.copyWith(
        hasBook: true,
        assets: const DashboardSection.loading(),
        monthStats: const DashboardSection.loading(),
        trends: const DashboardSection.loading(),
        categories: const DashboardSection.loading(),
        recentBills: const DashboardSection.loading(),
      ),
    );
    await _loadAll(emit);
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    if (_bookId == null) {
      emit(const DashboardState());
      return;
    }
    await _loadAll(emit);
  }

  Future<void> _onMonthStartDayChanged(
    DashboardMonthStartDayChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final day = BillingPreferences.normalizeMonthStartDay(event.day);
    if (day == _monthStartDay) return;
    _monthStartDay = day;
    if (_bookId == null) return;
    emit(
      state.copyWith(
        assets: const DashboardSection.loading(),
        monthStats: const DashboardSection.loading(),
        trends: const DashboardSection.loading(),
        categories: const DashboardSection.loading(),
        recentBills: const DashboardSection.loading(),
      ),
    );
    await _loadAll(emit);
  }

  /// 并发拉取全部；各任务捕获自身异常写入对应 section。
  Future<void> _loadAll(Emitter<DashboardState> emit) async {
    final version = ++_loadVersion;
    final bookId = _bookId;
    if (bookId == null) return;

    final now = DateTime.now();
    final window = MonthWindowResolver.resolveCurrent(now, _monthStartDay);
    final startStr = _day.format(window.start);
    final endStr = _day.format(window.end);

    var next = state.copyWith(hasBook: true);

    final results = await Future.wait<_SectionResult>([
      _guard<AssetsLiabilities>(
        () => _groupId == null
            ? Future.value(const AssetsLiabilities())
            : _dashboardService.getAssetsLiabilities(_groupId!),
        _SectionKey.assets,
      ),
      _guard<BillStatistics>(
        () => _billService.getStatistics(
          bookId: bookId,
          tradeTimeStartTime: startStr,
          tradeTimeEndTime: endStr,
        ),
        _SectionKey.monthStats,
      ),
      _guard<List<TrendPoint>>(
        () => _buildExpenseTrend(
          bookId: bookId,
          start: window.start,
          end: window.end,
        ),
        _SectionKey.trends,
      ),
      _guard<List<CategorySlice>>(
        () => _dashboardService.getCategoryExpense(
          bookId: bookId,
          start: window.start,
          end: window.end,
        ),
        _SectionKey.categories,
      ),
      _guard<BillPage>(
        () => _billService.getPage(BillQuery(bookId: bookId, pageSize: 3)),
        _SectionKey.recentBills,
      ),
    ]);

    if (version != _loadVersion) return;
    for (final r in results) {
      next = _apply(next, r);
    }
    emit(next);
  }

  Future<List<TrendPoint>> _buildExpenseTrend({
    required int bookId,
    required DateTime start,
    required DateTime end,
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
          billTypes: [FxBillType.expense.value],
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

  DashboardState _apply(DashboardState s, _SectionResult r) {
    final err = r.error;
    switch (r.key) {
      case _SectionKey.assets:
        return s.copyWith(
          assets: err != null
              ? DashboardSection<AssetsLiabilities>.error(err)
              : DashboardSection<AssetsLiabilities>.ready(
                  r.value! as AssetsLiabilities,
                ),
        );
      case _SectionKey.monthStats:
        return s.copyWith(
          monthStats: err != null
              ? DashboardSection<BillStatistics>.error(err)
              : DashboardSection<BillStatistics>.ready(
                  r.value! as BillStatistics,
                ),
        );
      case _SectionKey.trends:
        return s.copyWith(
          trends: err != null
              ? DashboardSection<List<TrendPoint>>.error(err)
              : DashboardSection<List<TrendPoint>>.ready(
                  r.value! as List<TrendPoint>,
                ),
        );
      case _SectionKey.categories:
        return s.copyWith(
          categories: err != null
              ? DashboardSection<List<CategorySlice>>.error(err)
              : DashboardSection<List<CategorySlice>>.ready(
                  (r.value! as List<CategorySlice>).take(3).toList(),
                ),
        );
      case _SectionKey.recentBills:
        return s.copyWith(
          recentBills: err != null
              ? DashboardSection<List<FortuneBillVo>>.error(err)
              : DashboardSection<List<FortuneBillVo>>.ready(
                  (r.value! as BillPage).rows,
                ),
        );
    }
  }
}

enum _SectionKey { assets, monthStats, trends, categories, recentBills }

class _SectionResult {
  final _SectionKey key;
  final Object? value;
  final String? error;
  const _SectionResult({required this.key, this.value, this.error});
}
