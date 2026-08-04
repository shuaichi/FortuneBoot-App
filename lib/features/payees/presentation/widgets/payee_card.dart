import 'package:flutter/material.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
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
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return Material(
      color: palette.surface,
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
                  color: palette.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 20,
                  color: payee.enable ? palette.primary : palette.textTertiary,
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
                            ? palette.textPrimary
                            : palette.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _capChip(
                          context,
                          '可支',
                          payee.canExpense,
                          finance.expense,
                        ),
                        const SizedBox(width: FxSpacing.xs),
                        _capChip(
                          context,
                          '可收',
                          payee.canIncome,
                          finance.income,
                        ),
                        if (payee.sort != null) ...[
                          const SizedBox(width: FxSpacing.sm),
                          Text(
                            '排序 ${payee.sort}',
                            style: FxTypography.caption.copyWith(
                              color: palette.textTertiary,
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
    );
  }

  Widget _capChip(BuildContext context, String label, bool on, Color tint) {
    final palette = FxPalette.of(context);
    final color = on ? tint : palette.textTertiary;
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
