import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 统一 loading / error / empty 三态视图。所有列表页用它兜底。
class FxStateView extends StatelessWidget {
  const FxStateView._({
    required this.kind,
    this.message,
    this.onRetry,
    this.icon,
  });

  final _Kind kind;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;

  factory FxStateView.loading({String? message}) =>
      FxStateView._(kind: _Kind.loading, message: message);

  factory FxStateView.error({String? message, VoidCallback? onRetry}) =>
      FxStateView._(kind: _Kind.error, message: message, onRetry: onRetry);

  factory FxStateView.empty({
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
  }) => FxStateView._(
    kind: _Kind.empty,
    message: message,
    icon: icon,
    onRetry: onRetry,
  );

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    switch (kind) {
      case _Kind.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(FxSpacing.xxxl),
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );
      case _Kind.error:
        return _message(
          context,
          icon ?? Icons.error_outline_rounded,
          message ?? '加载失败',
          palette.danger,
          retryLabel: '重试',
        );
      case _Kind.empty:
        return _message(
          context,
          icon ?? Icons.inbox_rounded,
          message ?? '暂无数据',
          palette.textTertiary,
          retryLabel: onRetry != null ? '刷新' : null,
        );
    }
  }

  Widget _message(
    BuildContext context,
    IconData iconData,
    String text,
    Color tint, {
    String? retryLabel,
  }) {
    final palette = FxPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 48, color: tint),
            const SizedBox(height: FxSpacing.md),
            Text(
              text,
              style: FxTypography.label.copyWith(color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null && retryLabel != null) ...[
              const SizedBox(height: FxSpacing.lg),
              FxButton.tonal(label: retryLabel, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Kind { loading, error, empty }
