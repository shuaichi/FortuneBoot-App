import 'package:flutter/material.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 标签树节点。与分类树共用「展开箭头 + 名称 + ⋯」的单行结构。
///
/// 能力点、搜索计数、状态字等不再逐行堆叠，统一由编辑表单承载。
class TagTile extends StatelessWidget {
  const TagTile({
    super.key,
    required this.node,
    required this.expanded,
    required this.onTap,
    required this.onMenu,
    required this.onToggleExpand,
    required this.expandedFor,
    this.depth = 0,
  });

  final FortuneTagVo node;
  final bool expanded;
  final int depth;
  final ValueChanged<FortuneTagVo> onTap;
  final ValueChanged<FortuneTagVo> onMenu;
  final ValueChanged<int> onToggleExpand;
  final bool Function(FortuneTagVo child) expandedFor;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hasChildren = node.children.isNotEmpty;
    final isRoot = depth == 0;
    final name = node.tagName ?? S.of(context).tagsUnnamed;
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasChildren && node.tagId != null
            ? () => onToggleExpand(node.tagId!)
            : () => onTap(node),
        onLongPress: () => onMenu(node),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              0,
              FxSpacing.xs,
              0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 48,
                  child: hasChildren
                      ? Icon(
                          expanded
                              ? Icons.expand_more_rounded
                              : Icons.chevron_right_rounded,
                          size: 20,
                          color: palette.textTertiary,
                        )
                      : null,
                ),
                const SizedBox(width: FxSpacing.sm),
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
                FxIconButton(
                  icon: Icons.more_horiz_rounded,
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  color: palette.textTertiary,
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
                  TagTile(
                    node: child,
                    depth: depth + 1,
                    expanded: expandedFor(child),
                    onTap: onTap,
                    onMenu: onMenu,
                    onToggleExpand: onToggleExpand,
                    expandedFor: expandedFor,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
