import 'package:equatable/equatable.dart';

/// 分类拆分行（分类 + 金额）。
class CategoryAmountRow extends Equatable {
  /// 仅用于编辑器内动态行的稳定身份，不提交到服务端。
  final String rowId;
  final int? categoryId;
  final String? categoryName;
  final double amount;

  const CategoryAmountRow({
    this.rowId = '',
    this.categoryId,
    this.categoryName,
    this.amount = 0,
  });

  CategoryAmountRow copyWith({
    int? categoryId,
    String? categoryName,
    double? amount,
  }) {
    return CategoryAmountRow(
      rowId: rowId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [rowId, categoryId, categoryName, amount];
}

/// 附加费用行。
class ExtraRow extends Equatable {
  /// 仅用于编辑器内动态行的稳定身份，不提交到服务端。
  final String rowId;

  /// 手续费1 / 优惠2
  final int extraType;

  final double amount;

  /// 转出from=1 / 转入to=2
  final int accountSide;
  final int? categoryId;
  final String? remark;

  const ExtraRow({
    this.rowId = '',
    this.extraType = 1,
    this.amount = 0,
    this.accountSide = 1,
    this.categoryId,
    this.remark,
  });

  ExtraRow copyWith({
    int? extraType,
    double? amount,
    int? accountSide,
    int? categoryId,
    String? remark,
  }) {
    return ExtraRow(
      rowId: rowId,
      extraType: extraType ?? this.extraType,
      amount: amount ?? this.amount,
      accountSide: accountSide ?? this.accountSide,
      categoryId: categoryId ?? this.categoryId,
      remark: remark ?? this.remark,
    );
  }

  @override
  List<Object?> get props => [
    rowId,
    extraType,
    amount,
    accountSide,
    categoryId,
    remark,
  ];
}
