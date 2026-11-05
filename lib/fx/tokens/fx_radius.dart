import 'package:flutter/widgets.dart';

/// 控件 12、容器 16、模态表面 24；胶囊仅用于短状态或筛选项。
abstract final class FxRadius {
  static const double tile = 12;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static const Radius cardRadius = Radius.circular(card);
  static const Radius sheetRadius = Radius.circular(sheet);

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get tileBorder => BorderRadius.circular(tile);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);

  const FxRadius._();
}

/// 动效时长与曲线。
abstract final class FxMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 250);

  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

  static const Curve easeOut = Cubic(0.16, 1, 0.3, 1);
  static const Curve standard = Curves.easeOutCubic;

  const FxMotion._();
}
