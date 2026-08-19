import 'package:flutter/material.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 归物详情（FxSheet 内）：持有天数 / 日均成本 / 过保 / 出售盈亏等。
class GoodsDetailSheet extends StatelessWidget {
  final FortuneGoodsKeeperVo goods;
  final String? currencyCode;

  const GoodsDetailSheet({super.key, required this.goods, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final profit = goods.profit;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goods.goodsName ?? S.of(context).goodsUnnamed,
                  style: FxTypography.title,
                ),
              ),
              FxMoneyText(
                amount: goods.price ?? 0,
                currencyCode: currencyCode,
                fontSize: 20,
                color: palette.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          _row(
            context,
            S.of(context).goodsFieldPurchaseDate,
            goods.purchaseDate ?? '-',
          ),
          if (goods.holdingTime != null)
            _row(
              context,
              S.of(context).goodsFieldHoldingTime,
              S.of(context).goodsDaysValue('${goods.holdingTime}'),
            ),
          if (goods.dailyAverageCost != null)
            _row(
              context,
              S.of(context).goodsStatDailyCost,
              goods.dailyAverageCost!.toStringAsFixed(2),
            ),
          if ((goods.categoryName ?? '').isNotEmpty)
            _row(
              context,
              S.of(context).goodsFieldCategory,
              goods.categoryName!,
            ),
          if ((goods.tagName ?? '').isNotEmpty)
            _row(context, S.of(context).goodsFieldTag, goods.tagName!),
          if ((goods.warrantyDate ?? '').isNotEmpty)
            _row(
              context,
              S.of(context).goodsFieldWarrantyDate,
              goods.warrantyDate!,
            ),
          if ((goods.isOverWarranty ?? '').isNotEmpty)
            _row(
              context,
              S.of(context).goodsFieldWarrantyStatus,
              goods.isOverWarranty!,
            ),
          if (goods.useByTimes && goods.usageNum != null)
            _row(
              context,
              S.of(context).goodsFieldUsageCount,
              '${goods.usageNum}',
            ),
          if ((goods.statusDesc ?? '').isNotEmpty)
            _row(context, S.of(context).goodsFieldStatus, goods.statusDesc!),
          if ((goods.retiredDate ?? '').isNotEmpty)
            _row(
              context,
              S.of(context).goodsFieldRetiredDate,
              goods.retiredDate!,
            ),
          if (goods.soldPrice != null)
            _row(
              context,
              S.of(context).goodsFieldSoldPrice,
              goods.soldPrice!.toStringAsFixed(2),
            ),
          if (profit != null)
            _row(
              context,
              S.of(context).goodsFieldProfit,
              '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)}',
              valueColor: profit >= 0 ? finance.income : finance.expense,
            ),
          if ((goods.remark ?? '').isNotEmpty)
            _row(context, S.of(context).goodsFieldRemark, goods.remark!),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: FxTypography.label.copyWith(
                color: FxPalette.of(context).textSecondary,
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Text(
              value,
              style: FxTypography.body.copyWith(
                color: valueColor ?? FxPalette.of(context).textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
