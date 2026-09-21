import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_service.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HarmonyOS 桌面卡片桥：收支日历。
class OhosDesktopWidget {
  OhosDesktopWidget._();

  static const MethodChannel _channel = MethodChannel(
    'fortuneboot/ohos_desktop_widget',
  );
  static const String _hideAmountsKey =
      'fortune.preferences.dashboard.hideAmounts';
  static const String _addGuide =
      '请长按桌面空白处，选择服务卡片 → 好记 → 选择日历或报销单卡片';

  static final DateFormat _day = DateFormat('yyyy-MM-dd');
  static final DateFormat _clock = DateFormat('HH:mm');
  static final NumberFormat _money = NumberFormat('#,##0.00');

  static bool get isSupportedOs => Platform.operatingSystem == 'ohos';

  static void Function()? _monthChangedHandler;
  static bool _handlerReady = false;

  /// App 侧注册：卡片翻月后若引擎在线，会回调刷新。
  static void bindMonthChangedHandler(void Function() handler) {
    if (!isSupportedOs) return;
    _monthChangedHandler = handler;
    if (_handlerReady) return;
    _handlerReady = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onCalendarMonthChanged') {
        _monthChangedHandler?.call();
      }
      return null;
    });
  }

  static Future<DateTime?> _readNativeCalendarMonth() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('getCalendarMonth');
      if (raw is Map) {
        final year = int.tryParse('${raw['year']}');
        final month = int.tryParse('${raw['month']}');
        if (year != null && month != null && month >= 1 && month <= 12) {
          return DateTime(year, month, 1);
        }
      }
    } on Object catch (e) {
      developer.log(
        'OhosDesktopWidget.getCalendarMonth failed: $e',
        name: 'desktop_widget',
      );
    }
    return null;
  }

  static Future<int?> _readNativeYearView() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('getCalendarYear');
      if (raw is Map) {
        final year = int.tryParse('${raw['year']}');
        if (year != null && year >= 1900 && year <= 2100) {
          return year;
        }
      }
    } on Object catch (e) {
      developer.log(
        'OhosDesktopWidget.getCalendarYear failed: $e',
        name: 'desktop_widget',
      );
    }
    return null;
  }

  static Future<bool> isSupported() async {
    if (!isSupportedOs) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// 拉取日/月收支日历并推送到桌面卡片。
  static Future<void> syncAll({
    required int bookId,
    int? groupId,
    String? currencyCode,
    bool? hideAmounts,
    BillService? billService,
    StatsService? statsService,
    DashboardService? dashboardService,
    OrdersService? ordersService,
    DateTime? anchor,
  }) async {
    await syncCalendar(
      bookId: bookId,
      groupId: groupId,
      currencyCode: currencyCode,
      hideAmounts: hideAmounts,
      billService: billService,
      statsService: statsService,
      dashboardService: dashboardService,
      anchor: anchor,
    );
    await syncYearCalendar(
      bookId: bookId,
      groupId: groupId,
      currencyCode: currencyCode,
      hideAmounts: hideAmounts,
      statsService: statsService,
      dashboardService: dashboardService,
    );
    await syncOrders(
      bookId: bookId,
      hideAmounts: hideAmounts,
      ordersService: ordersService,
    );
  }

  /// 拉取本月收支日历并推送到桌面卡片。
  static Future<void> syncCalendar({
    required int bookId,
    int? groupId,
    String? currencyCode,
    bool? hideAmounts,
    StatsService? statsService,
    BillService? billService,
    DashboardService? dashboardService,
    DateTime? anchor,
  }) async {
    if (!isSupportedOs || bookId <= 0) return;
    final hide =
        hideAmounts ??
        (await SharedPreferences.getInstance()).getBool(_hideAmountsKey) ??
        false;
    final bills = billService ?? BillService();
    final stats = statsService ?? StatsService();
    final dashboard = dashboardService ?? DashboardService();
    // 优先用桌面卡片当前翻到的月份；未指定 anchor 时读原生偏好。
    final nativeMonth =
        anchor == null ? await _readNativeCalendarMonth() : null;
    final wallNow = DateTime.now();
    final monthAnchor = DateTime(
      (anchor ?? nativeMonth ?? wallNow).year,
      (anchor ?? nativeMonth ?? wallNow).month,
      1,
    );
    final today = DateTime(wallNow.year, wallNow.month, wallNow.day);
    final monthEnd = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);

    var byDay = <int, ({double income, double expense})>{};
    try {
      final response = await stats.getIncomeExpenseCalendar(
        request: IncomeExpenseCalendarRequest.month(
          bookId: bookId,
          year: monthAnchor.year,
          month: monthAnchor.month,
        ),
      );
      byDay = _mergeCalendarItems(response.items, monthAnchor);
      developer.log(
        'OhosDesktopWidget.calendar api days=${byDay.length} items=${response.items.length}',
        name: 'desktop_widget',
      );
    } on Object catch (e, st) {
      developer.log(
        'OhosDesktopWidget.calendar api failed: $e',
        name: 'desktop_widget',
        stackTrace: st,
      );
    }

    if (byDay.isEmpty) {
      try {
        byDay = await _aggregateBillsByDay(
          bills: bills,
          bookId: bookId,
          monthAnchor: monthAnchor,
          monthEnd: monthEnd,
        );
        developer.log(
          'OhosDesktopWidget.calendar bill fallback days=${byDay.length}',
          name: 'desktop_widget',
        );
      } on Object catch (e, st) {
        developer.log(
          'OhosDesktopWidget.calendar bill fallback failed: $e',
          name: 'desktop_widget',
          stackTrace: st,
        );
      }
    }

    var monthIncome = 0.0;
    var monthExpense = 0.0;
    final dayParts = <String>[];
    final sortedDays = byDay.keys.toList()..sort();
    for (final day in sortedDays) {
      final bucket = byDay[day]!;
      monthIncome += bucket.income;
      monthExpense += bucket.expense;
      if (bucket.income == 0 && bucket.expense == 0) continue;
      dayParts.add(
        '$day:${_packCents(bucket.income, hide)}:${_packCents(bucket.expense, hide)}',
      );
    }

    final monthKey =
        '${monthAnchor.year}-${monthAnchor.month.toString().padLeft(2, '0')}';
    final isCurrentMonth =
        monthAnchor.year == wallNow.year && monthAnchor.month == wallNow.month;
    final todayMark = isCurrentMonth ? today.day : 0;
    final cellsPacked = '$monthKey|$todayMark|${dayParts.join(';')}';

    String? netAssetsText;
    if (groupId != null && groupId > 0) {
      try {
        final assets = await dashboard.getAssetsLiabilities(groupId);
        netAssetsText = hide ? '****' : _money.format(assets.netAssets);
      } on Object catch (e, st) {
        developer.log(
          'OhosDesktopWidget.netAssets failed: $e',
          name: 'desktop_widget',
          stackTrace: st,
        );
      }
    }

    await updateSnapshot(
      bookId: bookId,
      groupId: groupId,
      currencyCode: currencyCode,
      hideAmounts: hide,
      monthTitle: DateFormat('yyyy年M月').format(monthAnchor),
      weekdays: '一二三四五六日',
      cellsJson: cellsPacked,
      monthIncomeText: hide ? '****' : _money.format(monthIncome),
      monthExpenseText: hide ? '****' : _money.format(monthExpense),
      netAssetsText: netAssetsText,
      calendarYear: monthAnchor.year,
      calendarMonth: monthAnchor.month,
    );
  }

  /// 拉取年视图（12 个月）并推送到月收支日历卡片。
  static Future<void> syncYearCalendar({
    required int bookId,
    int? groupId,
    String? currencyCode,
    bool? hideAmounts,
    StatsService? statsService,
    DashboardService? dashboardService,
    int? year,
  }) async {
    if (!isSupportedOs || bookId <= 0) return;
    final hide =
        hideAmounts ??
        (await SharedPreferences.getInstance()).getBool(_hideAmountsKey) ??
        false;
    final stats = statsService ?? StatsService();
    final dashboard = dashboardService ?? DashboardService();
    final wallNow = DateTime.now();
    final nativeYear = year == null ? await _readNativeYearView() : null;
    final yearAnchor = year ?? nativeYear ?? wallNow.year;

    var byMonth = <int, ({double income, double expense})>{};
    try {
      final response = await stats.getIncomeExpenseCalendar(
        request: IncomeExpenseCalendarRequest.year(
          bookId: bookId,
          year: yearAnchor,
        ),
      );
      byMonth = _mergeYearItems(response.items, yearAnchor);
    } on Object catch (e, st) {
      developer.log(
        'OhosDesktopWidget.year calendar api failed: $e',
        name: 'desktop_widget',
        stackTrace: st,
      );
    }

    var yearIncome = 0.0;
    var yearExpense = 0.0;
    final monthParts = <String>[];
    final sorted = byMonth.keys.toList()..sort();
    for (final month in sorted) {
      final bucket = byMonth[month]!;
      yearIncome += bucket.income;
      yearExpense += bucket.expense;
      if (bucket.income == 0 && bucket.expense == 0) continue;
      monthParts.add(
        '$month:${_packCents(bucket.income, hide)}:${_packCents(bucket.expense, hide)}',
      );
    }
    final currentMonthMark =
        yearAnchor == wallNow.year ? wallNow.month : 0;
    final yearCellsPacked =
        '$yearAnchor|$currentMonthMark|${monthParts.join(';')}';

    String? netAssetsText;
    if (groupId != null && groupId > 0) {
      try {
        final assets = await dashboard.getAssetsLiabilities(groupId);
        netAssetsText = hide ? '****' : _money.format(assets.netAssets);
      } on Object catch (e, st) {
        developer.log(
          'OhosDesktopWidget.year netAssets failed: $e',
          name: 'desktop_widget',
          stackTrace: st,
        );
      }
    }

    await updateSnapshot(
      bookId: bookId,
      groupId: groupId,
      currencyCode: currencyCode,
      hideAmounts: hide,
      yearTitle: '$yearAnchor年',
      yearCellsJson: yearCellsPacked,
      yearIncomeText: hide ? '****' : _money.format(yearIncome),
      yearExpenseText: hide ? '****' : _money.format(yearExpense),
      netAssetsText: netAssetsText,
      yearViewYear: yearAnchor,
      subtitle: '翻年自动同步',
    );
  }

  static Map<int, ({double income, double expense})> _mergeYearItems(
    List<IncomeExpenseCalendarBucket> items,
    int year,
  ) {
    final byMonth = <int, ({double income, double expense})>{};
    for (final item in items) {
      final month = _monthFromPeriod(item.period, year);
      if (month == null) continue;
      final existing = byMonth[month];
      byMonth[month] = (
        income: (existing?.income ?? 0) + item.income,
        expense: (existing?.expense ?? 0) + item.expense,
      );
    }
    return byMonth;
  }

  static int? _monthFromPeriod(String period, int year) {
    final normalized = period.trim().replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length != 2) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y != year || m == null || m < 1 || m > 12) return null;
    return m;
  }

  /// 拉取报销单列表并推送到 2×2 报销单卡片。
  static Future<void> syncOrders({
    required int bookId,
    bool? hideAmounts,
    OrdersService? ordersService,
  }) async {
    if (!isSupportedOs || bookId <= 0) return;
    final hide =
        hideAmounts ??
        (await SharedPreferences.getInstance()).getBool(_hideAmountsKey) ??
        false;
    final orders = ordersService ?? OrdersService();
    var rows = <FortuneFinanceOrderVo>[];
    try {
      rows = await orders.getUsingList(bookId);
    } on Object catch (e, st) {
      developer.log(
        'OhosDesktopWidget.orders usingList failed: $e',
        name: 'desktop_widget',
        stackTrace: st,
      );
    }
    if (rows.isEmpty) {
      try {
        final page = await orders.getPage(
          bookId: bookId,
          pageNum: 1,
          pageSize: 20,
          type: FinanceOrderType.reimbursement.value,
        );
        rows = page.rows;
      } on Object catch (e, st) {
        developer.log(
          'OhosDesktopWidget.orders page failed: $e',
          name: 'desktop_widget',
          stackTrace: st,
        );
      }
    }

    final parts = <String>[];
    for (final row in rows.take(30)) {
      final id = row.orderId;
      if (id == null || id <= 0) continue;
      final rawTitle = (row.title ?? '未命名报销单')
          .replaceAll('|', '/')
          .replaceAll(';', ',');
      final title =
          rawTitle.length > 24 ? rawTitle.substring(0, 24) : rawTitle;
      if (hide) {
        parts.add('$id|$title|*|*');
      } else {
        final outCents = ((row.outAmount ?? 0) * 100).round();
        final inCents = ((row.inAmount ?? 0) * 100).round();
        parts.add('$id|$title|$outCents|$inCents');
      }
    }

    await updateSnapshot(
      bookId: bookId,
      hideAmounts: hide,
      ordersPacked: parts.join(';'),
      defaultOrderId: rows.isNotEmpty ? rows.first.orderId : null,
      subtitle: '长按切换报销单',
    );
  }

  static Map<int, ({double income, double expense})> _mergeCalendarItems(
    List<IncomeExpenseCalendarBucket> items,
    DateTime monthAnchor,
  ) {
    final byDay = <int, ({double income, double expense})>{};
    for (final item in items) {
      final day = _dayFromPeriod(item.period, monthAnchor);
      if (day == null) continue;
      final existing = byDay[day];
      byDay[day] = (
        income: (existing?.income ?? 0) + item.income,
        expense: (existing?.expense ?? 0) + item.expense,
      );
    }
    return byDay;
  }

  static Future<Map<int, ({double income, double expense})>>
  _aggregateBillsByDay({
    required BillService bills,
    required int bookId,
    required DateTime monthAnchor,
    required DateTime monthEnd,
  }) async {
    final byDay = <int, ({double income, double expense})>{};
    var pageNum = 1;
    const pageSize = 100;
    while (pageNum <= 20) {
      final page = await bills.getPage(
        BillQuery(
          bookId: bookId,
          pageNum: pageNum,
          pageSize: pageSize,
          tradeTimeStartTime: _day.format(monthAnchor),
          tradeTimeEndTime: _day.format(monthEnd),
        ),
      );
      if (page.rows.isEmpty) break;
      for (final bill in page.rows) {
        final trade = bill.tradeTime;
        if (trade == null) continue;
        if (trade.year != monthAnchor.year || trade.month != monthAnchor.month) {
          continue;
        }
        final day = trade.day;
        final amount = bill.displayAmount;
        final existing = byDay[day] ?? (income: 0.0, expense: 0.0);
        if (bill.billType == FxBillType.income.value) {
          byDay[day] = (
            income: existing.income + amount,
            expense: existing.expense,
          );
        } else if (bill.billType == FxBillType.expense.value ||
            bill.billType == FxBillType.advance.value) {
          byDay[day] = (
            income: existing.income,
            expense: existing.expense + amount,
          );
        }
      }
      if (page.rows.length < pageSize) break;
      if (pageNum * pageSize >= page.total) break;
      pageNum++;
    }
    return byDay;
  }

  /// 金额用「分」整数，避免 locale compact 破坏解析。
  static String _packCents(num value, bool hide) {
    if (hide) return '*';
    if (value == 0) return '';
    return (value * 100).round().toString();
  }

  static int? _dayFromPeriod(String period, DateTime anchor) {
    final normalized = period.trim().replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year != anchor.year || month != anchor.month || day == null) {
      return null;
    }
    final maxDay = DateTime(anchor.year, anchor.month + 1, 0).day;
    if (day < 1 || day > maxDay) return null;
    return day;
  }

  static Future<void> updateSnapshot({
    required int bookId,
    int? groupId,
    String? currencyCode,
    bool hideAmounts = false,
    String? monthTitle,
    String? weekdays,
    String? cellsJson,
    String? monthIncomeText,
    String? monthExpenseText,
    String? netAssetsText,
    String? yearTitle,
    String? yearCellsJson,
    String? yearIncomeText,
    String? yearExpenseText,
    String? ordersPacked,
    String? orderSelections,
    int? calendarYear,
    int? calendarMonth,
    int? yearViewYear,
    int? defaultOrderId,
    String? subtitle,
  }) async {
    if (!isSupportedOs) return;
    try {
      final args = <String, dynamic>{
        'updatedAt': _clock.format(DateTime.now()),
        'bookId': '$bookId',
        'hideAmounts': hideAmounts,
        'currencyCode': currencyCode ?? '',
        'subtitle': subtitle ?? '翻月自动同步',
      };
      if (groupId != null) args['groupId'] = groupId;
      if (monthTitle != null) args['monthTitle'] = monthTitle;
      if (weekdays != null) args['weekdays'] = weekdays;
      if (cellsJson != null) args['cellsJson'] = cellsJson;
      if (monthIncomeText != null) args['monthIncomeText'] = monthIncomeText;
      if (monthExpenseText != null) {
        args['monthExpenseText'] = monthExpenseText;
      }
      if (netAssetsText != null) args['netAssetsText'] = netAssetsText;
      if (yearTitle != null) args['yearTitle'] = yearTitle;
      if (yearCellsJson != null) args['yearCellsJson'] = yearCellsJson;
      if (yearIncomeText != null) args['yearIncomeText'] = yearIncomeText;
      if (yearExpenseText != null) args['yearExpenseText'] = yearExpenseText;
      if (ordersPacked != null) args['ordersPacked'] = ordersPacked;
      if (orderSelections != null) args['orderSelections'] = orderSelections;
      if (calendarYear != null) args['calendarYear'] = calendarYear;
      if (calendarMonth != null) args['calendarMonth'] = calendarMonth;
      if (yearViewYear != null) args['yearViewYear'] = yearViewYear;
      if (defaultOrderId != null) args['defaultOrderId'] = defaultOrderId;

      developer.log(
        'OhosDesktopWidget.updateSnapshot cellsLen=${cellsJson?.length ?? 0} '
        'monthExpense=$monthExpenseText',
        name: 'desktop_widget',
      );

      final result = await _channel.invokeMethod<dynamic>(
        'updateSnapshot',
        args,
      );
      developer.log(
        'OhosDesktopWidget.updateSnapshot result=$result',
        name: 'desktop_widget',
      );
    } on MissingPluginException catch (e) {
      developer.log(
        'OhosDesktopWidget channel missing: $e',
        name: 'desktop_widget',
      );
    } on PlatformException catch (e) {
      developer.log(
        'OhosDesktopWidget.updateSnapshot platform error: ${e.message}',
        name: 'desktop_widget',
      );
    }
  }

  static Future<void> publishNow() async {
    if (!isSupportedOs) return;
    try {
      await _channel.invokeMethod<dynamic>('publishNow');
    } on Object catch (e) {
      developer.log(
        'OhosDesktopWidget.publishNow failed: $e',
        name: 'desktop_widget',
      );
    }
  }

  static Future<DesktopWidgetAddResult> requestAddToDesktop() async {
    if (!isSupportedOs) {
      return const DesktopWidgetAddResult(
        ok: false,
        message: '当前系统不支持鸿蒙桌面卡片',
      );
    }
    try {
      final raw = await _channel.invokeMethod<dynamic>('requestAddToDesktop');
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        return DesktopWidgetAddResult(
          ok: map['ok'] == true,
          message: map['message']?.toString() ?? _addGuide,
        );
      }
      return const DesktopWidgetAddResult(ok: false, message: _addGuide);
    } on MissingPluginException {
      return const DesktopWidgetAddResult(ok: false, message: _addGuide);
    } on PlatformException catch (e) {
      return DesktopWidgetAddResult(ok: false, message: e.message ?? _addGuide);
    }
  }
}

class DesktopWidgetAddResult {
  final bool ok;
  final String message;

  const DesktopWidgetAddResult({required this.ok, required this.message});
}
