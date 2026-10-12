/// 交易对象模型与分页数据
class Payee {
  final int payeeId;
  final int bookId;
  final String payeeName;
  final int? sort;
  final bool canExpense;
  final bool canIncome;
  final bool enable;
  final String? remark;

  /// 自定义图标名（Iconify 名称，如 ep:shop）；为空时使用默认图标
  final String? icon;

  const Payee({
    required this.payeeId,
    required this.bookId,
    required this.payeeName,
    this.sort,
    required this.canExpense,
    required this.canIncome,
    required this.enable,
    this.remark,
    this.icon,
  });

  factory Payee.fromJson(Map<String, dynamic> json) {
    int? parseSort(dynamic s) {
      if (s == null) return null;
      if (s is int) return s;
      if (s is String) return int.tryParse(s);
      return null;
    }

    return Payee(
      payeeId: parseIntFromDynamic(json['payeeId']),
      bookId: parseIntFromDynamic(json['bookId']),
      payeeName: (json['payeeName'] ?? '').toString(),
      sort: parseSort(json['sort']),
      canExpense: (json['canExpense'] as bool?) ?? false,
      canIncome: (json['canIncome'] as bool?) ?? false,
      enable: (json['enable'] as bool?) ?? false,
      remark: json['remark']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  @override
  String toString() {
    return 'Payee(payeeId: $payeeId, name: $payeeName, sort: $sort, canExpense: $canExpense, canIncome: $canIncome, enable: $enable)';
  }
}

class PayeePageData {
  final int total;
  final List<Payee> rows;

  const PayeePageData({
    required this.total,
    required this.rows,
  });

  factory PayeePageData.fromJson(Map<String, dynamic> json) {
    final total = parseIntFromDynamic(json['total']);
    final list = json['rows'];
    final rows = (list is List ? list : const <dynamic>[])
        .map((e) => Payee.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return PayeePageData(total: total, rows: rows);
  }
}

int parseIntFromDynamic(dynamic value, {int defaultValue = 0}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}
