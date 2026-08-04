import 'package:flutter/material.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 交易对象列表项：名称 + 可支/可收状态点 + 排序 + ⋯ 菜单。
class PayeeCard extends StatelessWidget {
  final FortunePayeeVo payee;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  const PayeeCard({
    super.key,
    required this.payee,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FxColors.surface,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FxColors.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 20,
                  color: payee.enable
                      ? FxColors.primary
                      : FxColors.textTertiary,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payee.payeeName ?? '未命名',
                      style: FxTypography.bodyStrong.copyWith(
                        color: payee.enable
                            ? FxColors.textPrimary
                            : FxColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _capChip('可支', payee.canExpense, FxColors.expense),
                        const SizedBox(width: FxSpacing.xs),
                        _capChip('可收', payee.canIncome, FxColors.income),
                        if (payee.sort != null) ...[
                          const SizedBox(width: FxSpacing.sm),
                          Text(
                            '排序 ${payee.sort}',
                            style: FxTypography.caption.copyWith(
                              color: FxColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              InkResponse(
                radius: 18,
                onTap: onMenu,
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
    );
  }

  Widget _capChip(String label, bool on, Color tint) {
    final color = on ? tint : FxColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          on ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(label, style: FxTypography.caption.copyWith(color: color)),
      ],
    );
  }
}
