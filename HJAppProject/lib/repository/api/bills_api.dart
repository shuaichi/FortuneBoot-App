import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_statistics.dart';
import 'package:hjproject/home/bill_overview/models/fortune_bill_query.dart';

abstract class BillsApi {
  bool hasMore = true;

  bool isLoadingMore = false;

  late DateTime endTime;

  late DateTime caculatorTime;

  late DateTime startTime;

  late int billStatisticsDay;

  /// [新增] 用于保存当前的查询/筛选条件
  FortuneBillQuery? filterQuery;

  /// {@macro todos_api}
  BillsApi();

  int? groupId;

  int? bookId;

  /// [新增] 设置筛选条件的方法约束
  void setFilterQuery(FortuneBillQuery? query);

  /// Provides a [Stream] of all todos.
  Stream<List<BillItem>> getBills();

  /// Saves a [todo].
  ///
  /// If a [todo] with the same id already exists, it will be replaced.
  Future<void> saveBills(BillItem billItem);

  Future<void> deleteBill(int billId);

  Future<void> updateRemoteBill({int? groupId, int? bookId});

  Future<void> nextBillPage();

  /// Closes the client and frees up any resources.
  Future<void> close();

  Future<void> refreshBills(bool clear);

  Future<void> refreshStatistics(DateTime time);

  Future<void> statisticsDayChanged(int day);

  BillStatistics? billStatistics;
}