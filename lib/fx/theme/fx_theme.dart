import 'package:flutter/material.dart';
import 'package:fortuneboot/core/preferences/finance_color_preferences.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 中性 / 表面色 ThemeExtension：承载亮暗两套背景、文字、边框。
///
/// 业务页面应优先通过 `FxPalette.of(context)` 取色，逐步替代静态 [FxColors]，
/// 从而在暗色模式下自动适配。[FxColors] 静态常量保留为亮色默认与迁移兜底。
@immutable
class FxPalette extends ThemeExtension<FxPalette> {
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color shadow;

  const FxPalette({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.shadow,
  });

  static const FxPalette light = FxPalette(
    primary: FxColors.primary,
    primaryContainer: FxColors.primaryContainer,
    onPrimary: FxColors.onPrimary,
    canvas: FxColors.canvas,
    surface: FxColors.surface,
    surfaceMuted: FxColors.surfaceMuted,
    border: FxColors.border,
    textPrimary: FxColors.textPrimary,
    textSecondary: FxColors.textSecondary,
    textTertiary: FxColors.textTertiary,
    success: FxColors.success,
    warning: FxColors.warning,
    danger: FxColors.danger,
    info: FxColors.info,
    shadow: FxColors.shadow,
  );

  static const FxPalette dark = FxPalette(
    primary: Color(0xFF4D94FF),
    primaryContainer: Color(0xFF13294D),
    onPrimary: Color(0xFFFFFFFF),
    canvas: Color(0xFF0B0F17),
    surface: Color(0xFF161B24),
    surfaceMuted: Color(0xFF1F2630),
    border: Color(0xFF2A323D),
    textPrimary: Color(0xFFF2F4F7),
    textSecondary: Color(0xFFA6AEBB),
    textTertiary: Color(0xFF6F7885),
    success: Color(0xFF34D07A),
    warning: Color(0xFFFBBF4D),
    danger: Color(0xFFF87171),
    info: Color(0xFF38BDF8),
    shadow: Color(0x66000000),
  );

  static FxPalette of(BuildContext context) =>
      Theme.of(context).extension<FxPalette>() ?? light;

  @override
  FxPalette copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? onPrimary,
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? shadow,
  }) {
    return FxPalette(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  FxPalette lerp(ThemeExtension<FxPalette>? other, double t) {
    if (other is! FxPalette) return this;
    return FxPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// 业务语义色 ThemeExtension：收入/支出/转账/调整/垫付/报销。
/// 通过 `Theme.of(context).extension<FxFinanceColors>()!` 或 `FxFinanceColors.of(context)` 取。
@immutable
class FxFinanceColors extends ThemeExtension<FxFinanceColors> {
  final Color income;
  final Color expense;
  final Color transfer;
  final Color adjust;
  final Color advance;
  final Color reimburse;

  const FxFinanceColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.adjust,
    required this.advance,
    required this.reimburse,
  });

  static const FxFinanceColors light = FxFinanceColors(
    income: FxColors.income,
    expense: FxColors.expense,
    transfer: FxColors.transfer,
    adjust: FxColors.adjust,
    advance: FxColors.expense,
    reimburse: FxColors.expense,
  );

  factory FxFinanceColors.fromPreferences(FinanceColorPreferences prefs) {
    return FxFinanceColors(
      income: prefs.incomeColor,
      expense: prefs.expenseColor,
      transfer: prefs.transferColor,
      adjust: prefs.adjustColor,
      advance: prefs.advanceColor,
      reimburse: prefs.reimburseColor,
    );
  }

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
      case 7:
        return advance;
      case 8:
        return reimburse;
      case 1:
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
    Color? advance,
    Color? reimburse,
  }) {
    return FxFinanceColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      adjust: adjust ?? this.adjust,
      advance: advance ?? this.advance,
      reimburse: reimburse ?? this.reimburse,
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
      advance: Color.lerp(advance, other.advance, t)!,
      reimburse: Color.lerp(reimburse, other.reimburse, t)!,
    );
  }
}

/// 新设计系统主题。
abstract final class FxTheme {
  static ThemeData get light => buildLight();

  static ThemeData get dark => buildDark();

  /// 亮色主题。可注入自定义业务语义色。
  static ThemeData buildLight({FxFinanceColors? financeColors}) {
    return _build(
      brightness: Brightness.light,
      palette: FxPalette.light,
      financeColors: financeColors ?? FxFinanceColors.light,
    );
  }

  /// 暗色主题。可注入自定义业务语义色。
  static ThemeData buildDark({FxFinanceColors? financeColors}) {
    return _build(
      brightness: Brightness.dark,
      palette: FxPalette.dark,
      financeColors: financeColors ?? FxFinanceColors.light,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required FxPalette palette,
    required FxFinanceColors financeColors,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.textPrimary,
      secondary: palette.info,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.surfaceMuted,
      onSecondaryContainer: palette.textPrimary,
      tertiary: palette.warning,
      onTertiary: palette.canvas,
      tertiaryContainer: palette.surfaceMuted,
      onTertiaryContainer: palette.textPrimary,
      error: palette.danger,
      onError: palette.onPrimary,
      errorContainer: palette.danger.withValues(alpha: 0.16),
      onErrorContainer: palette.textPrimary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.surfaceMuted,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.border,
      outlineVariant: palette.border,
      shadow: palette.shadow,
      scrim: palette.shadow,
      inverseSurface: palette.textPrimary,
      onInverseSurface: palette.surface,
      inversePrimary: palette.primary,
      surfaceTint: palette.primary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      primaryColor: palette.primary,
      dividerColor: palette.border,
      splashColor: palette.primary.withValues(alpha: 0.08),
      highlightColor: palette.primary.withValues(alpha: 0.04),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: FxTypography.title.copyWith(color: palette.textPrimary),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: FxTypography.body.copyWith(color: palette.surface),
        shape: RoundedRectangleBorder(borderRadius: FxRadius.tileBorder),
      ),
      extensions: [palette, financeColors],
    );
  }
}
