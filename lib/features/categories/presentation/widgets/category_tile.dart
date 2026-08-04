import 'package:flutter/material.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
    final node = widget.node;
    final hasChildren = node.children.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.depth * FxSpacing.lg),
          child: Material(
            color: widget.depth == 0
                ? FxColors.surface
                : FxColors.surfaceMuted,
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
                          color: FxColors.textSecondary,
                        ),
                      )
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: FxSpacing.xs),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: node.enable
                            ? widget.typeTint
                            : FxColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: FxSpacing.sm),
                    Expanded(
                      child: Text(
                        node.categoryName ?? '未命名',
                        style: FxTypography.body.copyWith(
                          color: node.enable
                              ? FxColors.textPrimary
                              : FxColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.onAddChild != null && widget.depth == 0)
                      InkResponse(
                        radius: 18,
                        onTap: () => widget.onAddChild!(node),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: FxColors.textSecondary,
                        ),
                      ),
                    InkResponse(
                      radius: 18,
                      onTap: () => widget.onMenu(node),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: FxColors.textSecondary,
                      ),
                    ),
                  ],
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
