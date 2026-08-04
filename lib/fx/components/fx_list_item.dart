import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 通用行：左图标 + 标题 + 副标题 + 右值/箭头。
class FxListItem extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const FxListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.md,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: FxSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: FxTypography.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: FxTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showChevron) ...[
            const SizedBox(width: FxSpacing.sm),
            const Icon(Icons.chevron_right_rounded, color: FxColors.textTertiary),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      borderRadius: FxRadius.tileBorder,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: row,
    );
  }
}
