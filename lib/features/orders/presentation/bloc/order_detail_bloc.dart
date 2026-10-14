import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/generated/l10n.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

/// 单据详情状态机：detail、entries 与 summary 分别请求，动作成功后三者一起刷新。
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  static const int pageSize = 20;

  final OrdersService _service;
  final int bookId;
  final int orderId;

  OrderDetailBloc({
    required this.bookId,
    required this.orderId,
    OrdersService? service,
  }) : _service = service ?? OrdersService(),
       super(const OrderDetailState()) {
    on<OrderDetailLoaded>(_onLoaded);
    on<OrderDetailRefreshed>(_onLoaded);
    on<OrderDetailEntryStatusChanged>(_onEntryStatusChanged);
    on<OrderDetailLoadMoreRequested>(_onLoadMore);
    on<OrderDetailEntryActionRequested>(_onEntryAction);
    on<OrderDetailTransitionRequested>(_onTransition);
  }

  Future<void> _onLoaded(
    OrderDetailEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    // 删除完成后不再刷新同一实体：BillMutations.bump 触发的队列刷新在此丢弃，
    // 避免对已删除单据发出多余的 getDetail（返回 404）。
    if (state.removed) return;
    final generation = state.requestGeneration + 1;
    emit(
      state.copyWith(
        status: OrderDetailStatus.loading,
        requestGeneration: generation,
        entries: const [],
        page: 1,
        total: 0,
        errorMessage: null,
      ),
    );
    try {
      final results = await Future.wait<Object>([
        _service.getDetail(bookId: bookId, orderId: orderId),
        _service.getEntries(
          bookId: bookId,
          orderId: orderId,
          pageNum: 1,
          pageSize: pageSize,
          entryStatus: state.entryStatus,
        ),
        _service.getSummary(bookId: bookId),
      ]);
      if (isClosed || generation != state.requestGeneration) return;
      final detail = results[0] as FinanceOrderDetail;
      final entries = results[1] as FinanceOrderEntryPage;
      final summary = results[2] as FinanceOrderSummary;
      emit(
        state.copyWith(
          status: OrderDetailStatus.ready,
          detail: detail,
          entries: entries.rows,
          total: entries.total,
          page: 1,
          summary: summary,
          errorMessage: null,
        ),
      );
    } on FxApiException catch (error) {
      if (!isClosed && generation == state.requestGeneration) {
        emit(
          state.copyWith(
            status: OrderDetailStatus.error,
            errorMessage: error.message,
          ),
        );
      }
    } on Object {
      if (!isClosed && generation == state.requestGeneration) {
        emit(
          state.copyWith(
            status: OrderDetailStatus.error,
            errorMessage: S.current.dashboardLoadFailed,
          ),
        );
      }
    }
  }

  Future<void> _onEntryStatusChanged(
    OrderDetailEntryStatusChanged event,
    Emitter<OrderDetailState> emit,
  ) async {
    if (event.entryStatus == state.entryStatus) return;
    emit(
      state.copyWith(
        entryStatus: event.entryStatus,
        status: OrderDetailStatus.loading,
        entries: const [],
        page: 1,
        total: 0,
        requestGeneration: state.requestGeneration + 1,
      ),
    );
    try {
      final entries = await _service.getEntries(
        bookId: bookId,
        orderId: orderId,
        pageNum: 1,
        pageSize: pageSize,
        entryStatus: event.entryStatus,
      );
      emit(
        state.copyWith(
          status: OrderDetailStatus.ready,
          entries: entries.rows,
          total: entries.total,
          page: 1,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: OrderDetailStatus.error,
          errorMessage: error is FxApiException
              ? error.message
              : S.current.dashboardLoadFailed,
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    OrderDetailLoadMoreRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore) return;
    final nextPage = state.page + 1;
    emit(state.copyWith(loadingMore: true, loadMoreError: null));
    try {
      final page = await _service.getEntries(
        bookId: bookId,
        orderId: orderId,
        pageNum: nextPage,
        pageSize: pageSize,
        entryStatus: state.entryStatus,
      );
      emit(
        state.copyWith(
          entries: [...state.entries, ...page.rows],
          total: page.total,
          page: nextPage,
          loadingMore: false,
          loadMoreError: null,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          loadingMore: false,
          loadMoreError: S.current.ordersLoadMoreFailed,
        ),
      );
    }
  }

  Future<void> _onEntryAction(
    OrderDetailEntryActionRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    final detail = state.detail;
    final billId = event.entry.billId;
    final version = detail?.version;
    if (detail == null || billId == null || version == null) return;
    emit(state.copyWith(actionLoading: true, toastMessage: null));
    try {
      await _service.entryAction(
        bookId: bookId,
        orderId: orderId,
        billId: billId,
        action: event.action,
        requestId: _requestId(),
        expectedVersion: version,
      );
      BillMutations.bump();
      emit(state.copyWith(actionLoading: false));
      await _onLoaded(const OrderDetailRefreshed(), emit);
    } on Object catch (error) {
      emit(
        state.copyWith(
          actionLoading: false,
          toastMessage: error is FxApiException
              ? error.message
              : S.current.profileSaveFailedRetry,
        ),
      );
    }
  }

  Future<void> _onTransition(
    OrderDetailTransitionRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    final detail = state.detail;
    final version = detail?.version;
    if (detail == null || version == null) return;
    emit(state.copyWith(actionLoading: true, toastMessage: null));
    try {
      await _service.transition(
        bookId: bookId,
        orderId: orderId,
        action: event.action,
        requestId: _requestId(),
        expectedVersion: version,
      );
      BillMutations.bump();
      if (event.action == 'remove') {
        // 单据已删除：不刷新已删除实体（否则会弹出“找不到单据”），通知页面返回上层。
        emit(state.copyWith(actionLoading: false, removed: true));
        return;
      }
      emit(state.copyWith(actionLoading: false));
      await _onLoaded(const OrderDetailRefreshed(), emit);
    } on Object catch (error) {
      emit(
        state.copyWith(
          actionLoading: false,
          toastMessage: error is FxApiException
              ? error.message
              : S.current.profileSaveFailedRetry,
        ),
      );
    }
  }

  static String _requestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20, 32),
    ].join('-');
  }
}
