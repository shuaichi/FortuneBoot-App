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
///
/// 资产/负债色与首页净资卡共用 [FxPalette.success] / [FxPalette.danger]，
/// 不随用户自定义的收支色漂移。
class NetWorthCard extends StatelessWidget {
  final AssetsLiabilities assets;
  final String? currencyCode;

  const NetWorthCard({super.key, required this.assets, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    final assetMagnitude = assets.totalAssets.abs();
    final liabilityMagnitude = assets.totalLiabilities.abs();
    final total = assetMagnitude + liabilityMagnitude;
    final assetRatio = total <= 0 ? 0.0 : assetMagnitude / total;
    final liabRatio = total <= 0 ? 0.0 : liabilityMagnitude / total;

    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).accountsNetWorth),
          const SizedBox(height: FxSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FxMoneyText(
              amount: assets.netAssets,
              currencyCode: currencyCode,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
              masked: hideAmounts,
              compactWhenNeeded: true,
            ),
          ),
          const SizedBox(height: FxSpacing.lg),
          _bar(
            context,
            S.of(context).accountsAssets,
            assets.totalAssets,
            assetRatio,
            palette.success,
            hideAmounts,
          ),
          const SizedBox(height: FxSpacing.md),
          _bar(
            context,
            S.of(context).accountsLiabilities,
            assets.totalLiabilities,
            liabRatio,
            palette.danger,
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
                child: FxMoneyText(
                  amount: amount,
                  currencyCode: currencyCode,
                  fontSize: 14,
                  color: color,
                  masked: hideAmounts,
                  compactWhenNeeded: true,
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
