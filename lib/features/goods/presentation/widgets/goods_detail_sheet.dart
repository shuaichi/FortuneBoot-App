import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
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
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
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
          Align(
            alignment: Alignment.centerLeft,
            child: FxMoneyText(
              amount: goods.price ?? 0,
              currencyCode: currencyCode,
              fontSize: 20,
              color: palette.textPrimary,
              masked: hideAmounts,
            ),
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
              _formatMoney(context, goods.dailyAverageCost!, hideAmounts),
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
              _formatMoney(context, goods.soldPrice!, hideAmounts),
            ),
          if (profit != null)
            _row(
              context,
              S.of(context).goodsFieldProfit,
              _formatMoney(context, profit, hideAmounts, showSign: true),
              valueColor: profit >= 0 ? finance.income : finance.expense,
            ),
          if ((goods.remark ?? '').isNotEmpty)
            _row(context, S.of(context).goodsFieldRemark, goods.remark!),
        ],
      ),
    );
  }

  String _formatMoney(
    BuildContext context,
    double amount,
    bool masked, {
    bool showSign = false,
  }) {
    return FxMoneyFormatter.format(
      amount,
      locale: Localizations.localeOf(context).toString(),
      showSign: showSign,
      visibility: masked
          ? FxAmountVisibility.hidden
          : FxAmountVisibility.visible,
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
