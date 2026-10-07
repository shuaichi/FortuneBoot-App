import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/app_lock_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/security/app_lock_authenticator.dart';
import 'package:fortuneboot/core/security/app_lock_cubit.dart';
import 'package:fortuneboot/core/security/app_lock_fingerprint_hint.dart';
import 'package:fortuneboot/core/security/app_lock_gesture_pad.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  AppLockAvailability? _availability;
  AppLockMethod? _sessionMethod;
  final _password = TextEditingController();
  var _passwordError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _password.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeAutoBiometric();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppLockCubit, AppLockState>(
      listenWhen: (previous, current) =>
          previous.shouldBlock != current.shouldBlock,
      listener: (context, state) {
        if (!state.shouldBlock) {
          _availability = null;
          _sessionMethod = null;
          _password.clear();
          _passwordError = false;
          return;
        }
        unawaited(_loadAvailability());
      },
      builder: (context, state) {
        if (!state.shouldBlock) return widget.child;
        final palette = FxPalette.of(context);
        final s = S.of(context);
        final preferred = context.select<PreferencesCubit, AppLockMethod>(
          (c) => c.state.appLock.method,
        );
        final methods = _availability?.methods ?? const <AppLockMethod>[];
        final wanted = _sessionMethod ?? preferred;
        final primary = methods.contains(wanted)
            ? wanted
            : (methods.isEmpty ? null : methods.first);
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            Material(
              color: palette.canvas,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(FxSpacing.xl),
                  child: Column(
                    children: [
                      const Spacer(),
                      Icon(Icons.lock_rounded, size: 64, color: palette.primary),
                      const SizedBox(height: FxSpacing.lg),
                      Text(
                        s.appLockTitle,
                        style: FxTypography.title.copyWith(
                          color: palette.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: FxSpacing.sm),
                      Text(
                        s.appLockPickMethod,
                        style: FxTypography.body.copyWith(
                          color: palette.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: FxSpacing.xl),
                      if (_availability == null)
                        const CircularProgressIndicator()
                      else if (primary == null)
                        Text(
                          s.profileAppLockUnavailable,
                          textAlign: TextAlign.center,
                          style: FxTypography.body.copyWith(
                            color: palette.textSecondary,
                          ),
                        )
                      else
                        Flexible(
                          flex: 8,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _unlockBody(
                                  context,
                                  s,
                                  palette,
                                  state,
                                  primary,
                                ),
                                if (methods.length > 1) ...[
                                  const SizedBox(height: FxSpacing.lg),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      s.profileAppLockPickMethod,
                                      style: FxTypography.bodyStrong.copyWith(
                                        color: palette.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: FxSpacing.sm),
                                  for (final method in methods)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: FxSpacing.sm,
                                      ),
                                      child: Material(
                                        color: palette.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: state.authenticating
                                              ? null
                                              : () => _selectMethod(
                                                  context,
                                                  s,
                                                  method,
                                                ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: FxSpacing.md,
                                              vertical: FxSpacing.md,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  methodIcon(method),
                                                  color: palette.primary,
                                                ),
                                                const SizedBox(
                                                  width: FxSpacing.md,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    methodLabel(s, method),
                                                    style: FxTypography
                                                        .bodyStrong
                                                        .copyWith(
                                                          color: palette
                                                              .textPrimary,
                                                        ),
                                                  ),
                                                ),
                                                if (method == primary)
                                                  Icon(
                                                    Icons.check_rounded,
                                                    color: palette.primary,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _unlockBody(
    BuildContext context,
    S s,
    FxPalette palette,
    AppLockState state,
    AppLockMethod primary,
  ) {
    switch (primary) {
      case AppLockMethod.password:
        return Column(
          children: [
            FxTextField(
              label: s.profileAppLockMethodPassword,
              controller: _password,
              obscureText: true,
              errorText: _passwordError ? s.profileAppLockPasswordWrong : null,
              onSubmitted: (_) => _submitPassword(context, s),
            ),
            const SizedBox(height: FxSpacing.md),
            FxButton(
              label: s.appLockUnlock,
              expand: true,
              loading: state.authenticating,
              onPressed: state.authenticating
                  ? null
                  : () => _submitPassword(context, s),
            ),
          ],
        );
      case AppLockMethod.gesture:
        return Column(
          children: [
            if (_passwordError)
              Padding(
                padding: const EdgeInsets.only(bottom: FxSpacing.sm),
                child: Text(
                  s.profileAppLockGestureWrong,
                  style: FxTypography.caption.copyWith(color: palette.danger),
                ),
              ),
            AppLockGesturePad(
              enabled: !state.authenticating,
              onCompleted: (cells) => _submitGesture(context, s, cells),
            ),
          ],
        );
      case AppLockMethod.face:
        return FxButton(
          label: methodLabel(s, primary),
          icon: methodIcon(primary),
          expand: true,
          loading: state.authenticating,
          onPressed: state.authenticating
              ? null
              : () => context.read<AppLockCubit>().authenticate(
                  reason: s.appLockReason,
                  method: primary,
                ),
        );
      case AppLockMethod.fingerprint:
        if (state.authenticating) {
          return AppLockFingerprintHint(
            onCancel: () => context.read<AppLockCubit>().cancel(),
          );
        }
        return FxButton(
          label: methodLabel(s, primary),
          icon: methodIcon(primary),
          expand: true,
          onPressed: () => context.read<AppLockCubit>().authenticate(
            reason: s.appLockReason,
            method: primary,
          ),
        );
    }
  }

  Future<void> _submitPassword(BuildContext context, S s) async {
    final ok = await context.read<AppLockCubit>().authenticate(
      reason: s.appLockReason,
      method: AppLockMethod.password,
      password: _password.text,
    );
    if (!context.mounted) return;
    setState(() => _passwordError = !ok);
  }

  Future<void> _submitGesture(
    BuildContext context,
    S s,
    List<int> cells,
  ) async {
    final ok = await context.read<AppLockCubit>().authenticate(
      reason: s.appLockReason,
      method: AppLockMethod.gesture,
      gesture: cells,
    );
    if (!context.mounted) return;
    setState(() => _passwordError = !ok);
  }

  Future<void> _selectMethod(
    BuildContext context,
    S s,
    AppLockMethod method,
  ) async {
    setState(() {
      _sessionMethod = method;
      _passwordError = false;
    });
    unawaited(context.read<PreferencesCubit>().setAppLock(method: method));
    if (method == AppLockMethod.face || method == AppLockMethod.fingerprint) {
      await context.read<AppLockCubit>().authenticate(
        reason: s.appLockReason,
        method: method,
      );
    }
  }

  Future<void> _loadAvailability() async {
    final next = await context.read<AppLockCubit>().availability(
      unlocking: true,
    );
    if (!mounted) return;
    setState(() => _availability = next);
    _maybeAutoBiometric();
  }

  AppLockMethod? _primaryMethod() {
    final preferred = context.read<PreferencesCubit>().state.appLock.method;
    final methods = _availability?.methods ?? const <AppLockMethod>[];
    final wanted = _sessionMethod ?? preferred;
    if (methods.contains(wanted)) return wanted;
    return methods.isEmpty ? null : methods.first;
  }

  void _maybeAutoBiometric() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lock = context.read<AppLockCubit>();
      if (!lock.state.shouldBlock || lock.state.authenticating) return;
      final method = _primaryMethod();
      if (method == null) return;
      if (method != AppLockMethod.face && method != AppLockMethod.fingerprint) {
        return;
      }
      unawaited(
        lock.authenticate(
          reason: S.of(context).appLockReason,
          method: method,
        ),
      );
    });
  }
}

String methodLabel(S s, AppLockMethod method) {
  return switch (method) {
    AppLockMethod.face => s.profileAppLockMethodFace,
    AppLockMethod.fingerprint => s.profileAppLockMethodFingerprint,
    AppLockMethod.password => s.profileAppLockMethodPassword,
    AppLockMethod.gesture => s.profileAppLockMethodGesture,
  };
}

IconData methodIcon(AppLockMethod method) {
  return switch (method) {
    AppLockMethod.face => Icons.face_retouching_natural_rounded,
    AppLockMethod.fingerprint => Icons.fingerprint_rounded,
    AppLockMethod.password => Icons.password_rounded,
    AppLockMethod.gesture => Icons.gesture_rounded,
  };
}

Future<AppLockMethod?> showAppLockMethodSheet(
  BuildContext context, {
  required AppLockAvailability availability,
  AppLockMethod? current,
}) {
  final s = S.of(context);
  final palette = FxPalette.of(context);
  final methods = availability.methods;
  return showModalBottomSheet<AppLockMethod>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: FxSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(FxSpacing.lg),
                child: Text(
                  s.profileAppLockPickMethod,
                  style: FxTypography.title.copyWith(color: palette.textPrimary),
                ),
              ),
              for (final method in methods)
                ListTile(
                  leading: Icon(methodIcon(method), color: palette.primary),
                  title: Text(methodLabel(s, method)),
                  trailing: current == method
                      ? Icon(Icons.check_rounded, color: palette.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(method),
                ),
            ],
          ),
        ),
      );
    },
  );
}
