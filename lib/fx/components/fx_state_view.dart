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
    this.title,
  });

  final _Kind kind;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;
  final String? loadingLabel;
  final String? retryLabel;
  final String? title;

  factory FxStateView.loading({
    String? message,
    bool compact = false,
    String? loadingLabel,
    String? title,
  }) => FxStateView._(
    kind: _Kind.loading,
    message: message,
    compact: compact,
    loadingLabel: loadingLabel,
    title: title,
  );

  factory FxStateView.error({
    String? message,
    VoidCallback? onRetry,
    String? retryLabel,
    bool compact = false,
    String? title,
  }) => FxStateView._(
    kind: _Kind.error,
    message: message,
    onRetry: onRetry,
    retryLabel: retryLabel,
    compact: compact,
    title: title,
  );

  factory FxStateView.empty({
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    String? retryLabel,
    bool compact = false,
    String? title,
  }) => FxStateView._(
    kind: _Kind.empty,
    message: message,
    icon: icon,
    onRetry: onRetry,
    retryLabel: retryLabel,
    compact: compact,
    title: title,
  );

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    switch (kind) {
      case _Kind.loading:
        return Semantics(
          liveRegion: true,
          label:
              loadingLabel ?? [title, message].whereType<String>().join(', '),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(compact ? FxSpacing.md : FxSpacing.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2.5),
                  if (title != null) ...[
                    const SizedBox(height: FxSpacing.sm),
                    Text(
                      title!,
                      style: FxTypography.bodyStrong.copyWith(
                        color: palette.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
          title: title,
          retryLabel: retryLabel,
        );
      case _Kind.empty:
        return _message(
          context,
          icon ?? Icons.inbox_rounded,
          message ?? '',
          palette.textTertiary,
          title: title,
          retryLabel: onRetry != null ? retryLabel : null,
        );
    }
  }

  Widget _message(
    BuildContext context,
    IconData iconData,
    String text,
    Color tint, {
    String? title,
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
            if (title != null) ...[
              Text(
                title,
                style: FxTypography.bodyStrong.copyWith(
                  color: palette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FxSpacing.sm),
            ],
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
