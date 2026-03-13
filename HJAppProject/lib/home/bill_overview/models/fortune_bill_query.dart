import 'package:equatable/equatable.dart';

class FortuneBillQuery extends Equatable {
  final int? bookId;
  final int? accountId;
  final int? billType;
  final String? title;
  final String? tradeTimeStartTime;
  final String? tradeTimeEndTime;
  final double? amountMin;
  final double? amountMax;
  final int? orderId;
  final List<int>? categoryIds;
  final List<int>? tagIds;
  final int? payeeId;
  final bool? confirm;
  final bool? include;
  final String? remark;
  final String? orderColumn;

  const FortuneBillQuery({
    this.bookId,
    this.accountId,
    this.billType,
    this.title,
    this.tradeTimeStartTime,
    this.tradeTimeEndTime,
    this.amountMin,
    this.amountMax,
    this.orderId,
    this.categoryIds,
    this.tagIds,
    this.payeeId,
    this.confirm,
    this.include,
    this.remark,
    this.orderColumn,
  });

  // 判断当前查询条件是否为空（用于控制筛选图标的高亮状态）
  bool get isEmpty =>
      accountId == null &&
          billType == null &&
          (title == null || title!.isEmpty) &&
          tradeTimeStartTime == null &&
          tradeTimeEndTime == null &&
          amountMin == null &&
          amountMax == null &&
          categoryIds == null &&
          tagIds == null &&
          payeeId == null &&
          (remark == null || remark!.isEmpty);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (bookId != null) map['bookId'] = bookId;
    if (accountId != null) map['accountId'] = accountId;
    if (billType != null) map['billType'] = billType;
    if (title != null && title!.isNotEmpty) map['title'] = title;
    if (tradeTimeStartTime != null) map['tradeTimeStartTime'] = tradeTimeStartTime;
    if (tradeTimeEndTime != null) map['tradeTimeEndTime'] = tradeTimeEndTime;
    if (amountMin != null) map['amountMin'] = amountMin;
    if (amountMax != null) map['amountMax'] = amountMax;
    if (orderId != null) map['orderId'] = orderId;
    if (categoryIds != null) map['categoryIds'] = categoryIds;
    if (tagIds != null) map['tagIds'] = tagIds;
    if (payeeId != null) map['payeeId'] = payeeId;
    if (confirm != null) map['confirm'] = confirm;
    if (include != null) map['include'] = include;
    if (remark != null && remark!.isNotEmpty) map['remark'] = remark;
    if (orderColumn != null) map['orderColumn'] = orderColumn;
    return map;
  }

  FortuneBillQuery copyWith({
    int? bookId,
    int? accountId,
    int? Function()? billType,
    String? Function()? title,
    String? Function()? tradeTimeStartTime,
    String? Function()? tradeTimeEndTime,
    double? Function()? amountMin,
    double? Function()? amountMax,
    int? orderId,
    List<int>? Function()? categoryIds,
    List<int>? Function()? tagIds,
    int? payeeId,
    bool? confirm,
    bool? include,
    String? Function()? remark,
    String? orderColumn,
  }) {
    return FortuneBillQuery(
      bookId: bookId ?? this.bookId,
      accountId: accountId ?? this.accountId,
      billType: billType != null ? billType() : this.billType,
      title: title != null ? title() : this.title,
      tradeTimeStartTime: tradeTimeStartTime != null ? tradeTimeStartTime() : this.tradeTimeStartTime,
      tradeTimeEndTime: tradeTimeEndTime != null ? tradeTimeEndTime() : this.tradeTimeEndTime,
      amountMin: amountMin != null ? amountMin() : this.amountMin,
      amountMax: amountMax != null ? amountMax() : this.amountMax,
      orderId: orderId ?? this.orderId,
      categoryIds: categoryIds != null ? categoryIds() : this.categoryIds,
      tagIds: tagIds != null ? tagIds() : this.tagIds,
      payeeId: payeeId ?? this.payeeId,
      confirm: confirm ?? this.confirm,
      include: include ?? this.include,
      remark: remark != null ? remark() : this.remark,
      orderColumn: orderColumn ?? this.orderColumn,
    );
  }

  @override
  List<Object?> get props =>[
    bookId, accountId, billType, title, tradeTimeStartTime, tradeTimeEndTime,
    amountMin, amountMax, orderId, categoryIds, tagIds, payeeId, confirm,
    include, remark, orderColumn
  ];
}