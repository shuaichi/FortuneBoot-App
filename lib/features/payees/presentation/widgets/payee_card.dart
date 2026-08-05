import 'package:flutter/material.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 交易对象卡：与账户卡一致的悬浮卡片风格。
/// 左侧类型图标徽章 + 名称/停用置灰 + 可支/可收能力点 + 排序 + ⋯ 菜单。
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
    final disabled = !payee.enable;
    final tint = disabled ? palette.textTertiary : palette.primary;

    final card = Container(
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: FxRadius.cardBorder,
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: FxRadius.tileBorder,
            ),
            child: Icon(Icons.storefront_rounded, size: 22, color: tint),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee.payeeName ?? S.of(context).payeesUnnamed,
                  style: FxTypography.bodyStrong.copyWith(
                    color: disabled
                        ? palette.textTertiary
                        : palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _capChip(
                      context,
                      S.of(context).payeesCanExpenseShort,
                      payee.canExpense,
                      finance.expense,
                    ),
                    const SizedBox(width: FxSpacing.xs),
                    _capChip(
                      context,
                      S.of(context).payeesCanIncomeShort,
                      payee.canIncome,
                      finance.income,
                    ),
                    if (payee.sort != null) ...[
                      const SizedBox(width: FxSpacing.sm),
                      Text(
                        S.of(context).payeesSortValue(payee.sort!),
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
            radius: 20,
            onTap: onMenu,
            child: Icon(
              Icons.more_horiz_rounded,
              size: 20,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onMenu,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  Widget _capChip(BuildContext context, String label, bool on, Color tint) {
    final palette = FxPalette.of(context);
    final color = on ? tint : palette.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: on ? color.withValues(alpha: 0.12) : palette.surfaceMuted,
        borderRadius: FxRadius.pillBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            on
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(label, style: FxTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
