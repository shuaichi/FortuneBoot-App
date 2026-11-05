import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 静态标签或可操作标签；只有存在回调时才暴露按钮语义。
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
    final palette = FxPalette.of(context);
    final bg = selected ? palette.primaryContainer : palette.surfaceMuted;
    final fg = selected ? palette.primary : palette.textSecondary;
    final actionable = onTap != null;
    final content = Row(
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
        Flexible(
          child: Text(label, style: FxTypography.caption.copyWith(color: fg)),
        ),
        if (onDeleted != null) ...[
          const SizedBox(width: FxSpacing.xs),
          Semantics(
            container: true,
            button: true,
            label: '${S.of(context).fxDeleteLabel} $label',
            child: InkResponse(
              onTap: onDeleted,
              radius: 24,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close_rounded, size: 18, color: fg),
              ),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: actionable,
      selected: actionable ? selected : null,
      enabled: actionable ? true : null,
      label: label,
      child: Material(
        color: bg,
        borderRadius: FxRadius.pillBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: actionable || onDeleted != null ? 44 : 0,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: FxSpacing.md,
                right: onDeleted == null ? FxSpacing.md : 0,
                top: actionable ? FxSpacing.sm : 5,
                bottom: actionable ? FxSpacing.sm : 5,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
