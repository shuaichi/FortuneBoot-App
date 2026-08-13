import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';

/// Shared chart palette for categorical slices and ranked bars.
abstract final class FxChartPalette {
  static const List<Color> categorical = <Color>[
    FxColors.primary,
    FxColors.income,
    FxColors.adjust,
    FxColors.transfer,
    FxColors.info,
    FxColors.expense,
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];

  static Color colorAt(int index) => categorical[index % categorical.length];

  const FxChartPalette._();
}
