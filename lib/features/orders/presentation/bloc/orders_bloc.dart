import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';

part 'orders_event.dart';
part 'orders_state.dart';

/// 单据 Bloc：拉列表 + 状态机流转（using/close/reopen）。切账本重拉。
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersService _service;
  int? _bookId;

  OrdersBloc({OrdersService? service, int? bookId})
    : _service = service ?? OrdersService(),
      _bookId = bookId,
      super(const OrdersState()) {
    on<OrdersLoaded>(_onLoaded);
    on<OrdersMutated>(_onLoaded);
    on<OrdersBookChanged>(_onBookChanged);
    on<OrderTransitioned>(_onTransitioned);
  }

  Future<void> _onBookChanged(
    OrdersBookChanged event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != OrdersStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    await _load(emit);
  }

  Future<void> _onLoaded(OrdersEvent event, Emitter<OrdersState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<OrdersState> emit) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: OrdersStatus.empty, orders: const []));
      return;
    }
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final page = await _service.getPage(bookId: bookId, pageSize: 200);
      emit(
        state.copyWith(
          status: page.rows.isEmpty ? OrdersStatus.empty : OrdersStatus.loaded,
          orders: page.rows,
        ),
      );
    } on FxApiException catch (e) {
      emit(state.copyWith(status: OrdersStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(
        state.copyWith(status: OrdersStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onTransitioned(
    OrderTransitioned event,
    Emitter<OrdersState> emit,
  ) async {
    final bookId = _bookId;
    final orderId = event.order.orderId;
    if (bookId == null || orderId == null) return;
    try {
      await _service.transition(
        bookId: bookId,
        orderId: orderId,
        action: event.action,
      );
      await _load(emit);
    } on Object catch (e) {
      emit(
        state.copyWith(
          toastMessage:
              '操作失败：'
              '${e is FxApiException ? e.message : e.toString()}',
        ),
      );
    }
  }
}
