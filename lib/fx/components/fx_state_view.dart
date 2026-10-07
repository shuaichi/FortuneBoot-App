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
    this.compact = false,
    this.loadingLabel,
    this.retryLabel,
  });

  final _Kind kind;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;
  final String? loadingLabel;
  final String? retryLabel;

  factory FxStateView.loading({
    String? message,
    bool compact = false,
    String? loadingLabel,
  }) => FxStateView._(
    kind: _Kind.loading,
    message: message,
    compact: compact,
    loadingLabel: loadingLabel,
  );

  factory FxStateView.error({
    String? message,
    VoidCallback? onRetry,
    String? retryLabel,
    bool compact = false,
  }) => FxStateView._(
    kind: _Kind.error,
    message: message,
    onRetry: onRetry,
    retryLabel: retryLabel,
    compact: compact,
  );

  factory FxStateView.empty({
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    String? retryLabel,
    bool compact = false,
  }) => FxStateView._(
    kind: _Kind.empty,
    message: message,
    icon: icon,
    onRetry: onRetry,
    retryLabel: retryLabel,
    compact: compact,
  );

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    switch (kind) {
      case _Kind.loading:
        return Semantics(
          liveRegion: true,
          label: loadingLabel ?? message,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(compact ? FxSpacing.md : FxSpacing.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2.5),
                  if (message != null) ...[
                    const SizedBox(height: FxSpacing.sm),
                    Text(message!),
                  ],
                ],
              ),
            ),
          ),
        );
      case _Kind.error:
        return _message(
          context,
          icon ?? Icons.error_outline_rounded,
          message ?? '',
          palette.danger,
          retryLabel: retryLabel,
        );
      case _Kind.empty:
        return _message(
          context,
          icon ?? Icons.inbox_rounded,
          message ?? '',
          palette.textTertiary,
          retryLabel: onRetry != null ? retryLabel : null,
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
