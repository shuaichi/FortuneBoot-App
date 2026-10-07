import 'package:flutter/material.dart';
import 'package:fortuneboot/core/security/app_lock_gesture_pad.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

Future<String?> showAppLockPasswordSheet(
  BuildContext context, {
  required bool setup,
}) {
  return FxSheet.show<String>(
    context,
    title: setup
        ? S.of(context).profileAppLockPasswordSetup
        : S.of(context).profileAppLockMethodPassword,
    child: _PasswordSheetBody(setup: setup),
  );
}

class _PasswordSheetBody extends StatefulWidget {
  const _PasswordSheetBody({required this.setup});

  final bool setup;

  @override
  State<_PasswordSheetBody> createState() => _PasswordSheetBodyState();
}

class _PasswordSheetBodyState extends State<_PasswordSheetBody> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    final s = S.of(context);
    final a = _first.text.trim();
    if (a.length < 4) {
      setState(() => _error = s.profileAppLockPasswordTooShort);
      return;
    }
    if (widget.setup && a != _second.text.trim()) {
      setState(() => _error = s.profileAppLockPasswordMismatch);
      return;
    }
    Navigator.of(context).pop(a);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(FxSpacing.lg, 0, FxSpacing.lg, FxSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxTextField(
            label: s.profileAppLockMethodPassword,
            controller: _first,
            obscureText: true,
            errorText: _error,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: widget.setup ? null : (_) => _submit(),
          ),
          if (widget.setup) ...[
            const SizedBox(height: FxSpacing.md),
            FxTextField(
              label: s.profileAppLockPasswordConfirm,
              controller: _second,
              obscureText: true,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _submit(),
            ),
          ],
          const SizedBox(height: FxSpacing.lg),
          FxButton(label: s.commonConfirm, expand: true, onPressed: _submit),
        ],
      ),
    );
  }
}

Future<List<int>?> showAppLockGestureSheet(
  BuildContext context, {
  required bool setup,
}) {
  return FxSheet.show<List<int>>(
    context,
    title: setup
        ? S.of(context).profileAppLockGestureSetup
        : S.of(context).profileAppLockMethodGesture,
    child: _GestureSheetBody(setup: setup),
  );
}

class _GestureSheetBody extends StatefulWidget {
  const _GestureSheetBody({required this.setup});

  final bool setup;

  @override
  State<_GestureSheetBody> createState() => _GestureSheetBodyState();
}

class _GestureSheetBodyState extends State<_GestureSheetBody> {
  List<int>? _first;
  String? _hint;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(FxSpacing.lg, 0, FxSpacing.lg, FxSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error ??
                _hint ??
                (widget.setup
                    ? s.profileAppLockGestureHint
                    : s.profileAppLockGestureUnlock),
            textAlign: TextAlign.center,
            style: FxTypography.body.copyWith(
              color: _error != null ? palette.danger : palette.textSecondary,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          AppLockGesturePad(
            onCompleted: (cells) {
              if (!widget.setup) {
                Navigator.of(context).pop(cells);
                return;
              }
              if (_first == null) {
                setState(() {
                  _first = cells;
                  _error = null;
                  _hint = s.profileAppLockGestureAgain;
                });
                return;
              }
              if (_first!.join(',') != cells.join(',')) {
                setState(() {
                  _first = null;
                  _hint = null;
                  _error = s.profileAppLockGestureMismatch;
                });
                return;
              }
              Navigator.of(context).pop(cells);
            },
          ),
        ],
      ),
    );
  }
}
