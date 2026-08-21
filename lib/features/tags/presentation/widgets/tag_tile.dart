import 'package:flutter/material.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 标签树节点。展开状态由所属 Bloc 驱动。
class TagTile extends StatelessWidget {
  const TagTile({
    super.key,
    required this.node,
    required this.expanded,
    required this.onTap,
    required this.onMenu,
    required this.onToggleExpand,
    required this.expandedFor,
    required this.matchCountFor,
    this.depth = 0,
    this.searchMatchCount = 0,
  });

  final FortuneTagVo node;
  final bool expanded;
  final int depth;
  final ValueChanged<FortuneTagVo> onTap;
  final ValueChanged<FortuneTagVo> onMenu;
  final ValueChanged<int> onToggleExpand;
  final bool Function(FortuneTagVo child) expandedFor;
  final int Function(FortuneTagVo child) matchCountFor;
  final int searchMatchCount;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final hasChildren = node.children.isNotEmpty;
    final isRoot = depth == 0;
    final tint = node.enable ? finance.transfer : palette.textTertiary;
    final name = node.tagName ?? S.of(context).tagsUnnamed;
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
                            onPressed: node.tagId == null
                                ? null
                                : () => onToggleExpand(node.tagId!),
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
                          color: tint.withValues(alpha: 0.14),
                          borderRadius: FxRadius.tileBorder,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.tag_rounded, size: 15, color: tint),
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
                      _capDots(context),
                      const SizedBox(width: FxSpacing.sm),
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
            TagTile(
              node: child,
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

  Widget _capDots(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (node.canExpense) _dot(finance.expense),
        if (node.canIncome) _dot(finance.income),
        if (node.canTransfer) _dot(finance.transfer),
      ],
    );
  }

  Widget _dot(Color color) => Padding(
    padding: const EdgeInsets.only(left: 3),
    child: Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
