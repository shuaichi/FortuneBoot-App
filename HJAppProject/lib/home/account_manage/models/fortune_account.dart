import 'package:hjproject/util/currency_symbol.dart';
import 'package:intl/intl.dart';

class FortuneAccount {
  final int? accountId;
  final String? cardNo;
  final String? accountName;
  final double? balance;
  final DateTime? billDay;
  final DateTime? repayDay;
  final bool canExpense;
  final bool canIncome;
  final bool canTransferOut;
  final bool canTransferIn;
  final double? creditLimit;
  final String? currencyCode;
  final bool enable;
  final bool include;
  final double? apr;
  final double? initialBalance;
  final int? accountType;
  final int? groupId;
  final int? sort;
  final String? remark;

  /// 自定义图标名（Iconify 名称，如 ep:wallet）；为空时按账户类型取默认图标
  final String? icon;

  FortuneAccount({
    this.accountId,
    this.cardNo,
    this.accountName,
    this.balance,
    this.billDay,
    this.repayDay,
    this.canExpense = false,
    this.canIncome = false,
    this.canTransferOut = false,
    this.canTransferIn = false,
    this.creditLimit,
    this.currencyCode,
    this.enable = true,
    this.include = true,
    this.apr,
    this.initialBalance,
    this.accountType,
    this.groupId,
    this.sort,
    this.remark,
    this.icon,
  });

  factory FortuneAccount.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    bool _toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    return FortuneAccount(
      accountId: json['accountId'] as int?,
      cardNo: json['cardNo']?.toString(),
      accountName: json['accountName']?.toString(),
      balance: _toDouble(json['balance']),
      billDay: json['billDay'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['billDay']!.toString())
          : null,
      repayDay: json['repayDay'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['repayDay']!.toString())
          : null,
      canExpense: _toBool(json['canExpense']),
      canIncome: _toBool(json['canIncome']),
      canTransferOut: _toBool(json['canTransferOut']),
      canTransferIn: _toBool(json['canTransferIn']),
      creditLimit: _toDouble(json['creditLimit']),
      currencyCode: json['currencyCode']?.toString(),
      enable: _toBool(json['enable']),
      include: _toBool(json['include']),
      apr: _toDouble(json['apr']),
      initialBalance: _toDouble(json['initialBalance']),
      accountType: (json['accountType'] as num?)?.toInt(),
      groupId: (json['groupId'] as num?)?.toInt(),
      sort: (json['sort'] as num?)?.toInt(),
      remark: json['remark']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  // 缓存：current locale or default -> NumberFormat('#,##0.00')
  static final Map<String, NumberFormat> _decimalFmtCache = {};

  // 使用当前应用的 locale；若不可用则交由 NumberFormat 使用其默认配置（不在模型内兜底）
  static NumberFormat _getDecimalFormatter() {
    final l = Intl.getCurrentLocale();
    if (l.isEmpty) {
      return _decimalFmtCache.putIfAbsent(
        '_default',
        () => NumberFormat('#,##0.00'),
      );
    }
    return _decimalFmtCache.putIfAbsent(
      l,
      () => NumberFormat('#,##0.00', l),
    );
  }

  String get currencySymbol {
    final code = currencyCode ?? '';
    if (code.isEmpty) return '';
    return getCurrencySymbol(code);
  }

  String get balanceText {
    final num v = balance ?? 0;
    // 数字分组与小数位使用当前应用语言环境；若无可用 locale 则由 NumberFormat 默认规则处理
    final amount = _getDecimalFormatter().format(v);
    final sym = currencySymbol;
    if (sym.isEmpty) {
      return amount;
    }
    return '$sym$amount';
  }
}

class FortuneAccountPageData {
  final List<FortuneAccount> rows;
  final int total;
  final int? pageNum;
  final int? pageSize;

  FortuneAccountPageData({
    required this.rows,
    required this.total,
    this.pageNum,
    this.pageSize,
  });

  factory FortuneAccountPageData.fromJson(Map<String, dynamic> json) {
    final list = (json['rows'] as List? ?? [])
        .map(
            (e) => FortuneAccount.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return FortuneAccountPageData(
      rows: list,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      pageNum: (json['pageNum'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
    );
  }
}
