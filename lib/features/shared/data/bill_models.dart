import 'package:fortuneboot/core/network/fx_api.dart';

/// 账单类型：1支出 2收入 3转账 4余额调整 7垫付 8报销（后端跳号，无5/6）。
enum FxBillType {
  expense(1, '支出'),
  income(2, '收入'),
  transfer(3, '转账'),
  adjust(4, '余额调整'),
  advance(7, '垫付'),
  reimburse(8, '报销');

  const FxBillType(this.value, this.label);
  final int value;
  final String label;

  static FxBillType? fromValue(int? v) {
    for (final t in FxBillType.values) {
      if (t.value == v) return t;
    }
    return null;
  }

  /// BillEditor 可手选的 5 种类型（排除系统 adjust）。
  static const List<FxBillType> selectable = [
    expense,
    income,
    transfer,
    advance,
    reimburse,
  ];
}

/// 分类+金额对。
class BillCategoryAmount {
  final int? categoryId;
  final String? categoryName;
  final double amount;

  const BillCategoryAmount({this.categoryId, this.categoryName, this.amount = 0});

  factory BillCategoryAmount.fromJson(Map<String, dynamic> json) {
    return BillCategoryAmount(
      categoryId: FxApi.asId(json['categoryId']),
      categoryName: json['categoryName']?.toString(),
      amount: FxApi.asDouble(json['amount']) ?? 0,
    );
  }

  Map<String, dynamic> toAddJson() => {
        'categoryId': categoryId,
        'amount': amount,
      };
}

/// 账单标签（简版，列表/详情展示用）。
class BillTag {
  final int? tagId;
  final String? tagName;
  const BillTag({this.tagId, this.tagName});

  factory BillTag.fromJson(Map<String, dynamic> json) => BillTag(
        tagId: FxApi.asId(json['tagId'] ?? json['id']),
        tagName: json['tagName']?.toString(),
      );
}

/// 账单成员（简版）。
class BillMember {
  final int? memberId;
  final String? memberName;
  const BillMember({this.memberId, this.memberName});

  factory BillMember.fromJson(Map<String, dynamic> json) => BillMember(
        memberId: FxApi.asId(json['memberId'] ?? json['id']),
        memberName: json['memberName']?.toString(),
      );
}

/// 附加费用：1手续费/2优惠；accountSide 1转出from/2转入to。
class BillExtra {
  final int? extraId;
  final int? extraType;
  final double amount;
  final int? accountSide;
  final int? categoryId;
  final String? remark;

  const BillExtra({
    this.extraId,
    this.extraType,
    this.amount = 0,
    this.accountSide,
    this.categoryId,
    this.remark,
  });

  factory BillExtra.fromJson(Map<String, dynamic> json) => BillExtra(
        extraId: FxApi.asId(json['extraId']),
        extraType: FxApi.asId(json['extraType']),
        amount: FxApi.asDouble(json['amount']) ?? 0,
        accountSide: FxApi.asId(json['accountSide']),
        categoryId: FxApi.asId(json['categoryId']),
        remark: json['remark']?.toString(),
      );

  Map<String, dynamic> toAddJson() => {
        if (extraType != null) 'extraType': extraType,
        'amount': amount,
        if (accountSide != null) 'accountSide': accountSide,
        if (categoryId != null) 'categoryId': categoryId,
        if (remark != null && remark!.isNotEmpty) 'remark': remark,
      };
}

/// 账单出参 VO。
class FortuneBillVo {
  final int? billId;
  final int? bookId;
  final String? bookName;
  final String? title;
  final DateTime? tradeTime;
  final int? accountId;
  final String? accountName;
  final int? orderId;
  final double amount;
  final String? currencyCode;
  final String? toCurrencyCode;
  final double? convertedAmount;
  final int? payeeId;
  final String? payeeName;
  final int? billType;
  final int? toAccountId;
  final String? toAccountName;
  final bool confirm;
  final bool include;
  final String? remark;
  final bool hasFile;
  final List<BillCategoryAmount> categoryAmountPair;
  final List<BillTag> tagList;
  final List<BillMember> memberList;
  final List<BillExtra> extras;

  const FortuneBillVo({
    this.billId,
    this.bookId,
    this.bookName,
    this.title,
    this.tradeTime,
    this.accountId,
    this.accountName,
    this.orderId,
    this.amount = 0,
    this.currencyCode,
    this.toCurrencyCode,
    this.convertedAmount,
    this.payeeId,
    this.payeeName,
    this.billType,
    this.toAccountId,
    this.toAccountName,
    this.confirm = true,
    this.include = true,
    this.remark,
    this.hasFile = false,
    this.categoryAmountPair = const [],
    this.tagList = const [],
    this.memberList = const [],
    this.extras = const [],
  });

  factory FortuneBillVo.fromJson(Map<String, dynamic> json) {
    List<T> mapList<T>(dynamic v, T Function(Map<String, dynamic>) f) {
      if (v is List) {
        return v
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => f(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    }

    return FortuneBillVo(
      billId: FxApi.asId(json['billId']),
      bookId: FxApi.asId(json['bookId']),
      bookName: json['bookName']?.toString(),
      title: json['title']?.toString(),
      tradeTime: _parseDateTime(json['tradeTime']),
      accountId: FxApi.asId(json['accountId']),
      accountName: json['accountName']?.toString(),
      orderId: FxApi.asId(json['orderId']),
      amount: FxApi.asDouble(json['amount']) ?? 0,
      currencyCode: json['currencyCode']?.toString(),
      toCurrencyCode: json['toCurrencyCode']?.toString(),
      convertedAmount: FxApi.asDouble(json['convertedAmount']),
      payeeId: FxApi.asId(json['payeeId']),
      payeeName: json['payeeName']?.toString(),
      billType: FxApi.asId(json['billType']),
      toAccountId: FxApi.asId(json['toAccountId']),
      toAccountName: json['toAccountName']?.toString(),
      confirm: FxApi.asBool(json['confirm'], orElse: true),
      include: FxApi.asBool(json['include'], orElse: true),
      remark: json['remark']?.toString(),
      hasFile: FxApi.asBool(json['hasFile']),
      categoryAmountPair:
          mapList(json['categoryAmountPair'], BillCategoryAmount.fromJson),
      tagList: mapList(json['tagList'], BillTag.fromJson),
      memberList: mapList(json['memberList'], BillMember.fromJson),
      extras: mapList(json['extras'], BillExtra.fromJson),
    );
  }

  /// 主分类名（金额最大的分类）。
  String get primaryCategoryName {
    if (categoryAmountPair.isEmpty) return '';
    final sorted = [...categoryAmountPair]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.first.categoryName ?? '';
  }

  /// 分类名列表（金额降序，供图标引擎）。
  List<String> get categoryNamesByAmount {
    final sorted = [...categoryAmountPair]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.map((e) => e.categoryName ?? '').where((s) => s.isNotEmpty).toList();
  }

  /// 展示金额（多分类取和，否则 amount）。
  double get displayAmount {
    if (categoryAmountPair.isNotEmpty) {
      return categoryAmountPair.fold<double>(0, (s, e) => s + e.amount);
    }
    return amount;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v.replaceFirst(' ', 'T'));
    return null;
  }
}
