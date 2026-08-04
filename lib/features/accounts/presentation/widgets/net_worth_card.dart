import 'package:flutter/material.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 净资产总览大卡：净资产大数字 + 资产(绿)/负债(红)双进度条。
class NetWorthCard extends StatelessWidget {
  final AssetsLiabilities assets;
  final String? currencyCode;

  const NetWorthCard({
    super.key,
    required this.assets,
    this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final total = assets.totalAssets + assets.totalLiabilities;
    final assetRatio = total <= 0 ? 0.0 : assets.totalAssets / total;
    final liabRatio = total <= 0 ? 0.0 : assets.totalLiabilities / total;

    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FxCardLabel('净资产'),
          const SizedBox(height: FxSpacing.sm),
          FxMoneyText(
            amount: assets.netAssets,
            currencyCode: currencyCode,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: FxColors.textPrimary,
          ),
          const SizedBox(height: FxSpacing.lg),
          _bar('资产', assets.totalAssets, assetRatio, FxColors.income),
          const SizedBox(height: FxSpacing.md),
          _bar('负债', assets.totalLiabilities, liabRatio, FxColors.expense),
        ],
      ),
    );
  }

  Widget _bar(String label, double amount, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: FxSpacing.sm),
                Text(label, style: FxTypography.label),
              ],
            ),
            FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: 14,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.xs),
        FxProgressBar(value: ratio, color: color),
      ],
    );
  }
}
