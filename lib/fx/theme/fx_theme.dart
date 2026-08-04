import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 业务语义色 ThemeExtension：收入/支出/转账/调整。
/// 通过 `Theme.of(context).extension<FxFinanceColors>()!` 或 `FxFinanceColors.of(context)` 取。
@immutable
class FxFinanceColors extends ThemeExtension<FxFinanceColors> {
  final Color income;
  final Color expense;
  final Color transfer;
  final Color adjust;

  const FxFinanceColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.adjust,
  });

  static const FxFinanceColors light = FxFinanceColors(
    income: FxColors.income,
    expense: FxColors.expense,
    transfer: FxColors.transfer,
    adjust: FxColors.adjust,
  );

  static FxFinanceColors of(BuildContext context) =>
      Theme.of(context).extension<FxFinanceColors>() ?? light;

  /// 按账单类型取语义色。billType: 1支出 2收入 3转账 4调整 7垫付 8报销。
  Color forBillType(int? billType) {
    switch (billType) {
      case 2:
        return income;
      case 3:
        return transfer;
      case 4:
        return adjust;
      case 7: // 垫付
      case 8: // 报销
      case 1: // 支出
      default:
        return expense;
    }
  }

  @override
  FxFinanceColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? adjust,
  }) {
    return FxFinanceColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      adjust: adjust ?? this.adjust,
    );
  }

  @override
  FxFinanceColors lerp(ThemeExtension<FxFinanceColors>? other, double t) {
    if (other is! FxFinanceColors) return this;
    return FxFinanceColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      adjust: Color.lerp(adjust, other.adjust, t)!,
    );
  }
}

/// 新设计系统主题。
abstract final class FxTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FxColors.primary,
      primary: FxColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      surface: FxColors.surface,
      onSurface: FxColors.textPrimary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FxColors.canvas,
      canvasColor: FxColors.canvas,
      primaryColor: FxColors.primary,
      dividerColor: FxColors.border,
      splashColor: FxColors.primary.withValues(alpha: 0.08),
      highlightColor: FxColors.primary.withValues(alpha: 0.04),
      appBarTheme: const AppBarTheme(
        backgroundColor: FxColors.canvas,
        foregroundColor: FxColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: FxTypography.title,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: FxColors.textPrimary,
        displayColor: FxColors.textPrimary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FxColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FxColors.textPrimary,
        contentTextStyle: FxTypography.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: FxRadius.tileBorder),
      ),
      extensions: const [FxFinanceColors.light],
    );
  }
}
