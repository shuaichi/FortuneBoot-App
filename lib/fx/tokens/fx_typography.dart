import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';

/// 字体体系。正文用系统 fallback，金额/数字用等宽 tabular figures。
abstract final class FxTypography {
  /// 等宽字体族（金额/数字对齐）。RobotoMono 在多数平台可回退到等宽。
  static const String monoFamily = 'RobotoMono';

  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: FxColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: FxColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: FxColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: FxColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: FxColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: FxColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: FxColors.textTertiary,
  );

  /// 金额基础样式：等宽 + tabular figures。字号/颜色由调用处覆盖。
  static const TextStyle money = TextStyle(
    fontFamily: monoFamily,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
    color: FxColors.textPrimary,
  );

  const FxTypography._();
}
