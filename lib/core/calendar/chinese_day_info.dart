import 'package:lunar/lunar.dart';

/// 法定调休标记：休=放假，班=补班。
enum ChineseDutyMark { rest, work }

/// 公历某日的农历 / 节气 / 节日 / 调休信息。
class ChineseDayInfo {
  const ChineseDayInfo({
    required this.date,
    required this.lunarDayLabel,
    required this.headerLine,
    required this.cellSubtitle,
    this.duty,
    this.festivalName,
  });

  final DateTime date;

  /// 农历日简写，如「十八」「初一」。
  final String lunarDayLabel;

  /// 选中日标题副行，如「丙午年 | 八月十八 星期一」。
  final String headerLine;

  /// 格子内农历/节日文案。
  final String cellSubtitle;

  /// 调休标记；无则不显示。
  final ChineseDutyMark? duty;

  /// 主要节日名（法定或民俗），可为空。
  final String? festivalName;

  bool get isRest => duty == ChineseDutyMark.rest;
  bool get isWork => duty == ChineseDutyMark.work;
}

/// 基于 [lunar] 包解析中文历日信息（含法定节假日调休）。
class ChineseCalendar {
  ChineseCalendar._();

  static final Map<String, ChineseDayInfo> _cache = {};

  static ChineseDayInfo of(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _cache.putIfAbsent(key, () => _resolve(date));
  }

  static void clearCache() => _cache.clear();

  /// ISO 风格周序号（周日为一周起始，与常见中文日历一致）。
  static int weekOfYear(DateTime date) =>
      SolarWeek.fromYmd(date.year, date.month, date.day, 0).getIndexInYear();

  static ChineseDayInfo _resolve(DateTime date) {
    final solar = Solar.fromYmd(date.year, date.month, date.day);
    final lunar = solar.getLunar();
    final holiday = HolidayUtil.getHolidayByYmd(
      date.year,
      date.month,
      date.day,
    );

    final lunarDay = lunar.getDayInChinese();
    final lunarMonth = lunar.getMonthInChinese();
    final lunarDayLabel = lunarDay == '初一' ? '$lunarMonth月' : lunarDay;

    final jieQi = lunar.getJieQi().trim();
    final festivals = <String>[
      ...lunar.getFestivals(),
      ...solar.getFestivals(),
      ...solar.getOtherFestivals(),
    ];

    String? festivalName;
    if (holiday != null && !holiday.isWork()) {
      festivalName = _shorten(holiday.getName());
    }
    festivalName ??= festivals.isEmpty ? null : _shorten(festivals.first);

    final cellSubtitle = () {
      if (festivalName != null && festivalName.isNotEmpty) return festivalName;
      if (jieQi.isNotEmpty) return jieQi;
      return lunarDayLabel;
    }();

    ChineseDutyMark? duty;
    if (holiday != null) {
      duty = holiday.isWork() ? ChineseDutyMark.work : ChineseDutyMark.rest;
    }

    final weekDay = '星期${solar.getWeekInChinese()}';
    final headerLine =
        '${lunar.getYearInGanZhi()}年 | $lunarMonth月$lunarDay $weekDay';

    return ChineseDayInfo(
      date: DateTime(date.year, date.month, date.day),
      lunarDayLabel: lunarDayLabel,
      headerLine: headerLine,
      cellSubtitle: cellSubtitle,
      duty: duty,
      festivalName: festivalName,
    );
  }

  static String _shorten(String name) {
    var text = name.trim();
    if (text.endsWith('节') && text.length > 4) {
      // 教师节等保持；过长纪念名截断
    }
    if (text.length > 4) {
      text = text.substring(0, 4);
    }
    return text;
  }
}
