import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 通用行：左图标、完整标题/副标题、右值或箭头，大字时上下重排。
class FxListItem extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final int subtitleMaxLines;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const FxListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.subtitleMaxLines = 3,
    this.subtitleStyle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FxTypography.bodyStrong.copyWith(color: palette.textPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style:
                subtitleStyle ??
                FxTypography.caption.copyWith(color: palette.textSecondary),
            maxLines: subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
    final chevron = showChevron
        ? Icon(Icons.chevron_right_rounded, color: palette.textTertiary)
        : null;

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final reflow =
              constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          if (reflow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: FxSpacing.md),
                    ],
                    Expanded(child: textContent),
                    if (chevron != null) ...[
                      const SizedBox(width: FxSpacing.sm),
                      chevron,
                    ],
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(height: FxSpacing.sm),
                  Align(alignment: Alignment.centerRight, child: trailing),
                ],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: FxSpacing.md),
              ],
              Expanded(child: textContent),
              if (trailing != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              if (chevron != null) ...[
                const SizedBox(width: FxSpacing.sm),
                chevron,
              ],
            ],
          );
        },
      ),
    );

    if (onTap == null) return row;
    return Semantics(
      button: true,
      enabled: true,
      label: subtitle == null ? title : '$title, $subtitle',
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: row,
        ),
      ),
    );
  }
}
