import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';

/// Shared chart palette for categorical slices and ranked bars.
abstract final class FxChartPalette {
  static const List<Color> categorical = <Color>[
    FxColors.primary,
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
    Color(0xFF6366F1),
    Color(0xFFF97316),
  ];

  static const List<Color> darkCategorical = <Color>[
    Color(0xFF70A7FF),
    Color(0xFFB79CFF),
    Color(0xFF5BD4E8),
    Color(0xFFEFC477),
    Color(0xFF5EDBC8),
    Color(0xFFFF8FC5),
    Color(0xFFA5A8FF),
    Color(0xFFFFB27A),
  ];

  static Color colorAt(int index, {Brightness brightness = Brightness.light}) {
    final colors = brightness == Brightness.dark
        ? darkCategorical
        : categorical;
    return colors[index % colors.length];
  }

  const FxChartPalette._();
}
