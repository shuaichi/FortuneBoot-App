import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_chart_palette.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// Stats-only chart color resolver.
///
/// Financial series use semantic finance colors. Free-form category/tag/account
/// labels use a deterministic hash so the same label keeps the same color when
/// ranking order changes.
abstract final class StatsPalette {
  static Color income(BuildContext context) =>
      FxFinanceColors.of(context).income;

  static Color expense(BuildContext context) =>
      FxFinanceColors.of(context).expense;

  static Color transfer(BuildContext context) =>
      FxFinanceColors.of(context).transfer;

  static Color adjust(BuildContext context) =>
      FxFinanceColors.of(context).adjust;

  static Color stableFor(String key, {int? id}) {
    final seed = id?.hashCode ?? key.trim().toLowerCase().hashCode;
    return FxChartPalette.colorAt(seed.abs());
  }

  static Color liabilityVariant(BuildContext context, String key, {int? id}) {
    final base = expense(context);
    final alpha = 0.58 + (stableFor(key, id: id).hashCode.abs() % 4) * 0.1;
    return base.withValues(alpha: alpha.clamp(0.58, 0.88));
  }

  const StatsPalette._();
}
