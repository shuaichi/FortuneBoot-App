import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  setUpAll(() async {
    await S.load(const Locale('zh'));
  });

  test(
    'loads all selected order types with page size 20 and summary',
    () async {
      final service = _FakeOrdersService();
      final bloc = OrdersBloc(bookId: 7, service: service);
      addTearDown(bloc.close);

      bloc.add(const OrdersLoaded());
      final state = await bloc.stream.firstWhere((s) => s.status.isTerminal);

      expect(state.status, OrdersLoadStatus.ready);
      expect(state.orders.map((order) => order.type?.value), everyElement(2));
      expect(state.total, 41);
      expect(state.page, 1);
      expect(service.pageRequests.single.pageSize, 20);
      expect(
        service.pageRequests.single.type,
        FinanceOrderType.receivable.value,
      );
      expect(service.pageRequests.single.status, 200);
      expect(service.summaryRequests, [7]);
      expect(state.summary?.receivableAmount?.cents, 100000);
    },
  );

  test('debounces search changes by 300ms and resets the page', () async {
    final service = _FakeOrdersService();
    final bloc = OrdersBloc(bookId: 7, service: service);
    addTearDown(bloc.close);

    bloc.add(const OrdersLoaded());
    await bloc.stream.firstWhere((s) => s.status.isTerminal);
    bloc.add(const OrdersSearchChanged('张'));
    bloc.add(const OrdersSearchChanged('张三'));

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(service.pageRequests.where((r) => r.keyword != null), isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final state = bloc.state;
    expect(state.keyword, '张三');
    expect(state.page, 1);
    expect(service.pageRequests.last.keyword, '张三');
  });

  test('load-more failure keeps displayed rows and can retry', () async {
    final service = _FakeOrdersService()..failNextLoadMore = true;
    final bloc = OrdersBloc(bookId: 7, service: service);
    addTearDown(bloc.close);

    bloc.add(const OrdersLoaded());
    await bloc.stream.firstWhere((s) => s.status.isTerminal);
    bloc.add(const OrdersLoadMoreRequested());
    final failed = await bloc.stream.firstWhere((s) => s.loadMoreError != null);

    expect(failed.orders.length, 20);
    expect(failed.loadMoreError, isNotNull);

    service.failNextLoadMore = false;
    bloc.add(const OrdersLoadMoreRequested());
    final loaded = await bloc.stream.firstWhere(
      (s) => s.page == 2 && s.loadMoreError == null,
    );

    expect(loaded.orders.map((order) => order.orderId).toSet().length, 40);
  });

  test('discards a stale response after quickly switching book', () async {
    final service = _FakeOrdersService()
      ..pageDelay = const Duration(milliseconds: 200);
    final bloc = OrdersBloc(bookId: 7, service: service);
    addTearDown(bloc.close);

    bloc.add(const OrdersLoaded());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const OrdersBookChanged(8));
    final state = await bloc.stream.firstWhere(
      (s) => s.status.isTerminal && s.requestGeneration == 2,
    );

    expect(state.orders.every((order) => order.bookId == 8), isTrue);
  });
}

class _FakeOrdersService extends OrdersService {
  final pageRequests =
      <
        ({
          int bookId,
          int pageNum,
          int pageSize,
          int? type,
          int? status,
          String? keyword,
        })
      >[];
  final summaryRequests = <int>[];
  var failNextLoadMore = false;
  var pageDelay = Duration.zero;

  @override
  Future<FinanceOrderPage> getPage({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    int? type,
    int? status,
    String? settlementState,
    String? keyword,
    String? title,
    bool overdueOnly = false,
  }) async {
    if (pageDelay > Duration.zero) {
      await Future<void>.delayed(pageDelay);
    }
    if (failNextLoadMore && pageNum > 1) {
      failNextLoadMore = false;
      throw StateError('network down');
    }
    pageRequests.add((
      bookId: bookId,
      pageNum: pageNum,
      pageSize: pageSize,
      type: type,
      status: status,
      keyword: keyword ?? title,
    ));
    final typeValue = type ?? 2;
    final rows = List.generate(
      pageNum == 1 ? 20 : 20,
      (index) => _detail(
        id: (pageNum - 1) * 20 + index + 1,
        bookId: bookId,
        typeValue: typeValue,
      ),
    );
    return FinanceOrderPage(rows: rows, total: 41);
  }

  @override
  Future<FinanceOrderSummary> getSummary({required int bookId}) async {
    summaryRequests.add(bookId);
    return FinanceOrderSummary(receivableAmount: OrderMoney.fromCents(100000));
  }

  static FinanceOrderDetail _detail({
    required int id,
    required int bookId,
    required int typeValue,
  }) => FinanceOrderDetail(
    orderId: id,
    bookId: bookId,
    title: 'order $id',
    type: FinanceOrderType.fromValue(typeValue),
    status: 200,
  );
}

extension on OrdersLoadStatus {
  bool get isTerminal =>
      this == OrdersLoadStatus.ready || this == OrdersLoadStatus.error;
}
