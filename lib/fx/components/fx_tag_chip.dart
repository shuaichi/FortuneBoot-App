import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 标签胶囊，可选色点。
class FxTagChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const FxTagChip({
    super.key,
    required this.label,
    this.dotColor,
    this.selected = false,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? FxColors.primaryContainer : FxColors.surfaceMuted;
    final fg = selected ? FxColors.primary : FxColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: FxRadius.pillBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(label, style: FxTypography.caption.copyWith(color: fg)),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close_rounded, size: 13, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
