import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
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

  DashboardBloc({
    DashboardService? dashboardService,
    BillService? billService,
    int? bookId,
    int? groupId,
    String? currencyCode,
  }) : _dashboardService = dashboardService ?? DashboardService(),
       _billService = billService ?? BillService(),
       _bookId = bookId,
       _groupId = groupId,
       super(
         DashboardState(hasBook: bookId != null, currencyCode: currencyCode),
       ) {
    on<DashboardBookChanged>(_onBookChanged);
    on<DashboardRefreshed>(_onRefreshed);
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

  /// 并发拉取全部；各任务捕获自身异常写入对应 section。
  Future<void> _loadAll(Emitter<DashboardState> emit) async {
    final bookId = _bookId;
    if (bookId == null) return;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final startStr = _day.format(monthStart);
    final endStr = _day.format(monthEnd);

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
        () =>
            _dashboardService.getExpenseTrends(bookId: bookId, timePoint: now),
        _SectionKey.trends,
      ),
      _guard<List<CategorySlice>>(
        () => _dashboardService.getCategoryExpense(
          bookId: bookId,
          start: monthStart,
          end: monthEnd,
        ),
        _SectionKey.categories,
      ),
      _guard<BillPage>(
        () => _billService.getPage(BillQuery(bookId: bookId, pageSize: 3)),
        _SectionKey.recentBills,
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
