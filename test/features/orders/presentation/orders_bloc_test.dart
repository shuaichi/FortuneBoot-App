import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';

void main() {
  test('transitions order with backend action path and reloads', () async {
    final service = _FakeOrdersService(
      const OrdersPage(
        rows: [FortuneFinanceOrderVo(orderId: 1, type: 1, status: 200)],
      ),
    );
    final bloc = OrdersBloc(bookId: 47, service: service);
    addTearDown(bloc.close);

    bloc.add(
      const OrderTransitioned(
        order: FortuneFinanceOrderVo(orderId: 99, type: 1, status: 100),
        action: 'using',
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == OrdersStatus.loaded,
    );

    expect(state.orders.single.orderId, 1);
    expect(service.transitions.single.bookId, 47);
    expect(service.transitions.single.orderId, 99);
    expect(service.transitions.single.action, 'using');
    expect(service.requests.single.type, FinanceOrderType.reimbursement.value);
  });

  test('keeps only reimbursement orders when loading', () async {
    final service = _FakeOrdersService(
      const OrdersPage(
        rows: [
          FortuneFinanceOrderVo(orderId: 1, type: 1),
          FortuneFinanceOrderVo(orderId: 2, type: 2),
          FortuneFinanceOrderVo(orderId: 3, type: 3),
        ],
      ),
    );
    final bloc = OrdersBloc(bookId: 1, service: service);
    addTearDown(bloc.close);

    bloc.add(const OrdersLoaded());
    final state = await bloc.stream.firstWhere(
      (state) => state.status != OrdersStatus.loading,
    );

    expect(state.status, OrdersStatus.loaded);
    expect(state.orders.map((order) => order.orderId), [1]);
    expect(service.requests.single.type, FinanceOrderType.reimbursement.value);
  });

  test('shows empty state when only reserved orders are returned', () async {
    final bloc = OrdersBloc(
      bookId: 1,
      service: _FakeOrdersService(
        const OrdersPage(
          rows: [
            FortuneFinanceOrderVo(orderId: 2, type: 2),
            FortuneFinanceOrderVo(orderId: 3, type: 3),
          ],
        ),
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const OrdersLoaded());
    final state = await bloc.stream.firstWhere(
      (state) => state.status != OrdersStatus.loading,
    );

    expect(state.status, OrdersStatus.empty);
    expect(state.orders, isEmpty);
  });
}

class _FakeOrdersService extends OrdersService {
  _FakeOrdersService(this._page);

  final OrdersPage _page;
  final requests = <({int? type})>[];
  final transitions = <({int bookId, int orderId, String action})>[];

  @override
  Future<OrdersPage> getPage({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    String? title,
    int? type,
    int? status,
  }) async {
    requests.add((type: type));
    return _page;
  }

  @override
  Future<void> transition({
    required int bookId,
    required int orderId,
    required String action,
  }) async {
    transitions.add((bookId: bookId, orderId: orderId, action: action));
  }
}
