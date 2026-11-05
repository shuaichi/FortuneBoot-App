import 'package:flutter/material.dart';

/// 系统字体排版：正文优先可读性，数字仅启用等宽数字而不替换字体族。
///
/// 字号均为逻辑像素，继续继承系统 TextScaler；颜色由语义文本或主题提供。
/// @author JoyCode
/// @since 2026/11/05
abstract final class FxTypography {
  /// 仅供 Cron 等技术字符串使用，金额不使用整个等宽字体族。
  static const String monoFamily = 'monospace';

  /// 一级页面或单个核心指标。
  static const TextStyle display = TextStyle(
    fontSize: 34,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 41 / 34,
  );

  /// 页面分区标题。
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  /// 导航栏、弹层和卡片标题。
  static const TextStyle title = TextStyle(
    fontSize: 17,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 22 / 17,
  );

  /// 输入值、说明正文与主要列表内容。
  static const TextStyle body = TextStyle(
    fontSize: 17,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    height: 24 / 17,
  );

  /// 需要强调的正文，避免把全部信息提升至粗体标题。
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 17,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
  );

  /// 密集列表次要内容与控件标签。
  static const TextStyle label = TextStyle(
    fontSize: 15,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
  );

  /// 日期、来源、辅助说明；不用于唯一的操作名称。
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
  );

  /// 金额使用平台系统字体的 tabular figures，保留中文与币种一致的字形。
  static const TextStyle money = TextStyle(
    fontSize: 17,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 将 Material 控件与自定义组件接到同一排版尺度。
  static TextTheme textTheme(TextTheme base) => base.merge(
    const TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: display,
      headlineLarge: display,
      headlineMedium: titleLarge,
      headlineSmall: titleLarge,
      titleLarge: titleLarge,
      titleMedium: title,
      titleSmall: bodyStrong,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: bodyStrong,
      labelMedium: label,
      labelSmall: caption,
    ),
  );

  const FxTypography._();
}
