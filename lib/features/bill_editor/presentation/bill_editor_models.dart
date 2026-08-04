import 'package:equatable/equatable.dart';

/// 分类拆分行（分类 + 金额）。
class CategoryAmountRow extends Equatable {
  final int? categoryId;
  final String? categoryName;
  final double amount;

  const CategoryAmountRow({this.categoryId, this.categoryName, this.amount = 0});

  CategoryAmountRow copyWith({
    int? categoryId,
    String? categoryName,
    double? amount,
  }) {
    return CategoryAmountRow(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [categoryId, categoryName, amount];
}

/// 附加费用行。
class ExtraRow extends Equatable {
  /// 手续费1 / 优惠2
  final int extraType;

  final double amount;

  /// 转出from=1 / 转入to=2
  final int accountSide;
  final int? categoryId;
  final String? remark;

  const ExtraRow({
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
      extraType: extraType ?? this.extraType,
      amount: amount ?? this.amount,
      accountSide: accountSide ?? this.accountSide,
      categoryId: categoryId ?? this.categoryId,
      remark: remark ?? this.remark,
    );
  }

  @override
  List<Object?> get props =>
      [extraType, amount, accountSide, categoryId, remark];
}
