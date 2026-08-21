import 'package:flutter/material.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 分类树节点。展开状态由所属 Bloc 驱动。
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.node,
    required this.typeTint,
    required this.expanded,
    required this.onTap,
    required this.onMenu,
    required this.onToggleExpand,
    required this.expandedFor,
    required this.matchCountFor,
    this.depth = 0,
    this.onAddChild,
    this.searchMatchCount = 0,
  });

  final FortuneCategoryVo node;
  final Color typeTint;
  final bool expanded;
  final int depth;
  final ValueChanged<FortuneCategoryVo> onTap;
  final ValueChanged<FortuneCategoryVo> onMenu;
  final ValueChanged<int> onToggleExpand;
  final bool Function(FortuneCategoryVo child) expandedFor;
  final int Function(FortuneCategoryVo child) matchCountFor;
  final ValueChanged<FortuneCategoryVo>? onAddChild;
  final int searchMatchCount;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hasChildren = node.children.isNotEmpty;
    final isRoot = depth == 0;
    final name = node.categoryName ?? S.of(context).categoriesUnnamed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * FxSpacing.lg),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isRoot ? palette.surface : palette.surfaceMuted,
              borderRadius: FxRadius.tileBorder,
              boxShadow: isRoot
                  ? [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: FxRadius.tileBorder,
              child: InkWell(
                borderRadius: FxRadius.tileBorder,
                onTap: () => onTap(node),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FxSpacing.md,
                    vertical: FxSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (hasChildren)
                        Semantics(
                          button: true,
                          expanded: expanded,
                          label: name,
                          child: FxIconButton(
                            icon: expanded
                                ? Icons.expand_more_rounded
                                : Icons.chevron_right_rounded,
                            tooltip: name,
                            color: palette.textSecondary,
                            onPressed: node.categoryId == null
                                ? null
                                : () => onToggleExpand(node.categoryId!),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                      if (searchMatchCount > 0) ...[
                        Semantics(
                          label: S
                              .of(context)
                              .manageSearchBranchResults(searchMatchCount),
                          child: Text(
                            '$searchMatchCount',
                            style: FxTypography.caption.copyWith(
                              color: palette.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: FxSpacing.xs),
                      ],
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: (node.enable ? typeTint : palette.textTertiary)
                              .withValues(alpha: 0.14),
                          borderRadius: FxRadius.tileBorder,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isRoot
                              ? Icons.folder_rounded
                              : Icons.label_outline_rounded,
                          size: 15,
                          color: node.enable ? typeTint : palette.textTertiary,
                        ),
                      ),
                      const SizedBox(width: FxSpacing.sm),
                      Expanded(
                        child: Text(
                          name,
                          style: FxTypography.body.copyWith(
                            color: node.enable
                                ? palette.textPrimary
                                : palette.textTertiary,
                            fontWeight: isRoot
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onAddChild != null && isRoot)
                        FxIconButton(
                          icon: Icons.add_rounded,
                          tooltip: S.of(context).categoriesAdd,
                          color: palette.textSecondary,
                          onPressed: () => onAddChild!(node),
                        ),
                      FxIconButton(
                        icon: Icons.more_horiz_rounded,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).showMenuTooltip,
                        color: palette.textSecondary,
                        onPressed: () => onMenu(node),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasChildren && expanded) ...[
          const SizedBox(height: FxSpacing.xs),
          for (final child in node.children) ...[
            CategoryTile(
              node: child,
              typeTint: typeTint,
              depth: depth + 1,
              expanded: expandedFor(child),
              onTap: onTap,
              onMenu: onMenu,
              onToggleExpand: onToggleExpand,
              expandedFor: expandedFor,
              matchCountFor: matchCountFor,
              searchMatchCount: matchCountFor(child),
            ),
            const SizedBox(height: FxSpacing.xs),
          ],
        ],
      ],
    );
  }
}
