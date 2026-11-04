import 'package:flutter/material.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 归物卡片（网格项）：名称 + 价格 + 持有天数 + 日均成本 + 状态 + 过保。
class GoodsCard extends StatelessWidget {
  final FortuneGoodsKeeperVo goods;
  final String? currencyCode;
  final bool masked;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final VoidCallback? onLongPress;

  const GoodsCard({
    super.key,
    required this.goods,
    this.currencyCode,
    this.masked = false,
    this.onTap,
    this.onMenu,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return GestureDetector(
      onLongPress: onLongPress,
      child: FxCard(
        onTap: onTap,
        padding: const EdgeInsets.all(FxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    goods.goodsName ?? S.of(context).goodsUnnamed,
                    style: FxTypography.bodyStrong,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onMenu != null) _menuButton(context),
              ],
            ),
            const SizedBox(height: FxSpacing.xs),
            FxMoneyText(
              amount: goods.price ?? 0,
              currencyCode: currencyCode,
              fontSize: 18,
              color: palette.textPrimary,
              masked: masked,
              compactWhenNeeded: true,
            ),
            const SizedBox(height: FxSpacing.sm),
            if (goods.holdingTime != null)
              _line(
                context,
                Icons.schedule_rounded,
                S.of(context).goodsHoldingDays('${goods.holdingTime}'),
              ),
            if (goods.dailyAverageCost != null)
              _line(
                context,
                Icons.trending_down_rounded,
                S
                    .of(context)
                    .goodsDailyAvg(
                      FxMoneyFormatter.format(
                        goods.dailyAverageCost!,
                        locale: Localizations.localeOf(context).toString(),
                        visibility: masked
                            ? FxAmountVisibility.hidden
                            : FxAmountVisibility.visible,
                      ),
                    ),
              ),
            const SizedBox(height: FxSpacing.sm),
            Wrap(
              spacing: FxSpacing.xs,
              runSpacing: FxSpacing.xs,
              children: [
                if ((goods.statusDesc ?? '').isNotEmpty)
                  _tag(goods.statusDesc!, _statusColor(context, goods)),
                if ((goods.isOverWarranty ?? '').isNotEmpty)
                  _tag(
                    goods.isOverWarranty!,
                    goods.isOverWarrantyFlag
                        ? palette.warning
                        : palette.success,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      label: S.of(context).goodsMenuDetail,
      child: Tooltip(
        message: S.of(context).goodsMenuDetail,
        child: InkResponse(
          onTap: onMenu,
          radius: 24,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.more_horiz_rounded, color: palette.textTertiary),
          ),
        ),
      ),
    );
  }

  Widget _line(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: FxPalette.of(context).textTertiary),
          const SizedBox(width: FxSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Text(
          label,
          style: FxTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// 在役 / 退役 / 已出售使用不同的状态语义色，避免全部落回品牌蓝。
  Color _statusColor(BuildContext context, FortuneGoodsKeeperVo goods) {
    final palette = FxPalette.of(context);
    // status 与 statusDesc 的整型映射后端尚未固化，展示色优先跟随实际文案。
    final desc = (goods.statusDesc ?? '').toLowerCase();
    if (desc.contains('退役') || desc.contains('retired')) {
      return palette.textSecondary;
    }
    if (desc.contains('出售') || desc.contains('售') || desc.contains('sold')) {
      return palette.info;
    }
    if (desc.contains('在役') || desc.contains('使用') || desc.contains('active')) {
      return palette.success;
    }
    final status = GoodsStatus.fromValue(goods.status);
    if (status != null) {
      return switch (status) {
        GoodsStatus.active => palette.success,
        GoodsStatus.retired => palette.textSecondary,
        GoodsStatus.sold => palette.info,
      };
    }
    return palette.textSecondary;
  }
}
