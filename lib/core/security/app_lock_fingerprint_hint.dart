import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/app_lock_preferences.dart';
import 'package:fortuneboot/core/security/app_lock_cubit.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class AppLockFingerprintHint extends StatelessWidget {
  const AppLockFingerprintHint({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return Material(
      color: palette.surface,
      borderRadius: FxRadius.cardBorder,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.xl,
          FxSpacing.lg,
          FxSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fingerprint_rounded,
              size: 56,
              color: palette.primary,
            ),
            const SizedBox(height: FxSpacing.md),
            Text(
              s.profileAppLockMethodFingerprint,
              style: FxTypography.title.copyWith(color: palette.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FxSpacing.sm),
            Text(
              s.profileAppLockFingerprintHint,
              style: FxTypography.body.copyWith(color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FxSpacing.lg),
            FxButton.text(
              label: s.commonCancel,
              expand: true,
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showAppLockFingerprintPrompt(
  BuildContext context, {
  required String reason,
}) async {
  final lock = context.read<AppLockCubit>();
  var dialogOpen = true;
  unawaited(
    lock
        .authenticate(
          reason: reason,
          method: AppLockMethod.fingerprint,
        )
        .then((ok) {
          if (!dialogOpen || !context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop(ok);
        }),
  );
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AppLockFingerprintHint(
          onCancel: () {
            unawaited(lock.cancel());
            Navigator.of(dialogContext).pop(false);
          },
        ),
      );
    },
  );
  dialogOpen = false;
  if (result != true) unawaited(lock.cancel());
  return result == true;
}
