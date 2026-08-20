import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/billing_preferences.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/time/month_window_resolver.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';

part 'bills_event.dart';
part 'bills_state.dart';

/// 账单列表状态机：持 bookId + 月份 + 筛选，负责分页/刷新/切月/写操作。
class BillsBloc extends Bloc<BillsEvent, BillsState> {
  BillsBloc({
    required int? bookId,
    BillService? service,
    DateTime? now,
    int monthStartDay = BillingPreferences.defaultMonthStartDay,
  }) : _service = service ?? BillService(),
       _bookId = bookId,
       _monthStartDay = BillingPreferences.normalizeMonthStartDay(
         monthStartDay,
       ),
       super(BillsState.initial(_initialMonth(now, monthStartDay))) {
    on<BillsBookChanged>(_onBookChanged, transformer: restartable());
    on<BillsRefreshed>(_onRefreshed, transformer: restartable());
    on<BillsNextPageRequested>(_onNextPage, transformer: droppable());
    on<BillsPaginationRetried>(_onPaginationRetried, transformer: droppable());
    on<BillsEntryApplied>(_onEntryApplied, transformer: restartable());
    on<BillsMonthChanged>(_onMonthChanged, transformer: restartable());
    on<BillsMonthStartDayChanged>(
      _onMonthStartDayChanged,
      transformer: restartable(),
    );
    on<BillsFilterApplied>(_onFilterApplied, transformer: restartable());
    on<BillsErrorMessageCleared>(_onErrorMessageCleared);
    on<BillsBillDeleted>(_onDeleted);
    on<BillsConfirmToggled>(_onConfirmToggled);
    on<BillsIncludeToggled>(_onIncludeToggled);
  }

  final BillService _service;
  int? _bookId;
  int _monthStartDay;
  int _loadVersion = 0;

  static DateTime _initialMonth(DateTime? now, int monthStartDay) {
    return MonthWindowResolver.resolveCurrent(
      now ?? DateTime.now(),
      BillingPreferences.normalizeMonthStartDay(monthStartDay),
    ).anchorMonth;
  }

  /// 已加载页数计数器。独立维护而非从 bills.length 反推，
  /// 否则删除一行后长度不再是 pageSize 整数倍会导致重复拉取同一页。
  int _loadedPages = 0;

  int? get bookId => _bookId;

  MonthWindow get _window =>
      MonthWindowResolver.resolveForAnchor(state.month, _monthStartDay);

  /// 列表默认是连续时间流；只有用户或跨页入口显式给出范围时才限制查询。
  BillDateRange? get _queryDateRange => state.filter.dateRange;

  /// 顶部账期汇总始终基于当前可见账期；与连续列表查询解耦。
  BillDateRange get _statisticsDateRange =>
      state.filter.dateRange ??
      BillDateRange(start: _window.start, end: _window.end);

  BillQuery _buildQuery(int pageNum) {
    final f = state.filter;
    final range = _queryDateRange;
    return BillQuery(
      bookId: _bookId!,
      pageNum: pageNum,
      tradeTimeStartTime: range?.startDate,
      tradeTimeEndTime: range?.endDate,
      billTypes: f.billTypes.isEmpty ? null : f.billTypes.toList(),
      amountMin: f.amountMin,
      amountMax: f.amountMax,
      confirm: f.confirm,
      include: f.include,
      accountId: f.accountId,
      payeeId: f.payeeId,
      categoryIds: f.categoryIds,
      tagIds: f.tagIds,
    );
  }

  Future<void> _onBookChanged(
    BillsBookChanged event,
    Emitter<BillsState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != BillsStatus.initial) return;
    _bookId = event.bookId;
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    BillsRefreshed event,
    Emitter<BillsState> emit,
  ) async {
    await _loadFirstPage(emit, refresh: state.status == BillsStatus.loaded);
  }

  Future<void> _onPaginationRetried(
    BillsPaginationRetried event,
    Emitter<BillsState> emit,
  ) async {
    await _onNextPage(const BillsNextPageRequested(), emit);
  }

  Future<void> _onEntryApplied(
    BillsEntryApplied event,
    Emitter<BillsState> emit,
  ) async {
    final bookId = event.request.bookId;
    if (bookId == null) return;
    _bookId = bookId;
    final range = event.request.dateRange;
    final month = range == null
        ? state.month
        : MonthWindowResolver.resolveCurrent(
            range.start,
            _monthStartDay,
          ).anchorMonth;
    emit(
      state.copyWith(
        month: month,
        filter: state.filter.copyWith(
          dateRange: range,
          clearDateRange: range == null,
        ),
        monthStatistics: const {},
        clearStatistics: true,
        clearPaginationError: true,
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _onMonthChanged(
    BillsMonthChanged event,
    Emitter<BillsState> emit,
  ) async {
    final month = MonthWindowResolver.shift(state.month, event.delta);
    emit(state.copyWith(month: month));
  }

  Future<void> _onMonthStartDayChanged(
    BillsMonthStartDayChanged event,
    Emitter<BillsState> emit,
  ) async {
    final day = BillingPreferences.normalizeMonthStartDay(event.day);
    if (day == _monthStartDay) return;
    _monthStartDay = day;
    emit(
      state.copyWith(
        month: _initialMonth(DateTime.now(), day),
        filter: state.filter.copyWith(clearDateRange: true),
        monthStatistics: const {},
        clearStatistics: true,
        clearPaginationError: true,
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterApplied(
    BillsFilterApplied event,
    Emitter<BillsState> emit,
  ) async {
    emit(
      state.copyWith(
        filter: event.filter,
        monthStatistics: const {},
        clearStatistics: true,
        clearPaginationError: true,
      ),
    );
    await _loadFirstPage(emit);
  }

  void _onErrorMessageCleared(
    BillsErrorMessageCleared event,
    Emitter<BillsState> emit,
  ) {
    if (state.errorMessage == null) return;
    emit(state.copyWith());
  }

  bool get _canShowCompleteStatistics {
    final filter = state.filter;
    return filter.billTypes.isEmpty &&
        filter.amountMin == null &&
        filter.amountMax == null &&
        filter.confirm == null &&
        filter.include == null &&
        (filter.categoryIds == null || filter.categoryIds!.isEmpty) &&
        (filter.tagIds == null || filter.tagIds!.isEmpty) &&
        filter.accountId == null &&
        filter.payeeId == null;
  }

  /// 首页加载：拉第一页 + 月度统计。[refresh] 时保留旧列表避免闪烁。
  Future<void> _loadFirstPage(
    Emitter<BillsState> emit, {
    bool refresh = false,
  }) async {
    if (_bookId == null) {
      _loadedPages = 0;
      emit(
        state.copyWith(
          status: BillsStatus.loaded,
          bills: const [],
          total: 0,
          hasMore: false,
          isLoadingMore: false,
          clearStatistics: true,
          monthStatistics: const {},
        ),
      );
      return;
    }
    final version = ++_loadVersion;
    emit(
      state.copyWith(
        status: refresh ? BillsStatus.loaded : BillsStatus.loading,
        isRefreshing: refresh,
        isLoadingMore: false,
      ),
    );
    try {
      final pageFuture = _service.getPage(_buildQuery(1));
      final statsFuture = _canShowCompleteStatistics
          ? _fetchStatistics()
          : Future<BillStatistics?>.value(null);
      final results = await Future.wait([pageFuture, statsFuture]);
      final page = results[0] as BillPage;
      final stats = results[1] as BillStatistics?;
      if (version != _loadVersion) return;
      _loadedPages = 1;
      emit(
        state.copyWith(
          status: BillsStatus.loaded,
          bills: page.rows,
          total: page.total,
          hasMore: page.rows.length < page.total && page.rows.isNotEmpty,
          isLoadingMore: false,
          isRefreshing: false,
          statistics: stats,
          isSummaryAvailable: _canShowCompleteStatistics && stats != null,
          monthStatistics: const {},
          clearPaginationError: true,
        ),
      );
    } on FxApiException catch (error) {
      if (version != _loadVersion) return;
      emit(
        state.copyWith(
          status: refresh ? BillsStatus.loaded : BillsStatus.error,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: error.message,
        ),
      );
    } on Exception {
      if (version != _loadVersion) return;
      emit(
        state.copyWith(
          status: refresh ? BillsStatus.loaded : BillsStatus.error,
          isRefreshing: false,
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onNextPage(
    BillsNextPageRequested event,
    Emitter<BillsState> emit,
  ) async {
    if (_bookId == null ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.status != BillsStatus.loaded) {
      return;
    }
    final version = _loadVersion;
    emit(state.copyWith(isLoadingMore: true, clearPaginationError: true));
    final nextPage = _loadedPages + 1;
    try {
      final page = await _service.getPage(_buildQuery(nextPage));
      if (version != _loadVersion) return;
      // 按 billId 去重，避免删除后页码错位或后端重叠返回造成的重复行（重复 key 会崩溃）。
      final seen = state.bills.map((b) => b.billId).toSet();
      final fresh = page.rows.where((b) => seen.add(b.billId)).toList();
      final merged = [...state.bills, ...fresh];
      final monthStats = _canShowCompleteStatistics
          ? await _fetchMonthStatistics(merged)
          : const <DateTime, BillStatistics>{};
      if (version != _loadVersion) return;
      _loadedPages = nextPage;
      emit(
        state.copyWith(
          bills: merged,
          total: page.total,
          hasMore: merged.length < page.total && page.rows.isNotEmpty,
          isLoadingMore: false,
          monthStatistics: monthStats,
        ),
      );
    } on FxApiException catch (error) {
      if (version != _loadVersion) return;
      emit(
        state.copyWith(
          isLoadingMore: false,
          paginationErrorMessage: error.message,
        ),
      );
    } on Exception {
      if (version != _loadVersion) return;
      emit(state.copyWith(isLoadingMore: false, paginationErrorMessage: ''));
    }
  }

  Future<void> _onDeleted(
    BillsBillDeleted event,
    Emitter<BillsState> emit,
  ) async {
    final bookId = _bookId;
    final version = _loadVersion;
    if (bookId == null || event.bookId != bookId) return;
    try {
      await _service.remove(bookId: bookId, billId: event.billId);
      if (version != _loadVersion || bookId != _bookId) return;
      BillMutations.bump();
      final remaining = state.bills
          .where((bill) => bill.billId != event.billId)
          .toList();
      final stats = _canShowCompleteStatistics
          ? await _fetchStatistics()
          : null;
      if (version != _loadVersion || bookId != _bookId) return;
      emit(
        state.copyWith(
          bills: remaining,
          total: (state.total - 1).clamp(0, 1 << 31),
          statistics: stats,
          isSummaryAvailable: _canShowCompleteStatistics && stats != null,
          monthStatistics: const {},
        ),
      );
    } on FxApiException catch (error) {
      if (version == _loadVersion && bookId == _bookId) {
        emit(
          state.copyWith(
            errorMessage: error.message,
            bumpErrorMessageSerial: true,
          ),
        );
      }
    } on Exception {
      if (version == _loadVersion && bookId == _bookId) {
        emit(
          state.copyWith(
            errorMessage: '删除失败，请稍后重试',
            bumpErrorMessageSerial: true,
          ),
        );
      }
    }
  }

  Future<void> _onConfirmToggled(
    BillsConfirmToggled event,
    Emitter<BillsState> emit,
  ) async {
    final bookId = _bookId;
    final version = _loadVersion;
    if (bookId == null || event.bookId != bookId) return;
    try {
      if (event.confirm) {
        await _service.confirm(bookId: bookId, billId: event.billId);
      } else {
        await _service.unConfirm(bookId: bookId, billId: event.billId);
      }
      if (version != _loadVersion || bookId != _bookId) return;
      BillMutations.bump();
      if (state.filter.confirm != null) {
        await _loadFirstPage(emit, refresh: true);
        return;
      }
      final stats = _canShowCompleteStatistics
          ? await _fetchStatistics()
          : null;
      if (version != _loadVersion || bookId != _bookId) return;
      await _patchLocal(
        emit,
        event.billId,
        confirm: event.confirm,
        stats: stats,
      );
    } on FxApiException catch (error) {
      if (version == _loadVersion && bookId == _bookId) {
        emit(
          state.copyWith(
            errorMessage: error.message,
            bumpErrorMessageSerial: true,
          ),
        );
      }
    } on Exception {
      if (version == _loadVersion && bookId == _bookId) {
        emit(
          state.copyWith(
            errorMessage: '操作失败，请稍后重试',
            bumpErrorMessageSerial: true,
          ),
        );
      }
    }
  }

  Future<void> _onIncludeToggled(
    BillsIncludeToggled event,
    Emitter<BillsState> emit,
  ) async {
    final bookId = _bookId;
    final version = _loadVersion;
    if (bookId == null || event.bookId != bookId) return;
    try {
      if (event.include) {
        await _service.include(bookId: bookId, billId: event.billId);
      } else {
        await _service.exclude(bookId: bookId, billId: event.billId);
      }
      if (version != _loadVersion || bookId != _bookId) return;
      BillMutations.bump();
      if (state.filter.include != null) {
        await _loadFirstPage(emit, refresh: true);
        return;
      }
      final stats = _canShowCompleteStatistics
          ? await _fetchStatistics()
          : null;
      if (version != _loadVersion || bookId != _bookId) return;
      await _patchLocal(
        emit,
        event.billId,
        include: event.include,
        stats: stats,
      );
    } on FxApiException catch (error) {
      if (version == _loadVersion && bookId == _bookId) {
        emit(
          state.copyWith(
            errorMessage: error.message,
            bumpErrorMessageSerial: true,
          ),
        );
      }
    } on Exception {
      if (version == _loadVersion && bookId == _bookId) {
        emit(
          state.copyWith(
            errorMessage: '操作失败，请稍后重试',
            bumpErrorMessageSerial: true,
          ),
        );
      }
    }
  }

  /// 局部更新一条账单的状态字段（不重拉列表）。
  Future<void> _patchLocal(
    Emitter<BillsState> emit,
    int billId, {
    bool? confirm,
    bool? include,
    BillStatistics? stats,
  }) async {
    final updated = state.bills
        .map(
          (b) => b.billId == billId
              ? _copyBillFlags(b, confirm: confirm, include: include)
              : b,
        )
        .toList();
    final monthStats = _canShowCompleteStatistics
        ? await _fetchMonthStatistics(updated, refresh: true)
        : const <DateTime, BillStatistics>{};
    emit(
      state.copyWith(
        bills: updated,
        statistics: stats,
        isSummaryAvailable: _canShowCompleteStatistics && stats != null,
        monthStatistics: monthStats,
      ),
    );
  }

  Future<BillStatistics?> _fetchStatistics() async {
    if (_bookId == null) return null;
    final range = _statisticsDateRange;
    try {
      return await _service.getStatistics(
        bookId: _bookId!,
        tradeTimeStartTime: range.startDate,
        tradeTimeEndTime: range.endDate,
      );
    } on FxApiException catch (_) {
      return state.statistics;
    } catch (_) {
      return state.statistics;
    }
  }

  Future<Map<DateTime, BillStatistics>> _fetchMonthStatistics(
    List<FortuneBillVo> bills, {
    bool refresh = false,
  }) async {
    final bookId = _bookId;
    if (bookId == null || bills.isEmpty || state.filter.dateRange != null) {
      return const {};
    }
    final result = refresh
        ? <DateTime, BillStatistics>{}
        : Map<DateTime, BillStatistics>.of(state.monthStatistics);
    final anchors = <DateTime>{};
    for (final bill in bills) {
      final tradeTime = bill.tradeTime;
      if (tradeTime == null) continue;
      final window = MonthWindowResolver.resolveCurrent(
        tradeTime,
        _monthStartDay,
      );
      anchors.add(window.anchorMonth);
    }
    for (final anchor in anchors) {
      if (result.containsKey(anchor)) continue;
      final window = MonthWindowResolver.resolveForAnchor(
        anchor,
        _monthStartDay,
      );
      try {
        final stats = await _service.getStatistics(
          bookId: bookId,
          tradeTimeStartTime: BillService.dayFormat.format(window.start),
          tradeTimeEndTime: BillService.dayFormat.format(window.end),
        );
        result[anchor] = stats;
      } on Object {
        // 月份汇总失败不阻断时间流；该 section 会只展示日期分组。
      }
    }
    return result;
  }
}

/// 复制账单 VO 并覆盖 confirm/include（VO 无 copyWith，此处显式重建关键字段）。
FortuneBillVo _copyBillFlags(FortuneBillVo b, {bool? confirm, bool? include}) {
  return FortuneBillVo(
    billId: b.billId,
    bookId: b.bookId,
    bookName: b.bookName,
    title: b.title,
    tradeTime: b.tradeTime,
    accountId: b.accountId,
    accountName: b.accountName,
    orderId: b.orderId,
    amount: b.amount,
    currencyCode: b.currencyCode,
    toCurrencyCode: b.toCurrencyCode,
    convertedAmount: b.convertedAmount,
    payeeId: b.payeeId,
    payeeName: b.payeeName,
    billType: b.billType,
    toAccountId: b.toAccountId,
    toAccountName: b.toAccountName,
    confirm: confirm ?? b.confirm,
    include: include ?? b.include,
    remark: b.remark,
    hasFile: b.hasFile,
    categoryAmountPair: b.categoryAmountPair,
    tagList: b.tagList,
    memberList: b.memberList,
    extras: b.extras,
  );
}
