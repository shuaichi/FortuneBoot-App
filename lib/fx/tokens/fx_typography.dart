import 'package:flutter/material.dart';

/// 字体体系。正文用系统 fallback，金额/数字用等宽 tabular figures。
///
/// 注意：中性文本样式**不 bake 颜色**，颜色由主题 `TextTheme`（亮/暗自适应）
/// 或调用点 `.copyWith(color:)` 决定。次级/三级灰文本请配合
/// `FxPalette.of(context).textSecondary/textTertiary` 使用，保证暗色模式可读。
abstract final class FxTypography {
  /// 等宽字体族（金额/数字对齐）。RobotoMono 在多数平台可回退到等宽。
  static const String monoFamily = 'RobotoMono';

  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// 金额基础样式：等宽 + tabular figures。字号/颜色由调用处覆盖。
  static const TextStyle money = TextStyle(
    fontFamily: monoFamily,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  const FxTypography._();
}
