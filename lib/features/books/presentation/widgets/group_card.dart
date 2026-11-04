import 'package:flutter/material.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.capabilities,
    required this.isDefault,
    required this.isCurrent,
    required this.onTap,
    required this.onMenu,
  });

  final ManagedGroup group;
  final ManageCapabilities capabilities;
  final bool isDefault;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final accent = palette.textSecondary;
    return Opacity(
      opacity: group.enable ? 1 : 0.62,
      child: FxCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.folder_rounded, color: accent),
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: FxTypography.bodyStrong.copyWith(
                          color: palette.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FxSpacing.xs),
                      Text(
                        group.remark?.trim().isNotEmpty == true
                            ? group.remark!.trim()
                            : S.of(context).booksNoRemark,
                        style: FxTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _menuButton(context),
              ],
            ),
            const SizedBox(height: FxSpacing.md),
            Wrap(
              spacing: FxSpacing.xs,
              runSpacing: FxSpacing.xs,
              children: [
                FxTagChip(label: group.defaultCurrency ?? 'CNY'),
                FxTagChip(label: capabilities.role.label),
                if (isDefault)
                  FxTagChip(
                    label: S.of(context).booksDefaultGroupTag,
                    selected: true,
                  ),
                if (isCurrent)
                  FxTagChip(
                    label: S.of(context).booksCurrentUsingTag,
                    selected: true,
                  ),
                if (!group.enable)
                  FxTagChip(
                    label: S.of(context).booksDisabled,
                    dotColor: palette.warning,
                  ),
              ],
            ),
            const SizedBox(height: FxSpacing.sm),
            Text(
              group.defaultBookName?.trim().isNotEmpty == true
                  ? S.of(context).booksDefaultBook(group.defaultBookName!)
                  : S.of(context).booksNoDefaultBook,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    final tooltip = MaterialLocalizations.of(context).showMenuTooltip;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onMenu,
          radius: 24,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.more_horiz_rounded,
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
