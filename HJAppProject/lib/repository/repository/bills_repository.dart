import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_statistics.dart';
import 'package:fortuneboot/home/bill_overview/models/fortune_bill_query.dart';
import 'package:fortuneboot/repository/api/bills_api.dart';

class BillsRepository {
  BillsRepository({
    required BillsApi billsApi,
  }) : _billsApi = billsApi;

  static String minApiVersion = '1.1.0';
  static String maxApiVersion = '2.0.0';

  final BillsApi _billsApi;

  // =====================================
  // 供 Bloc 调用的透传方法
  // =====================================
  void setFilterQuery(FortuneBillQuery? query) {
    _billsApi.setFilterQuery(query);
  }

  int? groupId() => _billsApi.groupId;

  int? bookId() => _billsApi.bookId;

  int? billStatisticsDay() => _billsApi.billStatisticsDay;

  bool hasMore() => _billsApi.hasMore;

  bool isLoadingMore() => _billsApi.isLoadingMore;

  /// Provides a [Stream] of all todos.
  Stream<List<BillItem>> getBills() => _billsApi.getBills();

  Future<void> saveBills(BillItem billItem) => _billsApi.saveBills(billItem);

  Future<void> updateRemoteBill({int? groupId, int? bookId}) =>
      _billsApi.updateRemoteBill(groupId: groupId, bookId: bookId);

  Future<void> nextBillPage() => _billsApi.nextBillPage();

  /// Disposes any resources managed by the repository.
  void dispose() => _billsApi.close();

  void refreshBills({bool clear = true}) => _billsApi.refreshBills(clear);

  void deleteBill(int billId) => _billsApi.deleteBill(billId);

  BillStatistics? getStatistics() => _billsApi.billStatistics;

  Future<void> refreshStatistics(DateTime time) => _billsApi.refreshStatistics(time);

  Future<void> statisticsDayChanged(int day) => _billsApi.statisticsDayChanged(day);
}