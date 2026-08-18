import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

class AppLockGate extends StatelessWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        if (!state.isLocked) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(child: IgnorePointer(child: child)),
            const _AppLockScreen(),
          ],
        );
      },
    );
  }
}

class _AppLockScreen extends StatefulWidget {
  const _AppLockScreen();

  @override
  State<_AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<_AppLockScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppLockCubit>().state;
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final isPin = state.settings?.method == AppLockMethod.pin;
    return Material(
      color: palette.canvas,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, color: palette.primary, size: 48),
                  const SizedBox(height: 20),
                  Text(
                    s.appLockGateTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.status == AppLockStatus.setupRequired
                        ? s.appLockSetupRequiredDescription
                        : isPin
                        ? s.appLockEnterPinDescription
                        : s.appLockEnterPatternDescription,
                    textAlign: TextAlign.center,
                  ),
                  if (state.status == AppLockStatus.locked) ...[
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: isPin
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: InputDecoration(
                        errorText: _failureMessage(state.failure, s),
                        hintText: isPin
                            ? s.appLockPinHint
                            : s.appLockPatternHint,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _unlock(),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _unlock,
                      child: Text(s.appLockUnlock),
                    ),
                    if (state.settings?.biometricEnabled == true) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: state.isAuthenticating
                            ? null
                            : () => context
                                  .read<AppLockCubit>()
                                  .unlockWithBiometrics(
                                    localizedReason:
                                        s.appLockBiometricLocalizedReason,
                                  ),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(s.appLockUseBiometrics),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _failureMessage(AppLockFailure? failure, S s) {
    return switch (failure) {
      AppLockFailure.invalidCredential => s.appLockFailureInvalidCredential,
      AppLockFailure.configurationSaveFailed =>
        s.appLockFailureConfigurationSave,
      AppLockFailure.disableFailed => s.appLockFailureDisable,
      null => null,
    };
  }

  Future<void> _unlock() async {
    final unlocked = await context.read<AppLockCubit>().unlockWithCredential(
      _controller.text,
    );
    if (unlocked) _controller.clear();
  }
}
