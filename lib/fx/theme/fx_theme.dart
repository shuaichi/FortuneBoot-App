import 'package:flutter/material.dart';
import 'package:fortuneboot/core/preferences/finance_color_preferences.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
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

  /// 模态遮罩，独立于投影透明度。
  final Color scrim;

  /// 危险操作实色背景上的前景。
  final Color onDanger;

  /// 输入框等控件边界，与装饰边框分开。
  final Color borderStrong;

  /// 装饰性分隔线，不承担控件识别。
  final Color separator;

  /// 模态、菜单等浮层表面。
  final Color surfaceRaised;

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
    this.scrim = const Color(0x66000000),
    this.onDanger = const Color(0xFFFFFFFF),
    this.borderStrong = const Color(0xFF84848D),
    this.separator = const Color(0xFFEAEAED),
    this.surfaceRaised = const Color(0xFFFFFFFF),
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
    primary: Color(0xFF70A7FF),
    primaryContainer: Color(0xFF192C49),
    onPrimary: Color(0xFF121215),
    canvas: Color(0xFF101012),
    surface: Color(0xFF18181B),
    surfaceMuted: Color(0xFF202024),
    border: Color(0xFF34343B),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFBCBCC5),
    textTertiary: Color(0xFFA0A0AB),
    success: Color(0xFF6FD59B),
    warning: Color(0xFFEFC477),
    danger: Color(0xFFFF8C88),
    info: Color(0xFF7BCEEF),
    shadow: Color(0x66000000),
    scrim: Color(0x99000000),
    onDanger: Color(0xFF121215),
    borderStrong: Color(0xFF777780),
    separator: Color(0xFF2B2B31),
    surfaceRaised: Color(0xFF28282D),
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
    Color? scrim,
    Color? onDanger,
    Color? borderStrong,
    Color? separator,
    Color? surfaceRaised,
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
      scrim: scrim ?? this.scrim,
      onDanger: onDanger ?? this.onDanger,
      borderStrong: borderStrong ?? this.borderStrong,
      separator: separator ?? this.separator,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
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
      scrim: Color.lerp(scrim, other.scrim, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
    );
  }
}

/// 业务语义色 ThemeExtension：收入/支出/转账/调整/垫付/报销/节假日/休/班。
/// 通过 `Theme.of(context).extension<FxFinanceColors>()!` 或 `FxFinanceColors.of(context)` 取。
@immutable
class FxFinanceColors extends ThemeExtension<FxFinanceColors> {
  final Color income;
  final Color expense;
  final Color transfer;
  final Color adjust;
  final Color advance;
  final Color reimburse;
  final Color loanOut;
  final Color loanRecover;
  final Color loanIn;
  final Color loanRepay;
  final Color holiday;
  final Color rest;
  final Color work;

  const FxFinanceColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.adjust,
    required this.advance,
    required this.reimburse,
    required this.loanOut,
    required this.loanRecover,
    required this.loanIn,
    required this.loanRepay,
    required this.holiday,
    required this.rest,
    required this.work,
  });

  static const FxFinanceColors light = FxFinanceColors(
    income: FxColors.income,
    expense: FxColors.expense,
    transfer: FxColors.transfer,
    adjust: FxColors.adjust,
    advance: FxColors.expense,
    reimburse: FxColors.income,
    loanOut: FxColors.expense,
    loanRecover: FxColors.income,
    loanIn: FxColors.income,
    loanRepay: FxColors.expense,
    holiday: Color(0xFF7C3AED),
    rest: FxColors.expense,
    work: FxColors.adjust,
  );

  factory FxFinanceColors.fromPreferences(FinanceColorPreferences prefs) {
    return FxFinanceColors(
      income: prefs.incomeColor,
      expense: prefs.expenseColor,
      transfer: prefs.transferColor,
      adjust: prefs.adjustColor,
      advance: prefs.advanceColor,
      reimburse: prefs.reimburseColor,
      loanOut: prefs.expenseColor,
      loanRecover: prefs.incomeColor,
      loanIn: prefs.incomeColor,
      loanRepay: prefs.expenseColor,
      holiday: prefs.holidayColor,
      rest: prefs.restColor,
      work: prefs.workColor,
    );
  }

  static FxFinanceColors of(BuildContext context) =>
      Theme.of(context).extension<FxFinanceColors>() ?? light;

  /// 按账单类型取语义色。billType: 1支出 2收入 3转账 4调整 7—12单据流水。
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
        // 报销到账增加当前账户余额，与垫付支出方向相反。
        return income;
      case 9:
        return loanOut;
      case 10:
        return loanRecover;
      case 11:
        return loanIn;
      case 12:
        return loanRepay;
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
    Color? loanOut,
    Color? loanRecover,
    Color? loanIn,
    Color? loanRepay,
    Color? holiday,
    Color? rest,
    Color? work,
  }) {
    return FxFinanceColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      adjust: adjust ?? this.adjust,
      advance: advance ?? this.advance,
      reimburse: reimburse ?? this.reimburse,
      loanOut: loanOut ?? this.loanOut,
      loanRecover: loanRecover ?? this.loanRecover,
      loanIn: loanIn ?? this.loanIn,
      loanRepay: loanRepay ?? this.loanRepay,
      holiday: holiday ?? this.holiday,
      rest: rest ?? this.rest,
      work: work ?? this.work,
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
      loanOut: Color.lerp(loanOut, other.loanOut, t)!,
      loanRecover: Color.lerp(loanRecover, other.loanRecover, t)!,
      loanIn: Color.lerp(loanIn, other.loanIn, t)!,
      loanRepay: Color.lerp(loanRepay, other.loanRepay, t)!,
      holiday: Color.lerp(holiday, other.holiday, t)!,
      rest: Color.lerp(rest, other.rest, t)!,
      work: Color.lerp(work, other.work, t)!,
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
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.surfaceMuted,
      onSecondaryContainer: palette.textPrimary,
      tertiary: palette.primary,
      onTertiary: palette.onPrimary,
      tertiaryContainer: palette.surfaceMuted,
      onTertiaryContainer: palette.textPrimary,
      error: palette.danger,
      onError: palette.onDanger,
      errorContainer: palette.danger.withValues(alpha: 0.16),
      onErrorContainer: palette.textPrimary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerLowest: palette.canvas,
      surfaceContainerLow: palette.surface,
      surfaceContainer: palette.surface,
      surfaceContainerHigh: palette.surfaceRaised,
      surfaceContainerHighest: palette.surfaceMuted,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.borderStrong,
      outlineVariant: palette.border,
      shadow: palette.shadow,
      scrim: palette.scrim,
      inverseSurface: palette.textPrimary,
      onInverseSurface: palette.surface,
      inversePrimary: palette.primary,
      surfaceTint: Colors.transparent,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      primaryColor: palette.primary,
      dividerColor: palette.separator,
      dividerTheme: DividerThemeData(
        color: palette.separator,
        thickness: FxSpacing.hairline,
        space: FxSpacing.borderWidth,
      ),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      iconTheme: IconThemeData(color: palette.textSecondary, size: 22),
      focusColor: palette.primary.withValues(alpha: 0.12),
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
      textTheme: FxTypography.textTheme(base.textTheme).apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceRaised,
        modalBackgroundColor: palette.surfaceRaised,
        modalBarrierColor: palette.scrim,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: false,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: FxRadius.cardBorder,
          side: BorderSide(color: palette.border, width: FxSpacing.hairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(FxRadius.sheetRadius),
        ),
        titleTextStyle: FxTypography.titleLarge.copyWith(
          color: palette.textPrimary,
        ),
        contentTextStyle: FxTypography.body.copyWith(
          color: palette.textPrimary,
        ),
      ),
      // 全局仅定义文本角色；几何/填充由 FxTextField 管理，保留旧的
      // border: InputBorder.none 金额输入和搜索框的显式无边框契约。
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: FxTypography.body.copyWith(color: palette.textTertiary),
        labelStyle: FxTypography.label.copyWith(color: palette.textSecondary),
        helperStyle: FxTypography.caption.copyWith(
          color: palette.textSecondary,
        ),
        errorStyle: FxTypography.caption.copyWith(color: palette.danger),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: FxTypography.body.copyWith(color: palette.textPrimary),
        subtitleTextStyle: FxTypography.caption.copyWith(
          color: palette.textSecondary,
        ),
        iconColor: palette.textSecondary,
        minTileHeight: FxSpacing.rowHeight,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primary,
        selectionColor: palette.primary.withValues(alpha: 0.20),
        selectionHandleColor: palette.primary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          textStyle: FxTypography.bodyStrong,
          minimumSize: const Size(
            FxSpacing.controlHeight,
            FxSpacing.controlHeight,
          ),
          padding: FxSpacing.fieldPad,
          shape: RoundedRectangleBorder(borderRadius: FxRadius.tileBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: FxTypography.label,
          minimumSize: const Size(FxSpacing.touchTarget, FxSpacing.touchTarget),
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
