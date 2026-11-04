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
/// 垫付默认复用支出色；报销到账默认复用收入色，允许用户单独调整。
/// 节假日默认紫；「休」绿、「班」琥珀。
class FinanceColorPreferences extends Equatable {
  final int income;
  final int expense;
  final int transfer;
  final int adjust;
  final int advance;
  final int reimburse;
  final int holiday;
  final int rest;
  final int work;
  final String preset;

  // 与 FxColors 的常量值保持一致（编译期常量，供默认参数使用）。
  static const int _defaultIncome = 0xFFEF4444;
  static const int _defaultExpense = 0xFF16A34A;
  static const int _defaultTransfer = 0xFF7C3AED;
  static const int _defaultAdjust = 0xFFF59E0B;
  static const int _defaultHoliday = 0xFF7C3AED; // 紫色
  static const int _defaultRest = 0xFF16A34A; // 休
  static const int _defaultWork = 0xFFF59E0B; // 班

  const FinanceColorPreferences({
    this.income = _defaultIncome,
    this.expense = _defaultExpense,
    this.transfer = _defaultTransfer,
    this.adjust = _defaultAdjust,
    this.advance = _defaultExpense,
    this.reimburse = _defaultIncome,
    this.holiday = _defaultHoliday,
    this.rest = _defaultRest,
    this.work = _defaultWork,
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
        reimburse: 0xFFF59E0B,
        rest: 0xFF3B82F6,
        work: 0xFFF59E0B,
        preset: 'deuteranopia',
      ),
      FinanceColorPreset.protanopia => const FinanceColorPreferences(
        income: 0xFFF59E0B,
        expense: 0xFF1E40AF,
        transfer: _defaultTransfer,
        adjust: 0xFF64748B,
        advance: 0xFF1E40AF,
        reimburse: 0xFFF59E0B,
        rest: 0xFF1E40AF,
        work: 0xFFF59E0B,
        preset: 'protanopia',
      ),
      FinanceColorPreset.tritanopia => const FinanceColorPreferences(
        income: 0xFF1E40AF,
        expense: 0xFFDB2777,
        transfer: _defaultTransfer,
        adjust: 0xFFF59E0B,
        advance: 0xFFDB2777,
        reimburse: 0xFF1E40AF,
        rest: 0xFFDB2777,
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
    required int holiday,
    required int rest,
    required int work,
  }) {
    for (final preset in FinanceColorPreset.values) {
      final colors = FinanceColorPreferences.fromPreset(preset.storageValue);
      if (colors.income == income &&
          colors.expense == expense &&
          colors.transfer == transfer &&
          colors.adjust == adjust &&
          colors.advance == advance &&
          colors.reimburse == reimburse &&
          colors.holiday == holiday &&
          colors.rest == rest &&
          colors.work == work) {
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
  Color get holidayColor => Color(holiday);
  Color get restColor => Color(rest);
  Color get workColor => Color(work);

  FinanceColorPreferences copyWith({
    int? income,
    int? expense,
    int? transfer,
    int? adjust,
    int? advance,
    int? reimburse,
    int? holiday,
    int? rest,
    int? work,
    String? preset,
  }) {
    return FinanceColorPreferences(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      adjust: adjust ?? this.adjust,
      advance: advance ?? this.advance,
      reimburse: reimburse ?? this.reimburse,
      holiday: holiday ?? this.holiday,
      rest: rest ?? this.rest,
      work: work ?? this.work,
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
    holiday,
    rest,
    work,
    preset,
  ];
}
