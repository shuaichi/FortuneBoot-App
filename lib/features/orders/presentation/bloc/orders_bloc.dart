import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:stream_transform/stream_transform.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// 单据列表状态机。
///
/// [requestGeneration] 是请求序号：切换账本、类型或筛选时递增。迟到响应必须
/// 丢弃，不能把旧账本/旧筛选的数据回填到当前页面。
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  static const int pageSize = 20;

  final OrdersService _service;
  int? _bookId;

  OrdersBloc({OrdersService? service, int? bookId})
    : _service = service ?? OrdersService(),
      _bookId = bookId,
      super(const OrdersState()) {
    on<OrdersLoaded>(_onReload);
    on<OrdersRefreshed>(_onReload);
    on<OrdersMutated>(_onReload);
    on<OrdersBookChanged>(_onBookChanged);
    on<OrdersTypeChanged>(_onTypeChanged);
    on<OrdersStatusFilterChanged>(_onStatusChanged);
    on<OrdersSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) => events
          .debounce(const Duration(milliseconds: 300))
          .asyncExpand(mapper),
    );
    on<OrdersOverdueOnlyChanged>(_onOverdueOnlyChanged);
    on<OrdersLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onReload(OrdersEvent event, Emitter<OrdersState> emit) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onBookChanged(
    OrdersBookChanged event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != OrdersLoadStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    emit(
      state.copyWith(
        status: OrdersLoadStatus.loading,
        orders: const [],
        page: 1,
        total: 0,
        summary: null,
        errorMessage: null,
        loadMoreError: null,
        requestGeneration: state.requestGeneration + 1,
      ),
    );
    await _requestPage(emit);
  }

  Future<void> _onTypeChanged(
    OrdersTypeChanged event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.type == state.type) return;
    emit(
      state.copyWith(
        type: event.type,
        status: OrdersLoadStatus.loading,
        orders: const [],
        page: 1,
        total: 0,
        errorMessage: null,
        loadMoreError: null,
        requestGeneration: state.requestGeneration + 1,
      ),
    );
    await _requestPage(emit);
  }

  Future<void> _onStatusChanged(
    OrdersStatusFilterChanged event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.status == state.statusFilter) return;
    emit(
      state.copyWith(
        statusFilter: event.status,
        status: OrdersLoadStatus.loading,
        orders: const [],
        page: 1,
        total: 0,
        errorMessage: null,
        loadMoreError: null,
        requestGeneration: state.requestGeneration + 1,
      ),
    );
    await _requestPage(emit);
  }

  Future<void> _onSearchChanged(
    OrdersSearchChanged event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.keyword == state.keyword) return;
    emit(state.copyWith(keyword: event.keyword));
    await _loadFirstPage(emit);
  }

  Future<void> _onOverdueOnlyChanged(
    OrdersOverdueOnlyChanged event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.overdueOnly == state.overdueOnly) return;
    emit(
      state.copyWith(
        overdueOnly: event.overdueOnly,
        status: OrdersLoadStatus.loading,
        orders: const [],
        page: 1,
        total: 0,
        errorMessage: null,
        loadMoreError: null,
        requestGeneration: state.requestGeneration + 1,
      ),
    );
    await _requestPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<OrdersState> emit) async {
    emit(
      state.copyWith(
        status: OrdersLoadStatus.loading,
        orders: const [],
        page: 1,
        total: 0,
        errorMessage: null,
        loadMoreError: null,
        requestGeneration: state.requestGeneration + 1,
      ),
    );
    await _requestPage(emit);
  }

  Future<void> _requestPage(Emitter<OrdersState> emit) async {
    final bookId = _bookId;
    final generation = state.requestGeneration;
    if (bookId == null) {
      emit(state.copyWith(status: OrdersLoadStatus.noBook));
      return;
    }

    try {
      final results = await Future.wait<Object>([
        _service.getPage(
          bookId: bookId,
          pageNum: 1,
          pageSize: pageSize,
          type: state.type.value,
          status: state.statusFilter,
          keyword: state.keyword,
          overdueOnly: state.overdueOnly,
        ),
        _service.getSummary(bookId: bookId),
      ]);
      if (!isClosed && generation == state.requestGeneration) {
        final page = results[0] as FinanceOrderPage;
        final summary = results[1] as FinanceOrderSummary;
        emit(
          state.copyWith(
            status: page.rows.isEmpty
                ? OrdersLoadStatus.empty
                : OrdersLoadStatus.ready,
            orders: page.rows,
            total: page.total,
            page: 1,
            summary: summary,
            errorMessage: null,
            loadMoreError: null,
          ),
        );
      }
    } on FxApiException catch (error) {
      if (!isClosed && generation == state.requestGeneration) {
        emit(
          state.copyWith(
            status: OrdersLoadStatus.error,
            errorMessage: error.message,
          ),
        );
      }
    } on Object {
      if (!isClosed && generation == state.requestGeneration) {
        emit(
          state.copyWith(
            status: OrdersLoadStatus.error,
            errorMessage: S.current.dashboardLoadFailed,
          ),
        );
      }
    }
  }

  Future<void> _onLoadMore(
    OrdersLoadMoreRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final bookId = _bookId;
    if (bookId == null || state.loadingMore || !state.hasMore) return;
    final generation = state.requestGeneration;
    final nextPage = state.page + 1;
    emit(state.copyWith(loadingMore: true, loadMoreError: null));
    try {
      final page = await _service.getPage(
        bookId: bookId,
        pageNum: nextPage,
        pageSize: pageSize,
        type: state.type.value,
        status: state.statusFilter,
        keyword: state.keyword,
        overdueOnly: state.overdueOnly,
      );
      if (isClosed || generation != state.requestGeneration) return;
      final nextOrders = [...state.orders, ...page.rows];
      emit(
        state.copyWith(
          orders: nextOrders,
          page: nextPage,
          total: page.total,
          loadingMore: false,
          loadMoreError: null,
        ),
      );
    } on Object {
      if (isClosed || generation != state.requestGeneration) return;
      emit(
        state.copyWith(
          loadingMore: false,
          loadMoreError: S.current.ordersLoadMoreFailed,
        ),
      );
    }
  }
}
