import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

/// 账单列表筛选条件。
class BillsFilter extends Equatable {
  /// 账单类型多选（1支出 2收入 3转账 7垫付 8报销）。空表示不限。
  final Set<int> billTypes;
  final double? amountMin;
  final double? amountMax;

  /// 确认状态：null 不限、true 已确认、false 未确认。
  final bool? confirm;

  /// 统计状态：null 不限、true 统计、false 不统计。
  final bool? include;

  final List<int>? categoryIds;
  final List<int>? tagIds;
  final List<int>? memberIds;
  final int? accountId;
  final int? payeeId;
  final BillDateRange? dateRange;

  /// 标题查询关键词（按标题模糊匹配）。null/空串表示不限。
  final String? title;

  BillsFilter({
    Set<int> billTypes = const {},
    this.amountMin,
    this.amountMax,
    this.confirm,
    this.include,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? memberIds,
    this.accountId,
    this.payeeId,
    this.dateRange,
    this.title,
  }) : billTypes = UnmodifiableSetView(Set<int>.of(billTypes)),
       categoryIds = categoryIds == null
           ? null
           : List.unmodifiable(categoryIds),
       tagIds = tagIds == null ? null : List.unmodifiable(tagIds),
       memberIds = memberIds == null ? null : List.unmodifiable(memberIds);

  static final BillsFilter empty = BillsFilter();

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
    if (memberIds != null && memberIds!.isNotEmpty) n++;
    if (dateRange != null) n++;
    if (title != null && title!.isNotEmpty) n++;
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
    List<int>? memberIds,
    int? accountId,
    int? payeeId,
    BillDateRange? dateRange,
    String? title,
    bool clearAmountMin = false,
    bool clearAmountMax = false,
    bool clearConfirm = false,
    bool clearInclude = false,
    bool clearCategoryIds = false,
    bool clearTagIds = false,
    bool clearMemberIds = false,
    bool clearAccountId = false,
    bool clearPayeeId = false,
    bool clearDateRange = false,
    bool clearTitle = false,
  }) {
    return BillsFilter(
      billTypes: billTypes ?? this.billTypes,
      amountMin: clearAmountMin ? null : (amountMin ?? this.amountMin),
      amountMax: clearAmountMax ? null : (amountMax ?? this.amountMax),
      confirm: clearConfirm ? null : (confirm ?? this.confirm),
      include: clearInclude ? null : (include ?? this.include),
      categoryIds: clearCategoryIds ? null : (categoryIds ?? this.categoryIds),
      tagIds: clearTagIds ? null : (tagIds ?? this.tagIds),
      memberIds: clearMemberIds ? null : (memberIds ?? this.memberIds),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      payeeId: clearPayeeId ? null : (payeeId ?? this.payeeId),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      title: clearTitle ? null : (title ?? this.title),
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
    memberIds,
    accountId,
    payeeId,
    dateRange,
    title,
  ];
}
