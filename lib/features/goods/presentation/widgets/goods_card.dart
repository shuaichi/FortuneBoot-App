import 'package:flutter/material.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 归物卡片（网格项）：名称 + 价格 + 持有天数 + 日均成本 + 状态 + 过保。
class GoodsCard extends StatelessWidget {
  final FortuneGoodsKeeperVo goods;
  final String? currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GoodsCard({
    super.key,
    required this.goods,
    this.currencyCode,
    this.onTap,
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
            Text(
              goods.goodsName ?? '未命名',
              style: FxTypography.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: FxSpacing.xs),
            FxMoneyText(
              amount: goods.price ?? 0,
              currencyCode: currencyCode,
              fontSize: 18,
              color: palette.textPrimary,
            ),
            const SizedBox(height: FxSpacing.sm),
            if (goods.holdingTime != null)
              _line(
                context,
                Icons.schedule_rounded,
                '持有 ${goods.holdingTime} 天',
              ),
            if (goods.dailyAverageCost != null)
              _line(
                context,
                Icons.trending_down_rounded,
                '日均 ${_money(goods.dailyAverageCost!)}',
              ),
            const SizedBox(height: FxSpacing.sm),
            Wrap(
              spacing: FxSpacing.xs,
              runSpacing: FxSpacing.xs,
              children: [
                if ((goods.statusDesc ?? '').isNotEmpty)
                  _tag(goods.statusDesc!, palette.primary),
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

  String _money(double v) => v.toStringAsFixed(2);

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
              style: FxTypography.caption,
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
      child: Text(
        label,
        style: FxTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
