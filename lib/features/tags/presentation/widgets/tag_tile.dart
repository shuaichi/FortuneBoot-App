import 'package:flutter/material.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
                    Expanded(
                      child: Text(
                        '#${node.tagName ?? '未命名'}',
                        style: FxTypography.body.copyWith(
                          color: node.enable
                              ? FxColors.textPrimary
                              : FxColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _capDots(node),
                    const SizedBox(width: FxSpacing.sm),
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

  Widget _capDots(FortuneTagVo node) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (node.canExpense) _dot(FxColors.expense),
        if (node.canIncome) _dot(FxColors.income),
        if (node.canTransfer) _dot(FxColors.transfer),
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
