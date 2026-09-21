import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 净资产总览大卡：净资产大数字 + 资产(绿)/负债(红)双进度条。
class NetWorthCard extends StatelessWidget {
  final AssetsLiabilities assets;
  final String? currencyCode;

  const NetWorthCard({super.key, required this.assets, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    final total = assets.totalAssets + assets.totalLiabilities;
    final assetRatio = total <= 0 ? 0.0 : assets.totalAssets / total;
    final liabRatio = total <= 0 ? 0.0 : assets.totalLiabilities / total;

    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).accountsNetWorth),
          const SizedBox(height: FxSpacing.sm),
          _AdaptiveMoney(
            amount: assets.netAssets,
            currencyCode: currencyCode,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
            masked: hideAmounts,
          ),
          const SizedBox(height: FxSpacing.lg),
          _bar(
            context,
            S.of(context).accountsAssets,
            assets.totalAssets,
            assetRatio,
            finance.income,
            hideAmounts,
          ),
          const SizedBox(height: FxSpacing.md),
          _bar(
            context,
            S.of(context).accountsLiabilities,
            assets.totalLiabilities,
            liabRatio,
            finance.expense,
            hideAmounts,
          ),
        ],
      ),
    );
  }

  Widget _bar(
    BuildContext context,
    String label,
    double amount,
    double ratio,
    Color color,
    bool hideAmounts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: FxSpacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      style: FxTypography.label.copyWith(
                        color: FxPalette.of(context).textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _AdaptiveMoney(
                  amount: amount,
                  currencyCode: currencyCode,
                  fontSize: 14,
                  color: color,
                  masked: hideAmounts,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.xs),
        FxProgressBar(value: ratio, color: color),
      ],
    );
  }
}

class _AdaptiveMoney extends StatelessWidget {
  const _AdaptiveMoney({
    required this.amount,
    required this.currencyCode,
    required this.fontSize,
    required this.masked,
    this.fontWeight = FontWeight.w600,
    this.color,
  });

  final double amount;
  final String? currencyCode;
  final double fontSize;
  final bool masked;
  final FontWeight fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              masked: masked,
            ),
          ),
        );
      },
    );
  }
}
