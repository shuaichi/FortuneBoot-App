import 'package:flutter/material.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
    final accent = _accentFor(group.groupId ?? group.name.hashCode);
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
                    color: accent.withValues(alpha: 0.16),
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
                        style: FxTypography.title.copyWith(
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FxSpacing.xs),
                      Text(
                        group.remark?.trim().isNotEmpty == true
                            ? group.remark!.trim()
                            : '暂无备注',
                        style: FxTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
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
                if (isDefault) const FxTagChip(label: '默认分组', selected: true),
                if (isCurrent) const FxTagChip(label: '当前使用', selected: true),
                if (!group.enable)
                  FxTagChip(label: '已停用', dotColor: palette.warning),
              ],
            ),
            const SizedBox(height: FxSpacing.sm),
            Text(
              group.defaultBookName?.trim().isNotEmpty == true
                  ? '默认账本：${group.defaultBookName}'
                  : '默认账本：未设置',
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    return InkResponse(
      onTap: onMenu,
      radius: 24,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          Icons.more_horiz_rounded,
          color: FxPalette.of(context).textSecondary,
        ),
      ),
    );
  }

  Color _accentFor(int seed) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFFEA580C),
      Color(0xFF16A34A),
      Color(0xFF0891B2),
      Color(0xFF4F46E5),
      Color(0xFFB45309),
    ];
    return colors[seed.abs() % colors.length];
  }
}
