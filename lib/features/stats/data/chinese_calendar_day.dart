import 'package:lunar/lunar.dart';

/// 公历日对应的农历副文案、头部详情与法定假日「班/休」标记。
///
/// 格子副文案优先级：节气 > 节日 > 初一显示「X月」> 农历日。
/// 「班/休」来自 lunar 内置国务院调休表（[HolidayUtil]），
/// 以及安装包内 [HolidayPatchService] 注入的补丁。
class ChineseCalendarDay {
  const ChineseCalendarDay({
    required this.subtitle,
    required this.isFestivalOrTerm,
    required this.yearGanZhiLabel,
    required this.lunarDateLabel,
    required this.weekdayLabel,
    this.workRestLabel,
  });

  /// 日期下方小字：节气 / 节日 / 农历。
  final String subtitle;

  /// 副文案是否为节气或节日（用于强调着色）。
  final bool isFestivalOrTerm;

  /// 干支年，如「丙午年」。
  final String yearGanZhiLabel;

  /// 农历月日，如「八月十八」。
  final String lunarDateLabel;

  /// 星期，如「星期一」。
  final String weekdayLabel;

  /// 右上角「班」或「休」；非调休/放假日为 null。
  final String? workRestLabel;

  /// 头部副行：丙午年 | 八月十八 星期一。
  String get headerDetail =>
      '$yearGanZhiLabel | $lunarDateLabel $weekdayLabel';

  bool get isRest => workRestLabel == '休';
  bool get isWorkdayMakeup => workRestLabel == '班';

  static ChineseCalendarDay of(DateTime date) {
    final solar = Solar.fromYmd(date.year, date.month, date.day);
    final lunar = solar.getLunar();

    final holiday = HolidayUtil.getHolidayByYmd(
      date.year,
      date.month,
      date.day,
    );
    final String? workRest = holiday == null
        ? null
        : (holiday.isWork() ? '班' : '休');

    final resolved = _resolveSubtitle(solar, lunar);
    return ChineseCalendarDay(
      subtitle: resolved.$1,
      isFestivalOrTerm: resolved.$2,
      yearGanZhiLabel: '${lunar.getYearInGanZhi()}年',
      lunarDateLabel:
          '${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}',
      weekdayLabel: '星期${solar.getWeekInChinese()}',
      workRestLabel: workRest,
    );
  }

  static (String, bool) _resolveSubtitle(Solar solar, Lunar lunar) {
    final jieQi = lunar.getJieQi().trim();
    if (jieQi.isNotEmpty) return (jieQi, true);

    for (final name in lunar.getFestivals()) {
      final text = name.toString().trim();
      if (text.isNotEmpty) return (text, true);
    }
    for (final name in solar.getFestivals()) {
      final text = name.toString().trim();
      if (text.isNotEmpty) return (text, true);
    }

    if (lunar.getDay() == 1) {
      return ('${lunar.getMonthInChinese()}月', false);
    }
    return (lunar.getDayInChinese(), false);
  }
}
