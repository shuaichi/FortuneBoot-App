import 'package:flutter/material.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 图表卡基座：FxCard + 标题 + 区块态（loading/error/ready）兜底。
class StatsCardShell<T> extends StatelessWidget {
  final String label;
  final StatsSection<T> section;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  /// 固定内容高度（图表需要确定高度）。
  final double height;

  const StatsCardShell({
    super.key,
    required this.label,
    required this.section,
    required this.onRetry,
    required this.builder,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(label),
          const SizedBox(height: FxSpacing.md),
          SizedBox(height: height, child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    switch (section.status) {
      case StatsSectionStatus.loading:
        return FxStateView.loading();
      case StatsSectionStatus.error:
        return FxStateView.error(message: section.error, onRetry: onRetry);
      case StatsSectionStatus.ready:
        return builder(section.data as T);
    }
  }
}
