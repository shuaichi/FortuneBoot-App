import 'package:flutter/widgets.dart';

/// 8pt 间距体系。
abstract final class FxSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPad = EdgeInsets.all(lg);

  const FxSpacing._();
}
