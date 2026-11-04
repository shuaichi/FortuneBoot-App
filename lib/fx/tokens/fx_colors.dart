import 'package:flutter/material.dart';

/// Bento 金融风色板（亮色为主）。所有页面通过 [FxColors] 取色，杜绝硬编码。
/// 业务语义色（收入/支出/转账/调整）另由 [FxFinanceColors] ThemeExtension 承载，
/// 但常量值在此集中定义，两者保持一致。
abstract final class FxColors {
  // 主色
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryContainer = Color(0xFFE8F1FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 业务语义色（默认遵循国内记账习惯：支出绿、收入红；用户可在偏好中自定义）
  static const Color income = Color(0xFFEF4444);
  static const Color expense = Color(0xFF16A34A);
  static const Color transfer = Color(0xFF7C3AED);
  static const Color adjust = Color(0xFFF59E0B);

  // 中性阶
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF5B6470);
  static const Color textTertiary = Color(0xFF646C78);

  // 表面
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F6F8);
  static const Color canvas = Color(0xFFEEF0F4);
  static const Color border = Color(0xFFE5E7EB);

  // 语义
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // 阴影
  static const Color shadow = Color(0x14000000); // 8% black

  const FxColors._();
}
