import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/data/chinese_calendar_day.dart';

void main() {
  group('ChineseCalendarDay', () {
    test('shows lunar day for ordinary dates', () {
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 28));
      expect(day.subtitle, isNotEmpty);
      expect(day.isFestivalOrTerm, isFalse);
    });

    test('prefers solar term over lunar day', () {
      // 2026-09-07 白露
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 7));
      expect(day.subtitle, '白露');
      expect(day.isFestivalOrTerm, isTrue);
    });

    test('shows Teachers Day festival', () {
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 10));
      expect(day.subtitle, '教师节');
      expect(day.isFestivalOrTerm, isTrue);
    });

    test('shows Mid-Autumn festival and rest mark', () {
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 25));
      expect(day.subtitle, '中秋节');
      expect(day.isFestivalOrTerm, isTrue);
      expect(day.workRestLabel, '休');
    });

    test('shows makeup workday mark', () {
      // 2026-09-20 国庆调休上班
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 20));
      expect(day.workRestLabel, '班');
    });

    test('shows lunar month name on first day of lunar month', () {
      // 2026-09-11 农历八月初一
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 11));
      expect(day.subtitle, endsWith('月'));
      expect(day.isFestivalOrTerm, isFalse);
    });

    test('builds header detail with ganZhi year, lunar date and weekday', () {
      final day = ChineseCalendarDay.of(DateTime(2026, 9, 28));
      expect(day.yearGanZhiLabel, endsWith('年'));
      expect(day.lunarDateLabel, contains('月'));
      expect(day.weekdayLabel, startsWith('星期'));
      expect(day.headerDetail, contains(' | '));
      expect(day.headerDetail, contains(day.yearGanZhiLabel));
      expect(day.headerDetail, contains(day.lunarDateLabel));
      expect(day.headerDetail, contains(day.weekdayLabel));
    });

    test('marks New Year and Spring Festival as rest days when table exists', () {
      expect(ChineseCalendarDay.of(DateTime(2026, 1, 1)).workRestLabel, '休');
      expect(ChineseCalendarDay.of(DateTime(2026, 2, 17)).workRestLabel, '休');
    });
  });
}
