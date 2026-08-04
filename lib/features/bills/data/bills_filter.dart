import 'package:equatable/equatable.dart';

/// 账单列表筛选条件（本轮支持：类型多选 / 金额区间 / 确认 / 统计）。
///
/// 分类、标签、账户、交易对象的候选依赖尚未落地的管理模块 service，
/// 故本轮暂不接入 UI（预留字段，见 [categoryIds] / [tagIds] TODO）。
class BillsFilter extends Equatable {
  /// 账单类型多选（1支出 2收入 3转账 7垫付 8报销）。空表示不限。
  final Set<int> billTypes;
  final double? amountMin;
  final double? amountMax;

  /// 确认状态：null 不限、true 已确认、false 未确认。
  final bool? confirm;

  /// 统计状态：null 不限、true 统计、false 不统计。
  final bool? include;

  // TODO(bills): 待 categories/tags/accounts/payees 管理模块 service 落地后接入。
  final List<int>? categoryIds;
  final List<int>? tagIds;
  final int? accountId;
  final int? payeeId;

  const BillsFilter({
    this.billTypes = const {},
    this.amountMin,
    this.amountMax,
    this.confirm,
    this.include,
    this.categoryIds,
    this.tagIds,
    this.accountId,
    this.payeeId,
  });

  static const BillsFilter empty = BillsFilter();

  /// 已激活的筛选条件数（用于筛选图标角标）。
  int get activeCount {
    var n = 0;
    if (billTypes.isNotEmpty) n++;
    if (amountMin != null || amountMax != null) n++;
    if (confirm != null) n++;
    if (include != null) n++;
    if (accountId != null) n++;
    if (payeeId != null) n++;
    if (categoryIds != null && categoryIds!.isNotEmpty) n++;
    if (tagIds != null && tagIds!.isNotEmpty) n++;
    return n;
  }

  bool get isEmpty => activeCount == 0;

  BillsFilter copyWith({
    Set<int>? billTypes,
    double? amountMin,
    double? amountMax,
    bool? confirm,
    bool? include,
    List<int>? categoryIds,
    List<int>? tagIds,
    int? accountId,
    int? payeeId,
  }) {
    return BillsFilter(
      billTypes: billTypes ?? this.billTypes,
      amountMin: amountMin ?? this.amountMin,
      amountMax: amountMax ?? this.amountMax,
      confirm: confirm ?? this.confirm,
      include: include ?? this.include,
      categoryIds: categoryIds ?? this.categoryIds,
      tagIds: tagIds ?? this.tagIds,
      accountId: accountId ?? this.accountId,
      payeeId: payeeId ?? this.payeeId,
    );
  }

  @override
  List<Object?> get props => [
    billTypes,
    amountMin,
    amountMax,
    confirm,
    include,
    categoryIds,
    tagIds,
    accountId,
    payeeId,
  ];
}
