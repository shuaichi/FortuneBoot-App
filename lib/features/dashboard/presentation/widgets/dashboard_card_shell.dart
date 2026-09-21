import 'package:flutter/material.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_skeleton.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
        SectionStatus.loading => const _CardSkeleton(),
        SectionStatus.error => _CompactError(
          message: section.error ?? S.of(context).dashboardLoadFailed,
          onRetry: onRetry,
        ),
        SectionStatus.ready => builder(section.data as T),
      },
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FxSkeleton(width: 92, height: 14),
        FxSkeleton(width: double.infinity, height: 26),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxSkeleton(width: double.infinity, height: 8),
            SizedBox(height: FxSpacing.sm),
            FxSkeleton(width: 120, height: 8),
          ],
        ),
      ],
    );
  }
}

class _CompactError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _CompactError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 22, color: palette.danger),
          const SizedBox(height: FxSpacing.xs),
          Text(
            message,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FxSpacing.xs),
          Semantics(
            button: true,
            child: TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 36),
                padding: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                S.of(context).commonRetry,
                style: FxTypography.caption.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
