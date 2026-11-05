import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';

void main() {
  test(
    'loads multiple historical months without replacing earlier rows',
    () async {
      final service = _FakeBillService();
      service.onGetPage = (query) async {
        if (query.pageNum == 1) {
          return BillPage(rows: [_bill(1, DateTime(2026, 11, 3))], total: 2);
        }
        return BillPage(rows: [_bill(2, DateTime(2025, 10, 4))], total: 2);
      };
      final bloc = BillsBloc(
        bookId: 7,
        service: service,
        now: DateTime(2026, 11, 5),
      );
      addTearDown(bloc.close);

      bloc.add(const BillsBookChanged(7));
      await _waitFor(bloc, (state) => state.status == BillsStatus.loaded);
      bloc.add(const BillsNextPageRequested());
      await _waitFor(bloc, (state) => !state.hasMore && !state.isLoadingMore);

      expect(bloc.state.bills.map((bill) => bill.billId), [1, 2]);
      expect(
        bloc.state.monthGroups(1).map((group) => group.window.anchorMonth),
        [DateTime(2026, 11), DateTime(2025, 10)],
      );
      expect(service.queries.map((query) => query.pageNum), [1, 2]);
    },
  );

  test('first page resolves statistics for every loaded month', () async {
    final service = _FakeBillService();
    service.onGetPage = (query) async => BillPage(
      rows: [_bill(1, DateTime(2026, 11, 3)), _bill(2, DateTime(2025, 10, 4))],
      total: 2,
    );
    final bloc = BillsBloc(bookId: 7, service: service);
    addTearDown(bloc.close);

    bloc.add(const BillsBookChanged(7));
    await _waitFor(bloc, (state) => state.status == BillsStatus.loaded);

    final groups = bloc.state.monthGroups(1);
    expect(groups[0].statistics, isNotNull);
    expect(groups[1].statistics, isNotNull);
  });

  test('applies a zero-result filter through the service query', () async {
    final service = _FakeBillService();
    service.onGetPage = (query) async {
      if (query.title == '不存在') return const BillPage();
      return BillPage(rows: [_bill(1, DateTime(2026, 11, 3))], total: 1);
    };
    final bloc = BillsBloc(bookId: 7, service: service);
    addTearDown(bloc.close);
    bloc.add(const BillsBookChanged(7));
    await _waitFor(bloc, (state) => state.status == BillsStatus.loaded);

    bloc.add(BillsFilterApplied(BillsFilter(title: '不存在')));
    await _waitFor(
      bloc,
      (state) => state.isEmpty && state.filter.title == '不存在',
    );

    expect(bloc.state.bills, isEmpty);
    expect(service.queries.last.title, '不存在');
    expect(service.queries.last.pageNum, 1);
  });

  test('refresh failure keeps the short list available for retry', () async {
    final service = _FakeBillService();
    var failRefresh = false;
    service.onGetPage = (query) async {
      if (failRefresh) throw FxApiException(-1, '刷新失败');
      return BillPage(rows: [_bill(1, DateTime(2026, 11, 3))], total: 1);
    };
    final bloc = BillsBloc(bookId: 7, service: service);
    addTearDown(bloc.close);
    bloc.add(const BillsBookChanged(7));
    await _waitFor(bloc, (state) => state.status == BillsStatus.loaded);

    failRefresh = true;
    bloc.add(const BillsRefreshed());
    await _waitFor(
      bloc,
      (state) => !state.isRefreshing && state.errorMessage != null,
    );

    expect(bloc.state.status, BillsStatus.loaded);
    expect(bloc.state.bills.single.billId, 1);
    expect(bloc.state.errorMessage, '刷新失败');
  });

  test(
    'pagination failure keeps loaded months and supports a real retry',
    () async {
      final service = _FakeBillService();
      var failNextPage = true;
      service.onGetPage = (query) async {
        if (query.pageNum == 1) {
          return BillPage(rows: [_bill(1, DateTime(2026, 11, 3))], total: 2);
        }
        if (failNextPage) throw FxApiException(-1, '分页失败');
        return BillPage(rows: [_bill(2, DateTime(2025, 10, 4))], total: 2);
      };
      final bloc = BillsBloc(bookId: 7, service: service);
      addTearDown(bloc.close);
      bloc.add(const BillsBookChanged(7));
      await _waitFor(bloc, (state) => state.status == BillsStatus.loaded);

      bloc.add(const BillsNextPageRequested());
      await _waitFor(bloc, (state) => state.paginationErrorMessage != null);
      expect(bloc.state.bills.single.billId, 1);
      expect(bloc.state.hasMore, isTrue);

      failNextPage = false;
      bloc.add(const BillsPaginationRetried());
      await _waitFor(bloc, (state) => state.bills.length == 2);
      expect(bloc.state.paginationErrorMessage, isNull);
      expect(bloc.state.bills.map((bill) => bill.billId), [1, 2]);
    },
  );
}

Future<void> _waitFor(BillsBloc bloc, bool Function(BillsState) predicate) {
  if (predicate(bloc.state)) return Future.value();
  return bloc.stream.firstWhere(predicate);
}

FortuneBillVo _bill(int id, DateTime tradeTime) => FortuneBillVo(
  billId: id,
  title: '账单$id',
  tradeTime: tradeTime,
  amount: 12,
  billType: FxBillType.expense.value,
  currencyCode: 'CNY',
);

class _FakeBillService extends BillService {
  final queries = <BillQuery>[];
  Future<BillPage> Function(BillQuery query)? onGetPage;

  @override
  Future<BillPage> getPage(BillQuery query) {
    queries.add(query);
    return onGetPage?.call(query) ?? Future.value(const BillPage());
  }

  @override
  Future<BillStatistics> getStatistics({
    required int bookId,
    required String tradeTimeStartTime,
    required String tradeTimeEndTime,
  }) async => const BillStatistics(expense: 12, surplus: -12);
}
