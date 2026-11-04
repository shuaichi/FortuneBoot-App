import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 图表卡基座：FxCard + 标题 + 区块态（loading/error/ready）兜底。
class StatsCardShell<T> extends StatelessWidget {
  final String label;
  final StatsSection<T> section;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  /// 数据已就绪但无图表内容时，折叠成轻量空态。
  final bool Function(T data)? isEmpty;

  /// 固定内容高度（图表需要确定高度）。
  final double height;

  const StatsCardShell({
    super.key,
    required this.label,
    required this.section,
    required this.onRetry,
    required this.builder,
    this.height = 220,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(label),
          const SizedBox(height: FxSpacing.sm),
          _body(context),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (section.status) {
      case StatsSectionStatus.loading:
        return FxStateView.loading(compact: true);
      case StatsSectionStatus.error:
        return FxStateView.error(
          message: section.error,
          onRetry: onRetry,
          retryLabel: S.of(context).commonRetry,
          compact: true,
        );
      case StatsSectionStatus.ready:
        final data = section.data as T;
        if (isEmpty?.call(data) ?? false) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
            child: Text(
              S.of(context).statsNoRecordsThisPeriod,
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textTertiary,
              ),
            ),
          );
        }
        return SizedBox(height: height, child: builder(data));
    }
  }
}
