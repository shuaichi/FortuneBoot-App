import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/calendar/chinese_day_info.dart';

void main() {
  tearDown(ChineseCalendar.clearCache);

  test('resolves lunar subtitle and header for a normal day', () {
    final info = ChineseCalendar.of(DateTime(2026, 9, 28));
    expect(info.lunarDayLabel, isNotEmpty);
    expect(info.headerLine, contains('年'));
    expect(info.headerLine, contains('星期'));
    expect(info.cellSubtitle, isNotEmpty);
  });

  test('marks Mid-Autumn holiday rest in 2026', () {
    // 2026-09-25 中秋节放假（lunar HolidayUtil）
    final info = ChineseCalendar.of(DateTime(2026, 9, 25));
    expect(info.isRest, isTrue);
    expect(info.duty, ChineseDutyMark.rest);
    expect(info.cellSubtitle, contains('中秋'));
  });

  test('marks makeup work day as 班', () {
    // 2026-09-20 中秋/国庆调休补班
    final info = ChineseCalendar.of(DateTime(2026, 9, 20));
    expect(info.isWork, isTrue);
    expect(info.duty, ChineseDutyMark.work);
  });
}
