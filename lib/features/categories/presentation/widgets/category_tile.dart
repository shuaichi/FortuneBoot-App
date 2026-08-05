import 'package:flutter/material.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 分类树节点（自绘 accordion：有子节点可展开/收起）。
class CategoryTile extends StatefulWidget {
  final FortuneCategoryVo node;
  final Color typeTint;
  final int depth;
  final void Function(FortuneCategoryVo) onTap;
  final void Function(FortuneCategoryVo) onMenu;
  final void Function(FortuneCategoryVo, bool)? onEnableToggle;
  final void Function(FortuneCategoryVo parent)? onAddChild;

  const CategoryTile({
    super.key,
    required this.node,
    required this.typeTint,
    required this.onTap,
    required this.onMenu,
    this.depth = 0,
    this.onEnableToggle,
    this.onAddChild,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final node = widget.node;
    final hasChildren = node.children.isNotEmpty;
    final isRoot = widget.depth == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.depth * FxSpacing.lg),
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
                onTap: () => widget.onTap(node),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FxSpacing.md,
                    vertical: FxSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (hasChildren)
                        InkResponse(
                          radius: 18,
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Icon(
                            _expanded
                                ? Icons.expand_more_rounded
                                : Icons.chevron_right_rounded,
                            size: 20,
                            color: palette.textSecondary,
                          ),
                        )
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: FxSpacing.xs),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color:
                              (node.enable
                                      ? widget.typeTint
                                      : palette.textTertiary)
                                  .withValues(alpha: 0.14),
                          borderRadius: FxRadius.tileBorder,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isRoot
                              ? Icons.folder_rounded
                              : Icons.label_outline_rounded,
                          size: 15,
                          color: node.enable
                              ? widget.typeTint
                              : palette.textTertiary,
                        ),
                      ),
                      const SizedBox(width: FxSpacing.sm),
                      Expanded(
                        child: Text(
                          node.categoryName ?? S.of(context).categoriesUnnamed,
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
                      if (widget.onAddChild != null && widget.depth == 0)
                        InkResponse(
                          radius: 18,
                          onTap: () => widget.onAddChild!(node),
                          child: Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: palette.textSecondary,
                          ),
                        ),
                      InkResponse(
                        radius: 18,
                        onTap: () => widget.onMenu(node),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasChildren && _expanded) ...[
          const SizedBox(height: FxSpacing.xs),
          for (final child in node.children) ...[
            CategoryTile(
              node: child,
              typeTint: widget.typeTint,
              depth: widget.depth + 1,
              onTap: widget.onTap,
              onMenu: widget.onMenu,
              onEnableToggle: widget.onEnableToggle,
            ),
            const SizedBox(height: FxSpacing.xs),
          ],
        ],
      ],
    );
  }
}
