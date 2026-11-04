import 'package:flutter/material.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
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
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasChildren && node.categoryId != null
            ? () => onToggleExpand(node.categoryId!)
            : () => onTap(node),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 48,
                  child: hasChildren
                      ? Icon(
                          expanded
                              ? Icons.expand_more_rounded
                              : Icons.chevron_right_rounded,
                          size: 22,
                          color: palette.textSecondary,
                        )
                      : null,
                ),
                Expanded(
                  child: Text(
                    name,
                    style: FxTypography.body.copyWith(
                      color: node.enable
                          ? palette.textPrimary
                          : palette.textTertiary,
                      fontWeight: isRoot ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (searchMatchCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: FxSpacing.sm),
                    child: Semantics(
                      label: S
                          .of(context)
                          .manageSearchBranchResults(searchMatchCount),
                      child: Text(
                        '$searchMatchCount',
                        style: FxTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
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
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  color: palette.textSecondary,
                  onPressed: () => onMenu(node),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (hasChildren && expanded)
          Padding(
            padding: const EdgeInsets.only(left: FxSpacing.lg),
            child: Column(
              children: [
                for (final child in node.children)
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
              ],
            ),
          ),
      ],
    );
  }
}
