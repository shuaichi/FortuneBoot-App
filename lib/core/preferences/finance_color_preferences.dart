import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 色盲友好财务色预设。
enum FinanceColorPreset {
  defaults('default'),
  deuteranopia('deuteranopia'),
  protanopia('protanopia'),
  tritanopia('tritanopia');

  const FinanceColorPreset(this.storageValue);
  final String storageValue;

  static FinanceColorPreset fromStorage(String? value) {
    return FinanceColorPreset.values.firstWhere(
      (preset) => preset.storageValue == value,
      orElse: () => FinanceColorPreset.defaults,
    );
  }
}

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
  final String preset;

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
    this.preset = 'default',
  });

  factory FinanceColorPreferences.defaults() => const FinanceColorPreferences();

  factory FinanceColorPreferences.fromPreset(String preset) {
    final normalized = FinanceColorPreset.fromStorage(preset);
    return switch (normalized) {
      FinanceColorPreset.defaults => const FinanceColorPreferences(),
      FinanceColorPreset.deuteranopia => const FinanceColorPreferences(
        income: 0xFFF59E0B,
        expense: 0xFF3B82F6,
        transfer: _defaultTransfer,
        adjust: 0xFF64748B,
        advance: 0xFF3B82F6,
        reimburse: 0xFF3B82F6,
        preset: 'deuteranopia',
      ),
      FinanceColorPreset.protanopia => const FinanceColorPreferences(
        income: 0xFFF59E0B,
        expense: 0xFF1E40AF,
        transfer: _defaultTransfer,
        adjust: 0xFF64748B,
        advance: 0xFF1E40AF,
        reimburse: 0xFF1E40AF,
        preset: 'protanopia',
      ),
      FinanceColorPreset.tritanopia => const FinanceColorPreferences(
        income: 0xFF1E40AF,
        expense: 0xFFDB2777,
        transfer: _defaultTransfer,
        adjust: 0xFFF59E0B,
        advance: 0xFFDB2777,
        reimburse: 0xFFDB2777,
        preset: 'tritanopia',
      ),
    };
  }

  static String inferPreset({
    required int income,
    required int expense,
    required int transfer,
    required int adjust,
    required int advance,
    required int reimburse,
  }) {
    for (final preset in FinanceColorPreset.values) {
      final colors = FinanceColorPreferences.fromPreset(preset.storageValue);
      if (colors.income == income &&
          colors.expense == expense &&
          colors.transfer == transfer &&
          colors.adjust == adjust &&
          colors.advance == advance &&
          colors.reimburse == reimburse) {
        return preset.storageValue;
      }
    }
    return 'custom';
  }

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
    String? preset,
  }) {
    return FinanceColorPreferences(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      adjust: adjust ?? this.adjust,
      advance: advance ?? this.advance,
      reimburse: reimburse ?? this.reimburse,
      preset: preset ?? this.preset,
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
    preset,
  ];
}
