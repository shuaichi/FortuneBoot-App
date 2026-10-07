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

  static Color colorAt(int index) => categorical[index % categorical.length];

  const FxChartPalette._();
}
