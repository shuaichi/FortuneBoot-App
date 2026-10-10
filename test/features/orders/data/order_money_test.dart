import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';

void main() {
  test('parses response strings without double arithmetic', () {
    final left = OrderMoney.parse('0.10');
    final right = OrderMoney.parse('0.20');
    final result = left + right;

    expect(result.cents, 30);
    expect(result.toApiString(), '0.30');
    expect(left.compareTo(right), isNegative);
  });

  test('parse accepts zero and negative display amounts within limits', () {
    expect(OrderMoney.parse('0').cents, 0);
    expect(OrderMoney.parse('-12.34').cents, -1234);
    expect(OrderMoney.parse('999999999999.99').cents, 99999999999999);
    expect(OrderMoney.parse('-999999999999.99').cents, -99999999999999);
  });

  test('fromJson supports legacy JSON numbers by converting to decimal text', () {
    expect(OrderMoney.fromJson(0.1).toApiString(), '0.10');
    expect(OrderMoney.fromJson(12).toApiString(), '12.00');
    expect(OrderMoney.fromJson('-3.45').toApiString(), '-3.45');
  });

  test('parseInput only accepts a positive amount with at most two decimals', () {
    expect(OrderMoney.parseInput('0.01').cents, 1);
    expect(OrderMoney.parseInput('999999999999.99').cents, 99999999999999);

    expect(() => OrderMoney.parseInput('0'), throwsA(isA<FxFailure>()));
    expect(() => OrderMoney.parseInput('-1'), throwsA(isA<FxFailure>()));
    expect(
      () => OrderMoney.parseInput('999999999999999.99'),
      throwsA(isA<FxFailure>()),
    );
    expect(() => OrderMoney.parseInput('1.234'), throwsA(isA<FxFailure>()));
    expect(() => OrderMoney.parseInput('1e3'), throwsA(isA<FxFailure>()));
    expect(() => OrderMoney.parseInput('abc'), throwsA(isA<FxFailure>()));
    expect(() => OrderMoney.parseInput(''), throwsA(isA<FxFailure>()));
  });

  test('missing or invalid V2 amounts fail as protocol errors instead of zero', () {
    expect(
      () => OrderMoney.fromJson(null),
      throwsA(
        isA<FxFailure>().having(
          (failure) => failure.kind,
          'kind',
          FxFailureKind.invalidResponse,
        ),
      ),
    );
    expect(() => OrderMoney.fromJson('not-a-number'), throwsA(isA<FxFailure>()));
    expect(() => OrderMoney.fromJson(1.234), throwsA(isA<FxFailure>()));
  });

  test('supports exact addition, subtraction and comparison', () {
    final a = OrderMoney.fromCents(100);
    final b = OrderMoney.fromCents(30);

    expect((a - b).cents, 70);
    expect((b + b).compareTo(a), isNegative);
    expect(a == OrderMoney.fromCents(100), isTrue);
  });
}
