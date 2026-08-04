import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';

/// 图表切片配色：饼图/柱图按索引循环取色，全部来自 fx 色板，杜绝硬编码。
abstract final class StatsPalette {
  static const List<Color> slices = <Color>[
    FxColors.primary,
    FxColors.income,
    FxColors.adjust,
    FxColors.transfer,
    FxColors.info,
    FxColors.expense,
    Color(0xFF14B8A6), // teal
    Color(0xFFEC4899), // pink
  ];

  static Color colorAt(int index) => slices[index % slices.length];

  const StatsPalette._();
}
