import 'package:flutter/material.dart';

/// 亮色中性基准；业务界面通过 FxPalette 获取当前主题语义色。
/// 业务语义色（收入/支出/转账/调整）另由 [FxFinanceColors] ThemeExtension 承载，
/// 但常量值在此集中定义，两者保持一致。
abstract final class FxColors {
  // 主色
  static const Color primary = Color(0xFF0059D6);
  static const Color primaryContainer = Color(0xFFEBF2FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 业务语义色（默认遵循国内记账习惯：支出绿、收入红；用户可在偏好中自定义）
  static const Color income = Color(0xFFEF4444);
  static const Color expense = Color(0xFF16A34A);
  static const Color transfer = Color(0xFF7C3AED);
  static const Color adjust = Color(0xFFF59E0B);

  // 中性阶
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF52525B);
  static const Color textTertiary = Color(0xFF6C6C75);

  // 表面
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F0F2);
  static const Color canvas = Color(0xFFF6F6F7);
  static const Color border = Color(0xFFE2E2E6);

  // 语义
  static const Color success = Color(0xFF18733C);
  static const Color warning = Color(0xFF925B0E);
  static const Color danger = Color(0xFFC63333);
  static const Color info = Color(0xFF006C9C);

  // 阴影
  static const Color shadow = Color(0x14000000); // 8% black

  const FxColors._();
}
