import 'package:flutter/widgets.dart';

/// 4pt 基础网格与移动端语义间距；基础数值保留现有调用兼容性。
///
/// @author JoyCode
/// @since 2026/11/05
abstract final class FxSpacing {
  /// 紧邻图标、数值与标签。
  static const double xs = 4;

  /// 同一信息组内的小间距。
  static const double sm = 8;

  /// 行内元素、相邻紧凑内容。
  static const double md = 12;

  /// 常规内容内边距。
  static const double lg = 16;

  /// 页面左右留白。
  static const double xl = 20;

  /// 相邻区块的最小间隔。
  static const double xxl = 24;

  /// 不同任务区块的间隔。
  static const double xxxl = 32;

  /// 常规页面边距；紧凑列表可显式使用 [lg]。
  static const double pageInset = xl;

  /// 分组间距不复用行内间距。
  static const double sectionGap = xxl;

  /// 标签到字段、字段到辅助说明的间距。
  static const double fieldGap = sm;

  /// 同一表单的相邻字段间距。
  static const double formGap = xl;

  /// 本工程移动触控的舒适下限。
  static const double touchTarget = 44;

  /// 常用按钮和工具栏图标的最小尺寸。
  static const double controlHeight = 48;

  /// 列表行最小高度；多行文字仍须允许继续增高。
  static const double rowHeight = 52;

  /// 装饰性分割线使用逻辑像素宽度，不代替控件边界。
  static const double hairline = 0.5;

  /// 可交互控件边界。
  static const double borderWidth = 1;

  /// 焦点环宽度。
  static const double focusWidth = 2;

  /// 页面水平留白。
  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: pageInset);

  /// 独立卡片内容内边距。
  static const EdgeInsets cardPad = EdgeInsets.all(lg);

  /// 输入框内边距。
  static const EdgeInsets fieldPad = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  const FxSpacing._();
}
