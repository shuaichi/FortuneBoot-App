import 'package:equatable/equatable.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';

/// V2 单据金额的精确表示。
///
/// 服务端契约要求金额以两位十进制字符串传输。客户端所有新单据计算都使用
/// [cents]，禁止先转成 double 再计算或比较。
class OrderMoney extends Equatable implements Comparable<OrderMoney> {
  static const int maxCents = 99999999999999; // 999999999999.99

  final int cents;

  const OrderMoney._(this.cents);

  factory OrderMoney.fromCents(int cents) => OrderMoney._(cents);

  /// 解析服务端响应中的金额。允许 0 与负数（例如待核对单据的净收支）。
  factory OrderMoney.parse(String value) {
    final cents = _parseDecimal(value, allowNegative: true);
    if (cents.abs() > maxCents) {
      throw _invalidAmount();
    }
    return OrderMoney._(cents);
  }

  /// 解析用户输入。仅允许正数、最多两位小数且不超过后端上限。
  factory OrderMoney.parseInput(String value) {
    final cents = _parseDecimal(value, allowNegative: false);
    if (cents <= 0 || cents > maxCents) {
      throw _invalidAmount();
    }
    return OrderMoney._(cents);
  }

  /// 兼容旧 JSON number、V2 字符串，以及 `{amount|value}` 包装。
  /// 响应侧允许超过两位小数，按分截断；用户输入仍走 [parseInput] 严格校验。
  factory OrderMoney.fromJson(dynamic value) {
    if (value == null) {
      throw _invalidAmount();
    }
    if (value is Map) {
      final map = Map<Object?, Object?>.from(value);
      final nested =
          map['amount'] ?? map['value'] ?? map['cents'] ?? map['money'];
      if (nested == null) {
        throw _invalidAmount();
      }
      // cents 字段按整数分解析，避免再走十进制。
      if (map.containsKey('cents') && identical(nested, map['cents'])) {
        final cents = nested is int
            ? nested
            : int.tryParse(nested.toString());
        if (cents == null || cents.abs() > maxCents) {
          throw _invalidAmount();
        }
        return OrderMoney._(cents);
      }
      return OrderMoney.fromJson(nested);
    }
    return OrderMoney.parse(value.toString());
  }

  static int _parseDecimal(String rawValue, {required bool allowNegative}) {
    final value = rawValue.trim();
    // 响应用 allowNegative=true：允许多位小数后截断到分。
    // 输入用 allowNegative=false：最多两位小数。
    final match = RegExp(
      allowNegative ? r'^-?\d+(?:\.\d+)?$' : r'^\d+(?:\.\d{1,2})?$',
    ).firstMatch(value);
    if (match == null) {
      throw _invalidAmount();
    }

    final negative = value.startsWith('-');
    final unsigned = negative ? value.substring(1) : value;
    final dot = unsigned.indexOf('.');
    final wholePart = dot < 0 ? unsigned : unsigned.substring(0, dot);
    final rawDecimal = dot < 0 ? '' : unsigned.substring(dot + 1);
    final decimalPart = rawDecimal.isEmpty
        ? '00'
        : rawDecimal.padRight(2, '0').substring(0, 2);

    final whole = int.tryParse(wholePart.isEmpty ? '0' : wholePart);
    final decimal = int.tryParse(decimalPart);
    if (whole == null || decimal == null) {
      throw _invalidAmount();
    }
    final result = whole * 100 + decimal;
    return negative ? -result : result;
  }

  static FxFailure _invalidAmount() => const FxFailure(
    kind: FxFailureKind.invalidResponse,
  );

  OrderMoney operator +(OrderMoney other) =>
      OrderMoney._(cents + other.cents);

  OrderMoney operator -(OrderMoney other) =>
      OrderMoney._(cents - other.cents);

  @override
  int compareTo(OrderMoney other) => cents.compareTo(other.cents);

  String toApiString() {
    final negative = cents < 0;
    final absolute = cents.abs();
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${negative ? '-' : ''}$whole.$fraction';
  }

  @override
  String toString() => toApiString();

  @override
  List<Object> get props => [cents];
}
