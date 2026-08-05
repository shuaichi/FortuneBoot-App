import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 用户自定义账单语义颜色偏好。
///
/// 默认值与 FxColors 保持一致：支出绿、收入红（国内记账习惯）、转账紫、调整橙。
/// 垫付 / 报销默认复用支出色，允许用户单独调整。
class FinanceColorPreferences extends Equatable {
  final int income;
  final int expense;
  final int transfer;
  final int adjust;
  final int advance;
  final int reimburse;

  // 与 FxColors 的常量值保持一致（编译期常量，供默认参数使用）。
  static const int _defaultIncome = 0xFFEF4444;
  static const int _defaultExpense = 0xFF16A34A;
  static const int _defaultTransfer = 0xFF7C3AED;
  static const int _defaultAdjust = 0xFFF59E0B;

  const FinanceColorPreferences({
    this.income = _defaultIncome,
    this.expense = _defaultExpense,
    this.transfer = _defaultTransfer,
    this.adjust = _defaultAdjust,
    this.advance = _defaultExpense,
    this.reimburse = _defaultExpense,
  });

  factory FinanceColorPreferences.defaults() => const FinanceColorPreferences();

  Color get incomeColor => Color(income);
  Color get expenseColor => Color(expense);
  Color get transferColor => Color(transfer);
  Color get adjustColor => Color(adjust);
  Color get advanceColor => Color(advance);
  Color get reimburseColor => Color(reimburse);

  FinanceColorPreferences copyWith({
    int? income,
    int? expense,
    int? transfer,
    int? adjust,
    int? advance,
    int? reimburse,
  }) {
    return FinanceColorPreferences(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      adjust: adjust ?? this.adjust,
      advance: advance ?? this.advance,
      reimburse: reimburse ?? this.reimburse,
    );
  }

  @override
  List<Object?> get props => [
    income,
    expense,
    transfer,
    adjust,
    advance,
    reimburse,
  ];
}
