import 'package:flutter/material.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 卡片内区块状态包装：loading→紧凑转圈，error→紧凑重试，ready→交给 [builder]。
/// 统一承载在 [FxCard] 内。使用紧凑态以适配 Bento 小格,避免溢出。
class DashboardCardShell<T> extends StatelessWidget {
  final DashboardSection<T> section;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;
  final VoidCallback? onTap;

  const DashboardCardShell({
    super.key,
    required this.section,
    required this.builder,
    required this.onRetry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      onTap: section.isReady ? onTap : null,
      child: switch (section.status) {
        SectionStatus.loading => const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
        SectionStatus.error => _CompactError(
          message: section.error ?? '加载失败',
          onRetry: onRetry,
        ),
        SectionStatus.ready => builder(section.data as T),
      },
    );
  }
}

class _CompactError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _CompactError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 22,
            color: FxColors.danger,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            message,
            style: FxTypography.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FxSpacing.xs),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              '重试',
              style: FxTypography.caption.copyWith(
                color: FxColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
