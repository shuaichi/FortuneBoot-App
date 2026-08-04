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
    on<BillsMonthChanged>(_onMonthChanged, transformer: restartable());
    on<BillsMonthStartDayChanged>(
      _onMonthStartDayChanged,
      transformer: restartable(),
    );
    on<BillsFilterApplied>(_onFilterApplied, transformer: restartable());
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

  String get _windowStart => BillService.dayFormat.format(_window.start);

  String get _windowEnd => BillService.dayFormat.format(_window.end);

  BillQuery _buildQuery(int pageNum) {
    final f = state.filter;
    return BillQuery(
      bookId: _bookId!,
      pageNum: pageNum,
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

  Future<void> _onMonthChanged(
    BillsMonthChanged event,
    Emitter<BillsState> emit,
  ) async {
    final m = MonthWindowResolver.shift(state.month, event.delta);
    emit(state.copyWith(month: m, monthStatistics: const {}));
    await _loadFirstPage(emit);
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
        monthStatistics: const {},
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterApplied(
    BillsFilterApplied event,
    Emitter<BillsState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter, monthStatistics: const {}));
    await _loadFirstPage(emit);
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
      ),
    );
    try {
      final page = await _service.getPage(_buildQuery(1));
      final stats = await _fetchStatistics();
      final monthStats = await _fetchMonthStatistics(page.rows, refresh: true);
      if (version != _loadVersion) return;
      _loadedPages = 1;
      emit(
        state.copyWith(
          status: BillsStatus.loaded,
          bills: page.rows,
          total: page.total,
          hasMore: page.rows.length < page.total && page.rows.isNotEmpty,
          isRefreshing: false,
          statistics: stats,
          monthStatistics: monthStats,
        ),
      );
    } on FxApiException catch (e) {
      emit(
        state.copyWith(
          status: BillsStatus.error,
          isRefreshing: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BillsStatus.error,
          isRefreshing: false,
          errorMessage: e.toString(),
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
    emit(state.copyWith(isLoadingMore: true));
    final nextPage = _loadedPages + 1;
    try {
      final page = await _service.getPage(_buildQuery(nextPage));
      if (version != _loadVersion) return;
      // 按 billId 去重，避免删除后页码错位或后端重叠返回造成的重复行（重复 key 会崩溃）。
      final seen = state.bills.map((b) => b.billId).toSet();
      final fresh = page.rows.where((b) => seen.add(b.billId)).toList();
      final merged = [...state.bills, ...fresh];
      final monthStats = await _fetchMonthStatistics(merged);
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
    } on FxApiException catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> _onDeleted(
    BillsBillDeleted event,
    Emitter<BillsState> emit,
  ) async {
    if (_bookId == null) return;
    await _service.remove(bookId: _bookId!, billId: event.billId);
    BillMutations.bump();
    final remaining = state.bills
        .where((b) => b.billId != event.billId)
        .toList();
    final stats = await _fetchStatistics();
    final monthStats = await _fetchMonthStatistics(remaining, refresh: true);
    emit(
      state.copyWith(
        bills: remaining,
        total: (state.total - 1).clamp(0, 1 << 31),
        statistics: stats,
        monthStatistics: monthStats,
      ),
    );
  }

  Future<void> _onConfirmToggled(
    BillsConfirmToggled event,
    Emitter<BillsState> emit,
  ) async {
    if (_bookId == null) return;
    if (event.confirm) {
      await _service.confirm(bookId: _bookId!, billId: event.billId);
    } else {
      await _service.unConfirm(bookId: _bookId!, billId: event.billId);
    }
    // 确认状态影响是否计入余额/统计，需重拉汇总并通知其它页刷新。
    final stats = await _fetchStatistics();
    BillMutations.bump();
    await _patchLocal(emit, event.billId, confirm: event.confirm, stats: stats);
  }

  Future<void> _onIncludeToggled(
    BillsIncludeToggled event,
    Emitter<BillsState> emit,
  ) async {
    if (_bookId == null) return;
    if (event.include) {
      await _service.include(bookId: _bookId!, billId: event.billId);
    } else {
      await _service.exclude(bookId: _bookId!, billId: event.billId);
    }
    final stats = await _fetchStatistics();
    BillMutations.bump();
    await _patchLocal(emit, event.billId, include: event.include, stats: stats);
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
    final monthStats = await _fetchMonthStatistics(updated, refresh: true);
    emit(
      state.copyWith(
        bills: updated,
        statistics: stats,
        monthStatistics: monthStats,
      ),
    );
  }

  Future<BillStatistics?> _fetchStatistics() async {
    if (_bookId == null) return null;
    try {
      return await _service.getStatistics(
        bookId: _bookId!,
        tradeTimeStartTime: _windowStart,
        tradeTimeEndTime: _windowEnd,
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
    if (bookId == null || bills.isEmpty) return const {};
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
