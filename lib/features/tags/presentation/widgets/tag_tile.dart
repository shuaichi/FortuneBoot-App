import 'package:flutter/material.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 标签树节点（自绘 accordion）。展示 #名称 + 可支/收/转 状态点。
class TagTile extends StatefulWidget {
  final FortuneTagVo node;
  final int depth;
  final void Function(FortuneTagVo) onTap;
  final void Function(FortuneTagVo) onMenu;

  const TagTile({
    super.key,
    required this.node,
    required this.onTap,
    required this.onMenu,
    this.depth = 0,
  });

  @override
  State<TagTile> createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final node = widget.node;
    final hasChildren = node.children.isNotEmpty;
    final isRoot = widget.depth == 0;
    final tint = node.enable ? finance.transfer : palette.textTertiary;
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
                          color: tint.withValues(alpha: 0.14),
                          borderRadius: FxRadius.tileBorder,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.tag_rounded, size: 15, color: tint),
                      ),
                      const SizedBox(width: FxSpacing.sm),
                      Expanded(
                        child: Text(
                          node.tagName ?? S.of(context).tagsUnnamed,
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
                      _capDots(context, node),
                      const SizedBox(width: FxSpacing.sm),
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
                              width: 48,
                              height: 48,
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
        if (hasChildren && _expanded) ...[
          const SizedBox(height: FxSpacing.xs),
          for (final child in node.children) ...[
            TagTile(
              node: child,
              depth: widget.depth + 1,
              onTap: widget.onTap,
              onMenu: widget.onMenu,
            ),
            const SizedBox(height: FxSpacing.xs),
          ],
        ],
      ],
    );
  }

  Widget _capDots(BuildContext context, FortuneTagVo node) {
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
