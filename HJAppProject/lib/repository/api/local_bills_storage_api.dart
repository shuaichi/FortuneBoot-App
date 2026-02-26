import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_statistics.dart';
import 'package:hjproject/request/bill_request.dart';
import 'package:hjproject/repository/api/bills_api.dart';
import 'package:hjproject/request/include_request.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// {@template local_storage_todos_api}
/// A Flutter implementation of the [TodosApi] that uses local storage.
/// {@endtemplate}
class LocalStorageBillsApi extends BillsApi {
  /// {@macro local_storage_todos_api}
  LocalStorageBillsApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;
  final BillService _billService = BillService();
  final IncludeService _includeService = IncludeService();
  int pageNum = 1;
  int pageSize = 20;
  late final _billStreamController = BehaviorSubject<List<BillItem>>.seeded(
    const [],
  );

  /// The key used for storing the todos locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kBillsCollectionKey = '__bills_collection_key__';

  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  DateTime addOneMonth(DateTime date) {
    int newYear = date.year;
    int newMonth = date.month + 1; // 月份加1

    // 处理跨年（如12月加1个月变为下一年1月）
    if (newMonth > 12) {
      newYear += 1;
      newMonth = 1;
    }

    // 处理目标月份天数不足（如1月31日加1个月到2月需调整为28/29日）
    int newDay = date.day;
    int daysInTargetMonth =
        DateTime(newYear, newMonth + 1, 0).day; // 目标月最大天数[1,3](@ref)
    if (newDay > daysInTargetMonth) {
      newDay = daysInTargetMonth; // 调整为最后一天
    }

    return DateTime(newYear, newMonth, newDay);
  }

  DateTime subtractMonth(DateTime date) {
    int newYear = date.year;
    int newMonth = date.month - 1; // 月份减1

    // 处理跨年（如1月减1个月变为去年12月）
    if (newMonth < 1) {
      newYear -= 1;
      newMonth = 12; // 设为12月
    }

    // 处理目标月份天数不足（如3月31日减1个月到2月可能无效）
    int newDay = date.day;
    int daysInTargetMonth = DateTime(newYear, newMonth + 1, 0).day; // 目标月最大天数
    if (newDay > daysInTargetMonth) {
      newDay = daysInTargetMonth; // 调整为最后一天（如2月28/29日）
    }

    return DateTime(newYear, newMonth, newDay);
  }

  bool refreshCaculatorStatisticsDuration(DateTime time,
      {bool forceRefresh = false}) {
    caculatorTime = time;
    DateTime newEndTime;
    DateTime newStartTime;
    final timeLastDay = DateTime(time.year, time.month + 1, 0).day;

    final nextMonth = addOneMonth(time);
    final lastMonth = subtractMonth(time);
    bool needRefresh = false;
    if (time.day > billStatisticsDay) {
      newStartTime = safeLastDayTime(
          time, DateTime(time.year, time.month, billStatisticsDay));
      newEndTime = safeLastDayTime(nextMonth,
          DateTime(nextMonth.year, nextMonth.month, billStatisticsDay));
    } else {
      newStartTime = safeLastDayTime(lastMonth,
          DateTime(lastMonth.year, lastMonth.month, billStatisticsDay));
      newEndTime = safeLastDayTime(
          time, DateTime(time.year, time.month, billStatisticsDay));
    }
    if (forceRefresh) {
      endTime = newEndTime;
      startTime = newStartTime;
      return true;
    }
    if (newEndTime != endTime || newStartTime != startTime) {
      endTime = newEndTime;
      startTime = newStartTime;
      needRefresh = true;
    }
    print(
        'lxjtodo: refreshCaculatorStatisticsDuration $endTime $startTime $needRefresh');
    return needRefresh;
  }

  DateTime safeLastDayTime(DateTime originTime, DateTime targetTime) {
    DateTime finalTime = targetTime;
    if (targetTime.year > originTime.year ||
        targetTime.month > originTime.month) {
      // 设置为这个月最后一天
      finalTime = DateTime(targetTime.year, targetTime.month, 0);
    }
    return finalTime;
  }

  void _init() {
    billStatisticsDay = _plugin.getInt("billStatisticsDay") ?? 1;
    groupId = _plugin.getInt("groupId");
    bookId = _plugin.getInt("bookId");
    refreshCaculatorStatisticsDuration(DateTime.now(), forceRefresh: true);
    if (bookId != null) {
      queryNewBills();
    }
  }

  @override
  Future<void> refreshStatistics(DateTime time) async {
    if (refreshCaculatorStatisticsDuration(time)) {
      await refreshStatic(startTime, endTime);
    }
    return;
  }

  @override
  Stream<List<BillItem>> getBills() =>
      _billStreamController.asBroadcastStream();

  @override
  Future<void> saveBills(BillItem billItem) {
    final bills = [..._billStreamController.value];
    final billIndex = bills.indexWhere((t) => t.billId == billItem.billId);
    if (billIndex >= 0) {
      bills[billIndex] = billItem;
    } else {
      bills.add(billItem);
    }

    _billStreamController.add(bills);
    return _setValue(kBillsCollectionKey, json.encode(bills));
  }

  @override
  Future<void> deleteBill(int billId) async {
    final bills = [..._billStreamController.value];
    final billIndex = bills.indexWhere((t) => t.billId == billId);
    await refreshStatic(startTime, endTime);
    if (billIndex == -1) {
    } else {
      bills.removeAt(billIndex);
      _billStreamController.add(bills);
      // 统计
      return _setValue(kBillsCollectionKey, json.encode(bills));
    }
  }

  @override
  Future<void> close() {
    return _billStreamController.close();
  }

  @override
  Future<void> nextBillPage() async {
    pageNum++;
    queryNewBills();
  }

  Future<void> queryNewBills({bool clear = true}) async {
    isLoadingMore = true;
    List<BillItem> items = [..._billStreamController.value];
    print('🔍 DEBUG: 当前Stream中的账单数量: ${items.length}');

    if (bookId == null) {
      print('❌ ERROR: bookId为null，无法查询账单数据');
      isLoadingMore = false;
      return;
    }

    try {
      var billResponse = await _billService.getPage(
        pageNum: pageNum,
        pageSize: pageSize,
        bookId: '$bookId',
      );
      print('🔍 DEBUG: API响应 - code: ${billResponse.code}, data: ${billResponse.data != null ? "有数据" : "无数据"}');
      try {
        await refreshStatic(startTime, endTime);
      } catch (e) {
        print('❌ ERROR: 刷新统计数据失败: $e');
      }
      if (billResponse.code == 0) {
      print('🔍 DEBUG: 开始解析API响应数据...');

      // 检查 billResponse.data 是否存在
      if (billResponse.data == null) {
        print('❌ ERROR: billResponse.data为null');
        isLoadingMore = false;
        return;
      }

      print('🔍 DEBUG: billResponse.data类型: ${billResponse.data.runtimeType}');
      print('🔍 DEBUG: billResponse.data内容: ${billResponse.data}');

      // 检查 rows 字段是否存在
      if (billResponse.data['rows'] == null) {
        print('❌ ERROR: billResponse.data[\'rows\']为null');
        isLoadingMore = false;
        return;
      }

      final billList = billResponse.data['rows'] as List? ?? [];
      print('🔍 DEBUG: API返回的原始数据行数: ${billList.length}');
      print('🔍 DEBUG: billList类型: ${billList.runtimeType}');

      if (billList.isEmpty) {
        print('⚠️ WARNING: billList为空，没有数据需要解析');
        isLoadingMore = false;
        return;
      }

      print('🔍 DEBUG: 开始逐个解析BillItem...');
      final List<BillItem> remoteItems = [];

      for (int i = 0; i < billList.length; i++) {
        try {
          print('🔍 DEBUG: 解析第${i + 1}个数据项...');
          final ele = billList[i];
          print('🔍 DEBUG: 第${i + 1}项原始数据类型: ${ele.runtimeType}');
          print('🔍 DEBUG: 第${i + 1}项原始数据: $ele');

          if (ele == null) {
            print('❌ ERROR: 第${i + 1}项数据为null，跳过');
            continue;
          }

          final Map<String, dynamic> itemMap = Map<String, dynamic>.from(ele as Map? ?? {});
          print('🔍 DEBUG: 第${i + 1}项转换后的Map: $itemMap');

          final billItem = BillItem.fromJson(itemMap);
          remoteItems.add(billItem);
          print('✅ SUCCESS: 第${i + 1}项解析成功，BillItem ID: ${billItem.billId}');

        } catch (e, stackTrace) {
          print('❌ ERROR: 解析第${i + 1}项时发生异常: $e');
          print('❌ ERROR: 异常堆栈: $stackTrace');
          continue;
        }
      }
      print('🔍 DEBUG: 解析完成！成功解析的BillItem数量: ${remoteItems.length}');

      if (clear) {
        items.addAll(remoteItems);
      } else {
        items = remoteItems;
      }
      final allBillsCount = billResponse.data['total'] as int? ?? 20;
      hasMore = items.length < allBillsCount;
      isLoadingMore = false;
      print('🔍 DEBUG: 最终添加到Stream的items数量: ${items.length}');
      print('🔍 DEBUG: hasMore: $hasMore, total: $allBillsCount');
      _billStreamController.add(items);
      // _setValue(kBillsCollectionKey, json.encode(items));
      } else {
        print('❌ ERROR: API响应失败 - code: ${billResponse.code}, message: ');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: queryNewBills发生异常: $e');
      print('❌ ERROR: 堆栈跟踪: $stackTrace');
    } finally {
      isLoadingMore = false;
    }
  }

  @override
  Future<void> updateRemoteBill({int? groupId, int? bookId}) async {
    developer.log('🔄 Repository更新请求 - 输入GroupId: $groupId, 输入BookId: $bookId', name: 'BillsApi');
    developer.log('📊 当前状态 - 当前GroupId: ${this.groupId}, 当前BookId: ${this.bookId}', name: 'BillsApi');

    try {
      if ((groupId != null && groupId != this.groupId) ||
          (bookId != null && bookId != this.bookId)) {

        developer.log('✅ 检测到ID变化，开始更新...', name: 'BillsApi');

        final oldGroupId = this.groupId;
        final oldBookId = this.bookId;

        this.groupId = groupId ?? this.groupId;
        this.bookId = bookId ?? this.bookId;
        if (this.groupId != null) {
          _plugin.setInt("groupId", this.groupId!);
        }
        if (this.bookId != null) {
          _plugin.setInt("bookId", this.bookId!);
        }
        developer.log('📝 ID更新完成 - 新GroupId: ${this.groupId}, 新BookId: ${this.bookId}', name: 'BillsApi');
        developer.log('📝 变更对比 - GroupId: $oldGroupId → ${this.groupId}, BookId: $oldBookId → ${this.bookId}', name: 'BillsApi');

        pageNum = 1;
        developer.log('🔄 重置页码为1，清空Stream数据...', name: 'BillsApi');

        _billStreamController.add([]);
        developer.log('✅ Stream已清空，当前数据量: ${_billStreamController.value.length}', name: 'BillsApi');

        developer.log('📡 开始查询新账单数据...', name: 'BillsApi');
        await queryNewBills();
        developer.log('✅ Repository更新完成', name: 'BillsApi');

      } else {
        developer.log('ℹ️ ID未发生变化，跳过更新', name: 'BillsApi');
      }
    } catch (error, stackTrace) {
      developer.log('❌ Repository更新失败', error: error, stackTrace: stackTrace, name: 'BillsApi');
      // 重新抛出异常，让上层处理
      rethrow;
    }
  }

  Future<void> refreshStatic(DateTime startTime, DateTime endTime) async {
    var billStatisticsResponse = await _includeService.getBillStatistics(
      bookId ?? 0,
      DateFormat('yyyy-MM-dd').format(startTime),
      DateFormat('yyyy-MM-dd').format(endTime),
    );
    if (billStatisticsResponse.code == 0) {
      if (billStatisticsResponse.data == null) {
        billStatistics = BillStatistics(
            income: 0, expense: 0, surplus: 0, staticTime: caculatorTime);
      } else {
        BillStatistics statistics = BillStatistics.fromJson(
            Map<String, dynamic>.from(
                billStatisticsResponse.data as Map? ?? {}));
        statistics.staticTime = caculatorTime;
        print('lxjtodo: $statistics startTime:$startTime, endTime:$endTime');
        billStatistics = statistics;
      }
    }
  }

  @override
  Future<void> refreshBills(bool clear) async {
    pageNum = 1;
    if (clear) {
      _billStreamController.add([]);
    }
    queryNewBills(clear: clear);
  }

  @override
  Future<void> statisticsDayChanged(int day) async {
    billStatisticsDay = day;
    _plugin.setInt("billStatisticsDay", day);
    refreshCaculatorStatisticsDuration(caculatorTime);
    await refreshStatic(startTime, endTime);
    return;
  }
}
