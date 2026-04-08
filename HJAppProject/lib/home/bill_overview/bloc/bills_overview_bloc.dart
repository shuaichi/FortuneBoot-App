import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_statistics.dart';
import 'package:fortuneboot/home/bill_overview/models/fortune_bill_query.dart';
import 'package:fortuneboot/request/bill_request.dart';
import 'package:fortuneboot/repository/repository/bills_repository.dart';

part 'bills_overview_event.dart';
part 'bills_overview_state.dart';

class BillsOverviewBloc extends Bloc<BillsOverviewEvent, BillsOverviewState> {
  BillsOverviewBloc({
    required BillsRepository billsRepository,
  })  : _billsRepository = billsRepository,
        super(const BillsOverviewState()) {
    on<BillsOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<BillsOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<BillsOverviewLoadMoreRequested>(_onLoadMoreRequested);
    on<BillsOverviewDeleteRequested>(_onDeleteRequested);
    on<BillsOverviewLoadLastRequested>(_onLoadLastRequested);
    on<BillsOverviewRefreshStatisticsRequested>(_onLoadStatisticsRequested);
    on<BillsOverviewRefreshStatisticsDayChanged>(_onStatisticsDayChanged);
    on<BillsOverviewFilterChanged>(_onFilterChanged);
  }
  final BillService _billService = BillService();

  final BillsRepository _billsRepository;

  Future<void> _onSubscriptionRequested(
    BillsOverviewSubscriptionRequested event,
    Emitter<BillsOverviewState> emit,
  ) async {
    print('🔍 DEBUG: BLoC订阅请求开始');
    emit(state.copyWith(status: () => BillsOverviewStatus.loading));
    print('🔍 DEBUG: BLoC状态设置为loading');
    
    _billsRepository.refreshBills(clear: false);

    await emit.forEach<List<BillItem>>(
      _billsRepository.getBills(),
      onData: (bills) {
        print('🔍 DEBUG: BLoC收到账单数据 - 数量: ${bills.length}');
        final statistics = _billsRepository.getStatistics();
        print('🔍 DEBUG: 统计数据 - income: ${statistics?.income}, expense: ${statistics?.expense}');
        return state.copyWith(
          status: () => BillsOverviewStatus.success,
          bills: bills,
          hasMore: _billsRepository.hasMore(),
          isLoadingMore: _billsRepository.isLoadingMore(),
          statistics: statistics,
        );
      },
      onError: (error, stackTrace) {
        print('❌ ERROR: BLoC数据流出错 - $error');
        print('❌ ERROR: 堆栈跟踪 - $stackTrace');
        return state.copyWith(
          status: () => BillsOverviewStatus.failure,
        );
      },
    );
  }

  Future<void> _onUndoDeletionRequested(
    BillsOverviewUndoDeletionRequested event,
    Emitter<BillsOverviewState> emit,
  ) async {
    assert(
      state.lastDeletedBill != null,
      'Last deleted bill can not be null.',
    );

    final bill = state.lastDeletedBill!;
    emit(state.copyWith(lastDeletedBill: () => null));
    await _billsRepository.saveBills(bill);
  }

  /// 上拉加载更多处理
  Future<void> _onLoadMoreRequested(
    BillsOverviewLoadMoreRequested event,
    Emitter<BillsOverviewState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    _billsRepository.nextBillPage();
  }

  FutureOr<void> _onDeleteRequested(BillsOverviewDeleteRequested event,
      Emitter<BillsOverviewState> emit) async {
    var response = await _billService.removeBill(
        _billsRepository.bookId() ?? 1, event.billId);
    if (response.code == 0) {
      _billsRepository.deleteBill(event.billId);
    } else {
      emit(state.copyWith(status: () => BillsOverviewStatus.failure));
    }
  }

  FutureOr<void> _onLoadLastRequested(
      BillsOverviewLoadLastRequested event, Emitter<BillsOverviewState> emit) {
    _billsRepository.refreshBills(clear: false);
  }

  FutureOr<void> _onFetchDetailFileRequested(
      BillsOverviewLoadLastRequested event, Emitter<BillsOverviewState> emit) {
    _billsRepository.refreshBills(clear: false);
  }

  FutureOr<void> _onLoadStatisticsRequested(
      BillsOverviewRefreshStatisticsRequested event,
      Emitter<BillsOverviewState> emit) async {
    await _billsRepository.refreshStatistics(event.refreshDate);
    emit(state.copyWith(statistics: _billsRepository.getStatistics()));
  }

  FutureOr<void> _onStatisticsDayChanged(
      BillsOverviewRefreshStatisticsDayChanged event,
      Emitter<BillsOverviewState> emit) async {
    await _billsRepository.statisticsDayChanged(event.day);
    emit(state.copyWith(statistics: _billsRepository.getStatistics()));
  }
  Future<void> _onFilterChanged(
      BillsOverviewFilterChanged event,
      Emitter<BillsOverviewState> emit,
      ) async {
    // 1. 更新筛选条件状态
    emit(state.copyWith(query: () => event.query, status: () => BillsOverviewStatus.loading));

    // 2. 将查询参数传递给 Repository 
    // 【注意】这需要在您的 BillsRepository 中增加 setFilterQuery 方法，并在 getBills() 请求时附带该参数
    _billsRepository.setFilterQuery(event.query);

    // 3. 清空列表并重新拉取
    _billsRepository.refreshBills(clear: true);
  }
}
