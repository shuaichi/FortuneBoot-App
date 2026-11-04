import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
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

  /// 主次操作统一使用 48dp 高度；认证等单列页面可显式提升到 50dp。
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
    this.height = 48,
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
    this.height = 48,
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
    this.height = 48,
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
    this.height = 48,
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
        fg = Colors.white;
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          child: Container(
            height: height,
            alignment: hug ? null : Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
