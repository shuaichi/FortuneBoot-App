import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/recurring/presentation/recurring_formatters.dart';

void main() {
  test('formats execution time for people instead of exposing ISO text', () {
    expect(
      formatRecurringExecutionTime('2026-11-28T09:00:00'),
      '2026-11-28 09:00',
    );
    expect(formatRecurringExecutionTime(null), '-');
  });
}
