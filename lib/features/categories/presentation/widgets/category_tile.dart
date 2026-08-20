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
  final bool? initiallyExpanded;
  final bool forceExpanded;

  const CategoryTile({
    super.key,
    required this.node,
    required this.typeTint,
    required this.onTap,
    required this.onMenu,
    this.depth = 0,
    this.onEnableToggle,
    this.onAddChild,
    this.initiallyExpanded,
    this.forceExpanded = false,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  late bool _expanded = widget.initiallyExpanded ?? widget.depth == 0;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final node = widget.node;
    final hasChildren = node.children.isNotEmpty;
    final expanded = widget.forceExpanded || _expanded;
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
                        Semantics(
                          button: true,
                          expanded: expanded,
                          label:
                              node.categoryName ??
                              S.of(context).categoriesUnnamed,
                          child: Tooltip(
                            message:
                                node.categoryName ??
                                S.of(context).categoriesUnnamed,
                            child: InkResponse(
                              radius: 24,
                              onTap: widget.forceExpanded
                                  ? null
                                  : () =>
                                        setState(() => _expanded = !_expanded),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Icon(
                                  expanded
                                      ? Icons.expand_more_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 20,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
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
                        Semantics(
                          button: true,
                          label: S.of(context).categoriesAdd,
                          child: Tooltip(
                            message: S.of(context).categoriesAdd,
                            child: InkResponse(
                              radius: 24,
                              onTap: () => widget.onAddChild!(node),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 20,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Semantics(
                        button: true,
                        label: MaterialLocalizations.of(
                          context,
                        ).showMenuTooltip,
                        child: Tooltip(
                          message: MaterialLocalizations.of(
                            context,
                          ).showMenuTooltip,
                          child: InkResponse(
                            radius: 24,
                            onTap: () => widget.onMenu(node),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: 20,
                                color: palette.textSecondary,
                              ),
                            ),
                          ),
                        ),
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
              typeTint: widget.typeTint,
              depth: widget.depth + 1,
              onTap: widget.onTap,
              onMenu: widget.onMenu,
              onEnableToggle: widget.onEnableToggle,
              forceExpanded: widget.forceExpanded,
            ),
            const SizedBox(height: FxSpacing.xs),
          ],
        ],
      ],
    );
  }
}
