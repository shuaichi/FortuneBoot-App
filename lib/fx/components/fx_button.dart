import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

enum FxButtonVariant { filled, tonal, text, critical }

/// 统一按钮：filled(主色) / tonal(容器色) / text / critical(红)。
class FxButton extends StatelessWidget {
  static const double _defaultHorizontalPadding = 20;
  static const double _textHorizontalPadding = 12;

  final String label;
  final VoidCallback? onPressed;
  final FxButtonVariant variant;
  final IconData? icon;
  final bool expand;

  /// 为 true 时在宽松约束下按内容宽度收缩；默认撑满可用宽度。
  final bool hugContent;
  final bool loading;

  /// 最小高度；文字放大或换行时允许按钮自然增高。
  final double height;

  /// 加载态文案；为空时只展示进度指示器。
  final String? loadingLabel;

  const FxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FxButtonVariant.filled,
    this.icon,
    this.expand = false,
    this.hugContent = false,
    this.loading = false,
    this.height = FxSpacing.controlHeight,
    this.loadingLabel,
  });

  const FxButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.hugContent = false,
    this.loading = false,
    this.height = FxSpacing.controlHeight,
    this.loadingLabel,
  }) : variant = FxButtonVariant.tonal;

  const FxButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.hugContent = false,
    this.loading = false,
    this.height = FxSpacing.controlHeight,
    this.loadingLabel,
  }) : variant = FxButtonVariant.text;

  const FxButton.critical({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.hugContent = false,
    this.loading = false,
    this.height = FxSpacing.controlHeight,
    this.loadingLabel,
  }) : variant = FxButtonVariant.critical;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final Color bg;
    final Color fg;
    switch (variant) {
      case FxButtonVariant.filled:
        bg = palette.primary;
        fg = palette.onPrimary;
      case FxButtonVariant.tonal:
        bg = palette.primaryContainer;
        fg = palette.primary;
      case FxButtonVariant.text:
        bg = Colors.transparent;
        fg = palette.primary;
      case FxButtonVariant.critical:
        bg = palette.danger;
        fg = palette.onDanger;
    }

    final disabled = onPressed == null || loading;

    final Widget child = loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              ),
              if (loadingLabel != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    loadingLabel!,
                    textAlign: TextAlign.center,
                    style: FxTypography.bodyStrong.copyWith(color: fg),
                  ),
                ),
              ],
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: FxTypography.bodyStrong.copyWith(color: fg),
                ),
              ),
            ],
          );

    // 文本按钮没有底色，收窄左右内边距，避免窄屏并排时把文案挤出可用宽度。
    final horizontalPadding = variant == FxButtonVariant.text
        ? _textHorizontalPadding
        : _defaultHorizontalPadding;
    final hug = hugContent && !expand;

    final button = Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: bg,
        borderRadius: FxRadius.tileBorder,
        child: InkWell(
          borderRadius: FxRadius.tileBorder,
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: FxSpacing.md,
              ),
              // 只按内容增高，不能吞掉 bottomNavigationBar 的剩余视口高度。
              child: Center(
                widthFactor: hug ? 1 : null,
                heightFactor: 1,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      liveRegion: loading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
