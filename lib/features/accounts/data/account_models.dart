import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账户 VO（FortuneAccountVo）。金额 BigDecimal / id 雪花 Long 用 FxApi 宽松解析。
/// billDay / repayDay 为 LocalDate（yyyy-MM-dd），保留原始字符串用于展示与编辑。
class FortuneAccountVo {
  final int? accountId;
  final int? groupId;
  final String? cardNo;
  final String? accountName;
  final double balance;
  final double? initialBalance;
  final String? billDay; // yyyy-MM-dd
  final String? repayDay; // yyyy-MM-dd
  final bool canExpense;
  final bool canIncome;
  final bool canTransferOut;
  final bool canTransferIn;
  final double? creditLimit;
  final double? apr;
  final String? currencyCode;
  final bool enable;
  final bool include;
  final int? accountType;
  final int? sort;
  final String? remark;

  const FortuneAccountVo({
    this.accountId,
    this.groupId,
    this.cardNo,
    this.accountName,
    this.balance = 0,
    this.initialBalance,
    this.billDay,
    this.repayDay,
    this.canExpense = false,
    this.canIncome = false,
    this.canTransferOut = false,
    this.canTransferIn = false,
    this.creditLimit,
    this.apr,
    this.currencyCode,
    this.enable = true,
    this.include = true,
    this.accountType,
    this.sort,
    this.remark,
  });

  factory FortuneAccountVo.fromJson(Map<String, dynamic> json) {
    return FortuneAccountVo(
      accountId: FxApi.asId(json['accountId']),
      groupId: FxApi.asId(json['groupId']),
      cardNo: json['cardNo']?.toString(),
      accountName: json['accountName']?.toString(),
      balance: FxApi.asDouble(json['balance']) ?? 0,
      initialBalance: FxApi.asDouble(json['initialBalance']),
      billDay: json['billDay']?.toString(),
      repayDay: json['repayDay']?.toString(),
      canExpense: FxApi.asBool(json['canExpense']),
      canIncome: FxApi.asBool(json['canIncome']),
      canTransferOut: FxApi.asBool(json['canTransferOut']),
      canTransferIn: FxApi.asBool(json['canTransferIn']),
      creditLimit: FxApi.asDouble(json['creditLimit']),
      apr: FxApi.asDouble(json['apr']),
      currencyCode: json['currencyCode']?.toString(),
      enable: FxApi.asBool(json['enable'], orElse: true),
      include: FxApi.asBool(json['include'], orElse: true),
      accountType: FxApi.asId(json['accountType']),
      sort: FxApi.asId(json['sort']),
      remark: json['remark']?.toString(),
    );
  }

  /// 卡号末四位（不足四位则原样）。
  String? get lastFour {
    final n = cardNo?.trim();
    if (n == null || n.isEmpty) return null;
    return n.length <= 4 ? n : n.substring(n.length - 4);
  }

  /// 负债账户展示为负数余额。
  bool get isLiability => AccountTypeMeta.of(accountType).isLiability;

  /// 展示余额：好记负债账户「余额为负表示欠款」，直接展示后端符号。
  /// 勿用 abs 强行取负——正余额表示溢缴/未欠款，不是已用额度。
  double get displayBalance => balance;

  /// 信用卡/贷款已用额度：欠款 = max(0, -balance)；未使用或溢缴为 0。
  double get usedCreditAmount => balance < 0 ? -balance : 0;

  FortuneAccountVo copyWith({
    bool? canExpense,
    bool? canIncome,
    bool? canTransferOut,
    bool? canTransferIn,
    bool? include,
    bool? enable,
  }) {
    return FortuneAccountVo(
      accountId: accountId,
      groupId: groupId,
      cardNo: cardNo,
      accountName: accountName,
      balance: balance,
      initialBalance: initialBalance,
      billDay: billDay,
      repayDay: repayDay,
      canExpense: canExpense ?? this.canExpense,
      canIncome: canIncome ?? this.canIncome,
      canTransferOut: canTransferOut ?? this.canTransferOut,
      canTransferIn: canTransferIn ?? this.canTransferIn,
      creditLimit: creditLimit,
      apr: apr,
      currencyCode: currencyCode,
      enable: enable ?? this.enable,
      include: include ?? this.include,
      accountType: accountType,
      sort: sort,
      remark: remark,
    );
  }
}

/// 净资产总览：总资产 / 总负债 / 净资产。
class AssetsLiabilities {
  final double totalAssets;
  final double totalLiabilities;
  final double netAssets;

  const AssetsLiabilities({
    this.totalAssets = 0,
    this.totalLiabilities = 0,
    this.netAssets = 0,
  });

  factory AssetsLiabilities.fromJson(Map<String, dynamic> json) {
    final assets = FxApi.asDouble(json['totalAssets']) ?? 0;
    final liabilities = FxApi.asDouble(json['totalLiabilities']) ?? 0;
    return AssetsLiabilities(
      totalAssets: assets,
      totalLiabilities: liabilities,
      netAssets: FxApi.asDouble(json['netAssets']) ?? (assets - liabilities),
    );
  }
}

/// 账户类型元数据（AccountTypeEnum 权威：1活期 2信用卡 3资产 4贷款；负债类=2,4）。
class AccountTypeMeta {
  final int id;
  final String name;
  final IconData icon;
  final bool isLiability;

  const AccountTypeMeta({
    required this.id,
    required this.name,
    required this.icon,
    required this.isLiability,
  });

  static const AccountTypeMeta cash = AccountTypeMeta(
    id: 1,
    name: '现金账户',
    icon: Icons.account_balance_wallet_rounded,
    isLiability: false,
  );
  static const AccountTypeMeta credit = AccountTypeMeta(
    id: 2,
    name: '信用卡',
    icon: Icons.credit_card_rounded,
    isLiability: true,
  );
  static const AccountTypeMeta asset = AccountTypeMeta(
    id: 3,
    name: '资产账户',
    icon: Icons.savings_rounded,
    isLiability: false,
  );
  static const AccountTypeMeta loan = AccountTypeMeta(
    id: 4,
    name: '贷款账户',
    icon: Icons.request_quote_rounded,
    isLiability: true,
  );
  static const AccountTypeMeta unknown = AccountTypeMeta(
    id: 0,
    name: '其他账户',
    icon: Icons.account_balance_rounded,
    isLiability: false,
  );

  /// 分组展示顺序：现金 → 信用卡 → 资产 → 贷款。
  static const List<AccountTypeMeta> ordered = [cash, credit, asset, loan];

  static AccountTypeMeta of(int? type) {
    switch (type) {
      case 1:
        return cash;
      case 2:
        return credit;
      case 3:
        return asset;
      case 4:
        return loan;
      default:
        return unknown;
    }
  }

  /// 本地化类型名（展示用）。const [name] 仅作兜底/内部标识。
  String localizedName(BuildContext context) {
    final s = S.of(context);
    switch (id) {
      case 1:
        return s.accountsTypeCash;
      case 2:
        return s.accountsTypeCredit;
      case 3:
        return s.accountsTypeAsset;
      case 4:
        return s.accountsTypeLoan;
      default:
        return s.accountsTypeOther;
    }
  }

  /// 该类型的主色（信息区分用；负债偏红/橙，资产偏蓝/绿）。
  Color tint(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    switch (id) {
      case 1:
        return finance.income;
      case 2:
        return finance.expense;
      case 3:
        return FxPalette.of(context).primary;
      case 4:
        return finance.adjust;
      default:
        return FxPalette.of(context).textSecondary;
    }
  }
}
