import 'dart:ui';
import 'package:flutter/material.dart';

/// 全局 UI 状态机 (HJDS-EX v2.2 约束)
enum UIState { loading, success, empty, error, disabled }

/// 8dp 间距系统
class HJSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// 顶级 Fintech 色彩系统
class HJColors {
  static const Color background = Color(0xFFF2F4F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color divider = Color(0xFFE5E5EA); // Hairline
  static const Color income = Color(0xFF34C759); // iOS Green
  static const Color expense = Color(0xFFFF3B30); // iOS Red
  static const Color primary = Color(0xFF007AFF); // iOS Blue
}

/// 财务语义主题扩展
@immutable
class FinanceTheme extends ThemeExtension<FinanceTheme> {
  final Color income;
  final Color expense;
  final Color transfer;
  final Color balance;
  final Color pending;

  const FinanceTheme({
    this.income = HJColors.income,
    this.expense = HJColors.expense,
    this.transfer = HJColors.primary,
    this.balance = HJColors.textPrimary,
    this.pending = const Color(0xFFFF9500),
  });

  @override
  FinanceTheme copyWith(
      {Color? income,
        Color? expense,
        Color? transfer,
        Color? balance,
        Color? pending}) {
    return FinanceTheme(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      balance: balance ?? this.balance,
      pending: pending ?? this.pending,
    );
  }

  @override
  FinanceTheme lerp(ThemeExtension<FinanceTheme>? other, double t) {
    if (other is! FinanceTheme) return this;
    return FinanceTheme(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      balance: Color.lerp(balance, other.balance, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
    );
  }
}

/// 等宽数字排版系统 (Tabular Figures)
class HJTypography {
  static const TextStyle display = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: HJColors.textPrimary,
    fontFeatures:[FontFeature.tabularFigures()],
  );

  static const TextStyle tabularBody = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: HJColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: HJColors.textPrimary,
    height: 1.25,
  );
}