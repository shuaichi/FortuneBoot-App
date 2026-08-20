import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_models.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ⑧ 分类 Top3 支出洞察（跨满）：分类名 + 金额 + 占比进度条。
/// 无数据时整卡由父层隐藏,此处仅在 ready 且非空时渲染。
class CategoryTopCard extends StatelessWidget {
  final DashboardSection<List<CategorySlice>> section;
  final String? currencyCode;
  final VoidCallback onRetry;

  const CategoryTopCard({
    super.key,
    required this.section,
    required this.currencyCode,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    // 一组循环使用的分类色。
    final sliceColors = <Color>[
      palette.primary,
      finance.transfer,
      finance.adjust,
    ];
    return DashboardCardShell<List<CategorySlice>>(
      section: section,
      onRetry: onRetry,
      builder: (slices) {
        final maxValue = slices.fold<double>(
          0,
          (m, s) => s.value > m ? s.value : m,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxCardLabel(S.of(context).dashboardTopCategories),
            const SizedBox(height: FxSpacing.md),
            for (var i = 0; i < slices.length; i++) ...[
              _row(
                context,
                slices[i],
                sliceColors[i % sliceColors.length],
                maxValue,
                palette,
                hideAmounts,
              ),
              if (i != slices.length - 1) const SizedBox(height: FxSpacing.md),
            ],
          ],
        );
      },
    );
  }

  Widget _row(
    BuildContext context,
    CategorySlice slice,
    Color color,
    double maxValue,
    FxPalette palette,
    bool hideAmounts,
  ) {
    // 优先用后端 percent(0-100),否则用相对最大值的占比。
    final ratio = slice.percent > 0
        ? (slice.percent / 100).clamp(0.0, 1.0)
        : (maxValue <= 0 ? 0.0 : (slice.value / maxValue));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              slice.name.isEmpty
                  ? S.of(context).dashboardUncategorized
                  : slice.name,
              style: FxTypography.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            FxMoneyText(
              amount: slice.value,
              currencyCode: currencyCode,
              fontSize: 14,
              color: palette.textPrimary,
              masked: hideAmounts,
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.xs),
        FxProgressBar(value: ratio, color: color, height: 6),
      ],
    );
  }
}
