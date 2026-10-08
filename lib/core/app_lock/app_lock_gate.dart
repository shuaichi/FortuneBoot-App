import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';
import 'package:fortuneboot/core/app_lock/presentation/pattern_lock_grid.dart';
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

class _AppLockScreenState extends State<_AppLockScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  int _patternResetToken = 0;
  bool _autoBiometricTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoBiometric());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 切后台时可能已上锁；等回到前台再自动唤起生物识别。
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoBiometric());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppLockCubit>().state;
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final settings = state.settings;
    final isPin = settings?.method == AppLockMethod.pin;
    final preferred = settings?.preferredUnlock;
    final showBiometric =
        settings?.biometricPreferred == true &&
        state.status == AppLockStatus.locked;
    return Material(
      color: palette.canvas,
      child: SafeArea(
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: s.appLockGateTitle,
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
                      if (isPin) ...[
                        TextField(
                          controller: _controller,
                          autofocus: !showBiometric,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          decoration: InputDecoration(
                            errorText: _failureMessage(state.failure, s),
                            hintText: s.appLockPinHint,
                            counterText: '',
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _unlock(),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _unlock,
                          child: Text(s.appLockUnlockCta),
                        ),
                      ] else ...[
                        Text(
                          s.appLockDrawPattern,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        PatternLockGrid(
                          key: const Key('app-lock-pattern-grid'),
                          enabled: !state.isAuthenticating,
                          error:
                              state.failure == AppLockFailure.invalidCredential,
                          resetToken: _patternResetToken,
                          semanticLabel: s.appLockPatternAccessibilityLabel,
                          minimumPointsMessage: s.appLockPatternMinimumPoints,
                          progressSemanticLabel: s.appLockPatternProgress,
                          nodeSemanticLabel: (row, column, selected) =>
                              s.appLockPatternNodeAccessibility(
                                row + 1,
                                column + 1,
                                selected
                                    ? s.appLockPatternNodeSelected
                                    : s.appLockPatternNodeUnselected,
                              ),
                          onCompleted: _unlockPattern,
                        ),
                        if (state.failure != null) ...[
                          const SizedBox(height: 8),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _failureMessage(state.failure, s) ?? '',
                              style: TextStyle(color: palette.danger),
                            ),
                          ),
                        ],
                      ],
                      if (showBiometric) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: state.isAuthenticating
                              ? null
                              : () => _unlockWithBiometrics(s),
                          icon: Icon(
                            preferred == AppLockPreferredUnlock.face
                                ? Icons.face_rounded
                                : Icons.fingerprint_rounded,
                          ),
                          label: Text(
                            preferred == AppLockPreferredUnlock.face
                                ? s.appLockUseFace
                                : s.appLockUseFingerprint,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _tryAutoBiometric() {
    if (!mounted || _autoBiometricTriggered) return;
    // 后台上锁时不要立刻调起；等 resumed 再弹系统生物识别。
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final state = context.read<AppLockCubit>().state;
    if (state.status != AppLockStatus.locked ||
        state.settings?.biometricPreferred != true ||
        state.isAuthenticating) {
      return;
    }
    _autoBiometricTriggered = true;
    _unlockWithBiometrics(S.of(context));
  }

  Future<void> _unlockWithBiometrics(S s) {
    return context.read<AppLockCubit>().unlockWithBiometrics(
      localizedReason: s.appLockBiometricLocalizedReason,
    );
  }

  String? _failureMessage(AppLockFailure? failure, S s) {
    return switch (failure) {
      AppLockFailure.invalidCredential => s.appLockFailureInvalidCredential,
      AppLockFailure.biometricFailed => s.appLockFailureBiometric,
      AppLockFailure.biometricUnavailable =>
        s.appLockFailureBiometricUnavailable,
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

  Future<void> _unlockPattern(PatternPathResolution pattern) async {
    final unlocked = await context.read<AppLockCubit>().unlockWithPattern(
      pattern,
    );
    if (!mounted || unlocked) return;
    setState(() => _patternResetToken++);
  }
}
