import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// Confirmation sheet for actions that need an explicit user decision.
class FxConfirmSheet extends StatefulWidget {
  const FxConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.destructive = false,
    this.failureMessage,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Future<bool> Function() onConfirm;
  final bool destructive;
  final String? failureMessage;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required Future<bool> Function() onConfirm,
    bool destructive = false,
    String? failureMessage,
  }) {
    return FxSheet.show<bool>(
      context,
      title: title,
      child: FxConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        destructive: destructive,
        failureMessage: failureMessage,
      ),
    );
  }

  @override
  State<FxConfirmSheet> createState() => _FxConfirmSheetState();
}

class _FxConfirmSheetState extends State<FxConfirmSheet> {
  var _loading = false;
  var _failed = false;

  Future<void> _confirm() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final successful = await widget.onConfirm();
      if (!mounted) return;
      if (successful) {
        Navigator.of(context).pop(true);
        return;
      }
    } on Object {
      // Callers map technical failures to a safe [failureMessage].
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final confirm = widget.destructive
        ? FxButton.critical(
            label: widget.confirmLabel,
            loading: _loading,
            onPressed: _confirm,
          )
        : FxButton(
            label: widget.confirmLabel,
            loading: _loading,
            onPressed: _confirm,
          );
    return FxSheetPopGuard(
      hasUnsavedChanges: false,
      isBusy: _loading,
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.message),
            if (_failed) ...[
              const SizedBox(height: FxSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  widget.failureMessage ?? S.of(context).fxConfirmFailure,
                ),
              ),
            ],
            const SizedBox(height: FxSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: FxButton.tonal(
                    label: widget.cancelLabel,
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: FxSpacing.sm),
                Expanded(child: confirm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
