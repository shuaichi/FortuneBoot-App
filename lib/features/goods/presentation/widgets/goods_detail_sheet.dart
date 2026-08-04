import 'package:flutter/material.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 归物详情（FxSheet 内）：持有天数 / 日均成本 / 过保 / 出售盈亏等。
class GoodsDetailSheet extends StatelessWidget {
  final FortuneGoodsKeeperVo goods;
  final String? currencyCode;

  const GoodsDetailSheet({
    super.key,
    required this.goods,
    this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final profit = goods.profit;
    return SingleChildScrollView(
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
                child: Text(goods.goodsName ?? '未命名', style: FxTypography.title),
              ),
              FxMoneyText(
                amount: goods.price ?? 0,
                currencyCode: currencyCode,
                fontSize: 20,
                color: FxColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          _row('购买日期', goods.purchaseDate ?? '-'),
          if (goods.holdingTime != null)
            _row('持有天数', '${goods.holdingTime} 天'),
          if (goods.dailyAverageCost != null)
            _row('日均成本', goods.dailyAverageCost!.toStringAsFixed(2)),
          if ((goods.categoryName ?? '').isNotEmpty)
            _row('分类', goods.categoryName!),
          if ((goods.tagName ?? '').isNotEmpty) _row('标签', goods.tagName!),
          if ((goods.warrantyDate ?? '').isNotEmpty)
            _row('保修日期', goods.warrantyDate!),
          if ((goods.isOverWarranty ?? '').isNotEmpty)
            _row('保修状态', goods.isOverWarranty!),
          if (goods.useByTimes && goods.usageNum != null)
            _row('使用次数', '${goods.usageNum}'),
          if ((goods.statusDesc ?? '').isNotEmpty)
            _row('状态', goods.statusDesc!),
          if ((goods.retiredDate ?? '').isNotEmpty)
            _row('退役日期', goods.retiredDate!),
          if (goods.soldPrice != null)
            _row('出售价格', goods.soldPrice!.toStringAsFixed(2)),
          if (profit != null)
            _row(
              '出售盈亏',
              '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)}',
              valueColor: profit >= 0 ? FxColors.income : FxColors.expense,
            ),
          if ((goods.remark ?? '').isNotEmpty) _row('备注', goods.remark!),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: FxTypography.label),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Text(
              value,
              style: FxTypography.body.copyWith(
                color: valueColor ?? FxColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
