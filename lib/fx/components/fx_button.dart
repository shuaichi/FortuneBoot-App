import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

enum FxButtonVariant { filled, tonal, text, critical }

/// 统一按钮：filled(主色) / tonal(容器色) / text / critical(红)。
class FxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final FxButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool loading;

  const FxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FxButtonVariant.filled,
    this.icon,
    this.expand = false,
    this.loading = false,
  });

  const FxButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
  }) : variant = FxButtonVariant.tonal;

  const FxButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
  }) : variant = FxButtonVariant.text;

  const FxButton.critical({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.loading = false,
  }) : variant = FxButtonVariant.critical;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (variant) {
      case FxButtonVariant.filled:
        bg = FxColors.primary;
        fg = FxColors.onPrimary;
      case FxButtonVariant.tonal:
        bg = FxColors.primaryContainer;
        fg = FxColors.primary;
      case FxButtonVariant.text:
        bg = Colors.transparent;
        fg = FxColors.primary;
      case FxButtonVariant.critical:
        bg = FxColors.danger;
        fg = Colors.white;
    }

    final disabled = onPressed == null || loading;

    Widget child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: FxTypography.bodyStrong.copyWith(color: fg),
              ),
            ],
          );

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
            height: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
