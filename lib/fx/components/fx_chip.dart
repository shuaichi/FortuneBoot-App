import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// FX 风格 Chip — 内建 a11y(Semantics + 44dp 触摸目标)+ ripple。
/// 用于：类型选择、单选/多选 chip 集合。
class FxChip extends StatelessWidget {
  const FxChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.enabled = true,
    this.multiSelect = false,
    this.tooltip,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBackgroundColor,
    this.unselectedTextColor,
    this.isAction = false,
    this.disabledOpacity = 0.4,
    this.padding,
    this.constraints,
    this.alignment,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;
  final bool multiSelect;
  final String? tooltip;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedBackgroundColor;
  final Color? unselectedTextColor;
  final bool isAction;
  final double disabledOpacity;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final effectiveSelectedColor = selectedColor ?? palette.primary;
    final effectiveUnselectedColor = unselectedColor ?? palette.surfaceMuted;
    final fg = selected
        ? effectiveSelectedColor
        : unselectedTextColor ?? palette.textSecondary;
    final bg = selected
        ? selectedBackgroundColor ?? palette.primaryContainer
        : effectiveUnselectedColor;
    final borderColor = selected ? effectiveSelectedColor : palette.border;
    final effectiveConstraints =
        constraints ?? const BoxConstraints(minWidth: 88, minHeight: 44);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: tooltip ?? label,
      inMutuallyExclusiveGroup: !isAction && !multiSelect,
      child: Tooltip(
        message: tooltip ?? label,
        child: Opacity(
          opacity: enabled ? 1 : disabledOpacity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: FxRadius.pillBorder,
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      onTap();
                    }
                  : null,
              child: Container(
                constraints: effectiveConstraints,
                alignment: alignment,
                padding:
                    padding ??
                    const EdgeInsets.symmetric(
                      horizontal: FxSpacing.md,
                      vertical: FxSpacing.sm,
                    ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: FxRadius.pillBorder,
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: fg),
                      const SizedBox(width: FxSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: FxTypography.label.copyWith(
                          color: fg,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
