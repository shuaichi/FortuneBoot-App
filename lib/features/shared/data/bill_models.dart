import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 跨页面传递的账单日期闭区间。
///
/// API 仅接受自然日字符串，因此范围在创建时被归一化为当天开始和结束。
class BillDateRange extends Equatable {
  BillDateRange({required DateTime start, required DateTime end})
    : start = DateTime(start.year, start.month, start.day),
      end = DateTime(end.year, end.month, end.day, 23, 59, 59, 999, 999) {
    if (this.end.isBefore(this.start)) {
      throw ArgumentError.value(end, 'end', 'must not be before start');
    }
  }

  final DateTime start;
  final DateTime end;

  static final DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  String get startDate => _dayFormat.format(start);
  String get endDate => _dayFormat.format(end);

  @override
  List<Object> get props => [start, end];
}

/// Calendar 等调用方进入 Bills 时使用的稳定参数契约。
///
/// [groupId] 是调用方上下文校验信息；后端账单查询只能使用 [bookId]。
class BillsEntryRequest extends Equatable {
  const BillsEntryRequest({this.bookId, this.groupId, this.dateRange});

  final int? bookId;
  final int? groupId;
  final BillDateRange? dateRange;

  @override
  List<Object?> get props => [bookId, groupId, dateRange];
}

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

  /// 中文默认标签（无 context 兜底 / 日志用）。UI 显示请用 [localizedLabel]。
  final String label;

  /// 本地化标签（随语言切换）。
  String localizedLabel(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case FxBillType.expense:
        return s.billTypeExpense;
      case FxBillType.income:
        return s.billTypeIncome;
      case FxBillType.transfer:
        return s.billTypeTransfer;
      case FxBillType.adjust:
        return s.billTypeAdjust;
      case FxBillType.advance:
        return s.billTypeAdvance;
      case FxBillType.reimburse:
        return s.billTypeReimburse;
    }
  }

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

  /// 周期记账模板可选类型（与 Web 一致：支出/收入/转账；垫付报销需单据，周期不支持）。
  static const List<FxBillType> recurringSelectable = [
    expense,
    income,
    transfer,
  ];
}

/// 分类+金额对。
class BillCategoryAmount {
  final int? categoryId;
  final String? categoryName;
  final double amount;

  const BillCategoryAmount({
    this.categoryId,
    this.categoryName,
    this.amount = 0,
  });

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
      categoryAmountPair: mapList(
        json['categoryAmountPair'],
        BillCategoryAmount.fromJson,
      ),
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
    return sorted
        .map((e) => e.categoryName ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// 展示金额（多分类取和，否则 amount）。不含手续费/优惠。
  double get displayAmount {
    if (categoryAmountPair.isNotEmpty) {
      return categoryAmountPair.fold<double>(0, (s, e) => s + e.amount);
    }
    return amount;
  }

  /// 手续费合计（extraType=1）。
  double get feeTotal => extras
      .where((e) => e.extraType == 1 && e.amount > 0)
      .fold<double>(0, (s, e) => s + e.amount);

  /// 优惠合计（extraType=2）。
  double get discountTotal => extras
      .where((e) => e.extraType == 2 && e.amount > 0)
      .fold<double>(0, (s, e) => s + e.amount);

  /// 是否有手续费/优惠调整。
  bool get hasExtrasAdjustment => feeTotal > 0 || discountTotal > 0;

  /// 结算金额 = 原价 + 手续费 - 优惠（与 Web 一致）。
  double get settledAmount => displayAmount + feeTotal - discountTotal;

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty)
      return DateTime.tryParse(v.replaceFirst(' ', 'T'));
    return null;
  }
}
