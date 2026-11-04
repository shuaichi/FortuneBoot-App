import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 统一输入框：静态标签在框外，输入区只保留提示与错误，不使用浮动标签。
///
/// 认证、设置与编辑表单都应通过本组件接入 [FxTextField]，避免各页面自行
/// 拼装边框、填充色和焦点态。
class FxTextField extends StatelessWidget {
  const FxTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
    this.maxLength,
    this.showCounter = false,
    this.scrollPadding = const EdgeInsets.all(20),
    this.contentPadding,
  });

  /// 框外静态标签。
  final String label;

  /// 输入控制器。
  final TextEditingController? controller;

  /// 焦点节点。
  final FocusNode? focusNode;

  /// 空值提示。
  final String? hintText;

  /// 外部错误提示；表单校验错误由 [validator] 提供。
  final String? errorText;

  /// 辅助说明。
  final String? helperText;

  /// 前置图标。
  final Widget? prefixIcon;

  /// 后置图标。
  final Widget? suffixIcon;

  /// 键盘类型。
  final TextInputType? keyboardType;

  /// 键盘动作。
  final TextInputAction? textInputAction;

  /// 输入变化回调。
  final ValueChanged<String>? onChanged;

  /// 提交回调。
  final ValueChanged<String>? onSubmitted;

  /// 点击输入框外回调。
  final TapRegionCallback? onTapOutside;

  /// 是否密文。
  final bool obscureText;

  /// 是否可编辑。
  final bool enabled;

  /// 最大行数。
  final int maxLines;

  /// 自动填充提示。
  final Iterable<String>? autofillHints;

  /// 输入格式化。
  final List<TextInputFormatter>? inputFormatters;

  /// 表单校验器。
  final FormFieldValidator<String>? validator;

  /// 是否自动聚焦。
  final bool autofocus;

  /// 是否启用自动纠错。
  final bool autocorrect;

  /// 是否启用输入建议。
  final bool enableSuggestions;

  /// 大小写策略。
  final TextCapitalization textCapitalization;

  /// 文本对齐。
  final TextAlign textAlign;

  /// 输入文字样式；为空时使用正文样式。
  final TextStyle? style;

  /// 最大字符数。
  final int? maxLength;

  /// 是否展示字符计数器。
  final bool showCounter;

  /// 键盘弹起时为输入框预留的滚动空间。
  final EdgeInsets scrollPadding;

  /// 输入区内边距。
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      maxLength: maxLength,
      scrollPadding: scrollPadding,
      style: style ?? FxTypography.body.copyWith(color: palette.textPrimary),
      cursorColor: palette.primary,
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: enabled
            ? palette.surfaceMuted
            : palette.surfaceMuted.withValues(alpha: 0.55),
        isDense: false,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        counterText: showCounter ? null : '',
        helperMaxLines: 2,
        errorMaxLines: 3,
        hintStyle: FxTypography.body.copyWith(color: palette.textTertiary),
        helperStyle: FxTypography.caption.copyWith(
          color: palette.textSecondary,
        ),
        errorStyle: FxTypography.caption.copyWith(color: palette.danger),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.border.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.danger, width: 1.5),
        ),
      ),
    );

    if (label.trim().isEmpty) {
      return field;
    }

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: FxTypography.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }
}
