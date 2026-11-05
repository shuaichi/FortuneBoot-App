import 'package:flutter/material.dart';

/// Tone for transient user feedback.
enum FxFeedbackTone { success, error, warning, info }

/// Centralized, presentation-safe transient feedback.
abstract final class FxFeedback {
  static const _defaultDuration = Duration(seconds: 4);

  static void show(
    BuildContext context, {
    required String message,
    required FxFeedbackTone tone,
    String? deduplicationKey,
    Duration duration = _defaultDuration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted || message.trim().isEmpty) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        content: Semantics(
          liveRegion: true,
          label: message,
          child: Text(message),
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
  }

  static void success(BuildContext context, {required String message}) =>
      show(context, message: message, tone: FxFeedbackTone.success);

  static void error(BuildContext context, {required String message}) =>
      show(context, message: message, tone: FxFeedbackTone.error);

  static void warning(BuildContext context, {required String message}) =>
      show(context, message: message, tone: FxFeedbackTone.warning);

  static void info(BuildContext context, {required String message}) =>
      show(context, message: message, tone: FxFeedbackTone.info);
}
