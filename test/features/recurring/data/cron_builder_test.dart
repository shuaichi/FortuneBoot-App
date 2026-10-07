import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/recurring/data/cron_builder.dart';

void main() {
  group('CronBuilder', () {
    test('builds and parses monthly last-day cron', () {
      const spec = CronSpec(
        frequency: CronFrequency.monthly,
        hour: 9,
        minute: 30,
        dayOfMonth: 31,
        lastDayOfMonth: true,
      );

      final cron = CronBuilder.build(spec);
      final parsed = CronBuilder.tryParse(cron);

      expect(cron, '0 30 9 L * ?');
      expect(parsed, isNotNull);
      expect(parsed!.frequency, CronFrequency.monthly);
      expect(parsed.dayOfMonth, 31);
      expect(parsed.lastDayOfMonth, isTrue);
      expect(parsed.hour, 9);
      expect(parsed.minute, 30);
    });

    test('builds and parses yearly last-day cron', () {
      const spec = CronSpec(
        frequency: CronFrequency.yearly,
        hour: 8,
        minute: 5,
        month: 2,
        dayOfMonth: 31,
        lastDayOfMonth: true,
      );

      final cron = CronBuilder.build(spec);
      final parsed = CronBuilder.tryParse(cron);

      expect(cron, '0 5 8 L 2 ?');
      expect(parsed, isNotNull);
      expect(parsed!.frequency, CronFrequency.yearly);
      expect(parsed.month, 2);
      expect(parsed.dayOfMonth, 31);
      expect(parsed.lastDayOfMonth, isTrue);
    });

    test('keeps regular 31st distinct from last day', () {
      const spec = CronSpec(
        frequency: CronFrequency.monthly,
        hour: 7,
        minute: 0,
        dayOfMonth: 31,
      );

      final cron = CronBuilder.build(spec);
      final parsed = CronBuilder.tryParse(cron);

      expect(cron, '0 0 7 31 * ?');
      expect(parsed, isNotNull);
      expect(parsed!.dayOfMonth, 31);
      expect(parsed.lastDayOfMonth, isFalse);
    });
  });
}
