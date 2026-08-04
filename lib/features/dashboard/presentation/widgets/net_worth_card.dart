import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// ① 净资产大卡（跨2列、2行高）：大号净资产 + 资产(绿)/负债(红)双进度条。
/// 新用户空态：引导"开始记第一笔 →"。
class NetWorthCard extends StatelessWidget {
  final DashboardSection<AssetsLiabilities> section;
  final String? currencyCode;
  final bool emptyUser;
  final VoidCallback onRetry;

  const NetWorthCard({
    super.key,
    required this.section,
    required this.currencyCode,
    required this.emptyUser,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (emptyUser) {
      return FxCard(
        onTap: () => AppRouter.push<void>(context, Routes.billEditor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FxCardLabel('净资产'),
            const Spacer(),
            const Text('还没有记录', style: FxTypography.title),
            const SizedBox(height: FxSpacing.xs),
            Row(
              children: [
                Text(
                  '开始记第一笔',
                  style: FxTypography.body.copyWith(
                    color: FxColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: FxColors.primary,
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      );
    }

    return DashboardCardShell<AssetsLiabilities>(
      section: section,
      onRetry: onRetry,
      builder: (data) {
        final total = data.totalAssets + data.totalLiabilities;
        final assetRatio = total <= 0 ? 0.0 : data.totalAssets / total;
        final liabRatio = total <= 0 ? 0.0 : data.totalLiabilities / total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FxCardLabel('净资产'),
            const SizedBox(height: FxSpacing.sm),
            FxMoneyText(
              amount: data.netAssets,
              currencyCode: currencyCode,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: FxColors.textPrimary,
            ),
            const Spacer(),
            _bar('资产', data.totalAssets, assetRatio, FxColors.income),
            const SizedBox(height: FxSpacing.md),
            _bar('负债', data.totalLiabilities, liabRatio, FxColors.expense),
          ],
        );
      },
    );
  }

  Widget _bar(String label, double amount, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: FxTypography.caption),
            FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: 13,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.xs),
        FxProgressBar(value: ratio, color: color, height: 6),
      ],
    );
  }
}
