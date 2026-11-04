import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';
import 'package:fortuneboot/core/app_lock/presentation/pattern_lock_grid.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class AppLockSettingsPage extends StatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  final _credentialController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _credentialFocusNode = FocusNode();
  final _confirmationFocusNode = FocusNode();
  AppLockMethod _method = AppLockMethod.pin;
  AppLockPreferredUnlock _preferredUnlock = AppLockPreferredUnlock.pin;
  bool _isFaceAvailable = false;
  bool _isFingerprintAvailable = false;
  bool _isSaving = false;
  PatternPathResolution? _initialPattern;
  bool _isPatternConfirmed = false;
  int _patternResetToken = 0;
  String? _patternError;

  @override
  void initState() {
    super.initState();
    _loadBiometricAvailability();
  }

  @override
  void dispose() {
    _credentialController.clear();
    _confirmationController.clear();
    _credentialController.dispose();
    _confirmationController.dispose();
    _credentialFocusNode.dispose();
    _confirmationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final state = context.watch<AppLockCubit>().state;
    final s = S.of(context);
    final settings = state.settings;
    final isEnabled =
        settings != null && state.status != AppLockStatus.disabled;
    final activeMethod = isEnabled ? settings.method : _method;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, s),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  FxSpacing.lg,
                  FxSpacing.md,
                  FxSpacing.lg,
                  FxSpacing.xxxl,
                ),
                children: [
                  Text(
                    isEnabled
                        ? s.appLockEnabledHeading
                        : s.appLockEnableHeading,
                    style: FxTypography.titleLarge.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: FxSpacing.sm),
                  Text(
                    isEnabled
                        ? s.appLockEnabledDescription
                        : s.appLockEnableDescription,
                    style: FxTypography.body.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: FxSpacing.xl),
                  if (isEnabled)
                    _enabledContent(context, activeMethod)
                  else
                    _setupContent(context, activeMethod),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, S s) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
      child: Row(
        children: [
          FxIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: s.profileBack,
            color: palette.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: FxSpacing.xs),
          Expanded(
            child: Text(
              s.appLockSettingsTitle,
              style: FxTypography.title.copyWith(color: palette.textPrimary),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _setupContent(BuildContext context, AppLockMethod activeMethod) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.appLockFallbackMethodTitle,
          style: FxTypography.title.copyWith(
            color: FxPalette.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: FxSpacing.xs),
        Text(
          s.appLockFallbackMethodSubtitle,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: FxSpacing.md),
        FxCard(
          child: FxSegmented<AppLockMethod>(
            segments: [
              FxSegment(AppLockMethod.pin, s.appLockPinMethod),
              FxSegment(AppLockMethod.pattern, s.appLockPatternMethod),
            ],
            value: _method,
            onChanged: _changeMethod,
          ),
        ),
        const SizedBox(height: FxSpacing.lg),
        FxCard(
          child: activeMethod == AppLockMethod.pin
              ? _pinFields(context)
              : _patternFields(context),
        ),
        const SizedBox(height: FxSpacing.lg),
        Text(
          s.appLockPreferredUnlockTitle,
          style: FxTypography.title.copyWith(
            color: FxPalette.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: FxSpacing.xs),
        Text(
          s.appLockPreferredUnlockSubtitle,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: FxSpacing.md),
        FxCard(
          padding: EdgeInsets.zero,
          child: _preferredUnlockList(
            context,
            selected: _preferredUnlock,
            fallbackMethod: _method,
          ),
        ),
        const SizedBox(height: FxSpacing.xl),
        FxButton(
          label: _isSaving ? s.appLockSaving : s.appLockEnable,
          icon: Icons.lock_rounded,
          expand: true,
          loading: _isSaving,
          onPressed: _isSaving ? null : _enable,
        ),
      ],
    );
  }

  Widget _preferredUnlockList(
    BuildContext context, {
    required AppLockPreferredUnlock selected,
    required AppLockMethod fallbackMethod,
    bool persist = false,
  }) {
    final s = S.of(context);
    final options =
        <
          ({
            AppLockPreferredUnlock value,
            String label,
            IconData icon,
            bool enabled,
          })
        >[
          (
            value: AppLockPreferredUnlock.face,
            label: s.appLockPreferredFace,
            icon: Icons.face_rounded,
            enabled: _isFaceAvailable,
          ),
          (
            value: AppLockPreferredUnlock.fingerprint,
            label: s.appLockPreferredFingerprint,
            icon: Icons.fingerprint_rounded,
            enabled: _isFingerprintAvailable,
          ),
          (
            value: AppLockPreferredUnlock.pin,
            label: s.appLockPinMethod,
            icon: Icons.pin_rounded,
            enabled: fallbackMethod == AppLockMethod.pin,
          ),
          (
            value: AppLockPreferredUnlock.pattern,
            label: s.appLockPatternMethod,
            icon: Icons.gesture_rounded,
            enabled: fallbackMethod == AppLockMethod.pattern,
          ),
        ];
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 0.5,
              color: FxPalette.of(context).border,
            ),
          FxListItem(
            leading: Icon(
              options[i].icon,
              color: options[i].enabled
                  ? FxPalette.of(context).primary
                  : FxPalette.of(context).textTertiary,
            ),
            title: options[i].label,
            subtitle: options[i].enabled ? null : s.appLockPreferredUnavailable,
            trailing: Icon(
              selected == options[i].value
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected == options[i].value
                  ? FxPalette.of(context).primary
                  : FxPalette.of(context).textTertiary,
            ),
            onTap: (!options[i].enabled || _isSaving)
                ? null
                : () => _selectPreferred(options[i].value, persist: persist),
          ),
        ],
      ],
    );
  }

  Widget _pinFields(BuildContext context) {
    final s = S.of(context);
    final formatters = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(12),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FxTextField(
          label: s.appLockPinSetupLabel,
          helperText: s.appLockPinHint,
          controller: _credentialController,
          focusNode: _credentialFocusNode,
          obscureText: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: formatters,
          onSubmitted: (_) => _confirmationFocusNode.requestFocus(),
        ),
        const SizedBox(height: FxSpacing.md),
        FxTextField(
          label: s.appLockConfirmCredentialLabel,
          controller: _confirmationController,
          focusNode: _confirmationFocusNode,
          obscureText: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: formatters,
          onSubmitted: (_) {
            if (!_isSaving) _enable();
          },
        ),
      ],
    );
  }

  Widget _patternFields(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _initialPattern == null
              ? s.appLockDrawPattern
              : s.appLockConfirmPattern,
          style: FxTypography.title.copyWith(color: palette.textPrimary),
        ),
        const SizedBox(height: FxSpacing.sm),
        PatternLockGrid(
          key: const Key('app-lock-settings-pattern-grid'),
          enabled: !_isSaving,
          error: _patternError != null,
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
          onCompleted: _onPatternCompleted,
        ),
        if (_patternError != null) ...[
          const SizedBox(height: FxSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              _patternError!,
              style: FxTypography.body.copyWith(color: palette.danger),
            ),
          ),
        ],
        const SizedBox(height: FxSpacing.sm),
        FxButton.text(
          label: s.appLockPatternReset,
          onPressed: _isSaving ? null : _resetPattern,
        ),
      ],
    );
  }

  Widget _enabledContent(BuildContext context, AppLockMethod activeMethod) {
    final s = S.of(context);
    final settings = context.watch<AppLockCubit>().state.settings;
    final preferred = settings?.preferredUnlock ?? _preferredUnlock;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FxCard(
          padding: EdgeInsets.zero,
          child: FxListItem(
            leading: Icon(
              Icons.lock_outline_rounded,
              color: FxPalette.of(context).primary,
            ),
            title: s.appLockFallbackMethodTitle,
            subtitle: activeMethod == AppLockMethod.pin
                ? s.appLockPinMethod
                : s.appLockPatternMethod,
          ),
        ),
        const SizedBox(height: FxSpacing.lg),
        Text(
          s.appLockPreferredUnlockTitle,
          style: FxTypography.title.copyWith(
            color: FxPalette.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: FxSpacing.xs),
        Text(
          s.appLockPreferredUnlockSubtitle,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: FxSpacing.md),
        FxCard(
          padding: EdgeInsets.zero,
          child: _preferredUnlockList(
            context,
            selected: preferred,
            fallbackMethod: activeMethod,
            persist: true,
          ),
        ),
        const SizedBox(height: FxSpacing.lg),
        FxButton.tonal(
          label: s.appLockLockNow,
          icon: Icons.lock_rounded,
          expand: true,
          onPressed: () => context.read<AppLockCubit>().lockNow(),
        ),
        const SizedBox(height: FxSpacing.md),
        FxButton.critical(
          label: s.appLockDisable,
          icon: Icons.lock_open_rounded,
          expand: true,
          loading: _isSaving,
          onPressed: _isSaving ? null : _disable,
        ),
      ],
    );
  }

  Future<void> _selectPreferred(
    AppLockPreferredUnlock value, {
    required bool persist,
  }) async {
    if (!persist) {
      setState(() => _preferredUnlock = value);
      return;
    }
    setState(() {
      _preferredUnlock = value;
      _isSaving = true;
    });
    final ok = await context.read<AppLockCubit>().setPreferredUnlock(value);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (!ok) {
      _showMessage(S.of(context).appLockFailureConfigurationSave);
    }
  }

  void _changeMethod(AppLockMethod method) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _method = method;
      _initialPattern = null;
      _isPatternConfirmed = false;
      _patternError = null;
      _patternResetToken++;
      _credentialController.clear();
      _confirmationController.clear();
      // 回退方式变更时，默认解锁若不再合法则同步到回退方式。
      if (_preferredUnlock == AppLockPreferredUnlock.pin &&
          method != AppLockMethod.pin) {
        _preferredUnlock = AppLockPreferredUnlock.pattern;
      } else if (_preferredUnlock == AppLockPreferredUnlock.pattern &&
          method != AppLockMethod.pattern) {
        _preferredUnlock = AppLockPreferredUnlock.pin;
      }
    });
  }

  Future<void> _loadBiometricAvailability() async {
    final cubit = context.read<AppLockCubit>();
    final face = await cubit.isFaceAvailable();
    final fingerprint = await cubit.isFingerprintAvailable();
    if (!mounted) return;
    setState(() {
      _isFaceAvailable = face;
      _isFingerprintAvailable = fingerprint;
      if (_preferredUnlock == AppLockPreferredUnlock.face && !face) {
        _preferredUnlock = fingerprint
            ? AppLockPreferredUnlock.fingerprint
            : (_method == AppLockMethod.pattern
                  ? AppLockPreferredUnlock.pattern
                  : AppLockPreferredUnlock.pin);
      } else if (_preferredUnlock == AppLockPreferredUnlock.fingerprint &&
          !fingerprint) {
        _preferredUnlock = face
            ? AppLockPreferredUnlock.face
            : (_method == AppLockMethod.pattern
                  ? AppLockPreferredUnlock.pattern
                  : AppLockPreferredUnlock.pin);
      }
    });
  }

  Future<void> _enable() async {
    if (_method == AppLockMethod.pin &&
        !AppLockVerifier.isValidPin(_credentialController.text)) {
      _showMessage(S.of(context).appLockPinLengthInvalid);
      return;
    }
    if (_method == AppLockMethod.pin &&
        _credentialController.text != _confirmationController.text) {
      _showMessage(S.of(context).appLockCredentialMismatch);
      return;
    }
    final value = switch (_method) {
      AppLockMethod.pin => _credentialController.text,
      AppLockMethod.pattern =>
        _isPatternConfirmed ? _initialPattern?.traditionalCanonicalCsv : null,
    };
    if (value == null) {
      _showMessage(S.of(context).appLockPatternMinimumPoints);
      return;
    }
    setState(() => _isSaving = true);
    final cubit = context.read<AppLockCubit>();
    final ok = await cubit.configure(
      method: _method,
      value: value,
      preferredUnlock: _preferredUnlock,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    final s = S.of(context);
    final message = switch (cubit.state.failure) {
      AppLockFailure.configurationSaveFailed =>
        s.appLockFailureConfigurationSave,
      _ => s.appLockConfigurationInvalid,
    };
    _showMessage(message);
  }

  void _onPatternCompleted(PatternPathResolution pattern) {
    if (_initialPattern == null) {
      setState(() {
        _initialPattern = pattern;
        _isPatternConfirmed = false;
        _patternError = null;
        _patternResetToken++;
      });
      return;
    }
    if (listEquals(
      _initialPattern!.traditionalCanonicalPath,
      pattern.traditionalCanonicalPath,
    )) {
      setState(() {
        _isPatternConfirmed = true;
        _patternError = null;
        _patternResetToken++;
      });
      return;
    }
    setState(() {
      _patternError = S.of(context).appLockPatternMismatch;
      _patternResetToken++;
    });
  }

  void _resetPattern() {
    setState(() {
      _initialPattern = null;
      _isPatternConfirmed = false;
      _patternError = null;
      _patternResetToken++;
    });
  }

  Future<void> _disable() async {
    final method =
        context.read<AppLockCubit>().state.settings?.method ?? _method;
    if (method == AppLockMethod.pattern) {
      await _askForPattern();
      return;
    }
    final credential = await _askForCredential(method);
    if (credential == null || !mounted) return;
    setState(() => _isSaving = true);
    final ok = await context.read<AppLockCubit>().disable(credential);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
    if (!ok) _showMessage(S.of(context).appLockDisableVerificationFailed);
  }

  Future<void> _askForPattern() {
    return FxSheet.show<void>(
      context,
      title: S.of(context).appLockDisableDialogTitle,
      scrollable: true,
      child: _PatternVerificationSheet(
        onVerified: () {
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<String?> _askForCredential(AppLockMethod method) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    try {
      return await FxSheet.show<String>(
        context,
        title: S.of(context).appLockDisableDialogTitle,
        scrollable: true,
        child: _CredentialVerificationSheet(
          controller: controller,
          focusNode: focusNode,
          method: method,
        ),
      );
    } finally {
      controller.clear();
      controller.dispose();
      focusNode.dispose();
    }
  }

  void _showMessage(String message) {
    FxFeedback.error(context, message: message);
  }
}

class _PatternVerificationSheet extends StatefulWidget {
  const _PatternVerificationSheet({required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<_PatternVerificationSheet> createState() =>
      _PatternVerificationSheetState();
}

class _PatternVerificationSheetState extends State<_PatternVerificationSheet> {
  var _resetToken = 0;
  var _hasError = false;
  var _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PatternLockGrid(
            enabled: !_isVerifying,
            error: _hasError,
            resetToken: _resetToken,
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
            onCompleted: _verify,
          ),
          const SizedBox(height: FxSpacing.md),
          FxButton.text(
            label: s.commonCancel,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _verify(PatternPathResolution pattern) async {
    setState(() => _isVerifying = true);
    final ok = await context.read<AppLockCubit>().disableWithPattern(pattern);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      widget.onVerified();
      return;
    }
    setState(() {
      _hasError = true;
      _isVerifying = false;
      _resetToken++;
    });
  }
}

class _CredentialVerificationSheet extends StatelessWidget {
  const _CredentialVerificationSheet({
    required this.controller,
    required this.focusNode,
    required this.method,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLockMethod method;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPin = method == AppLockMethod.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FxTextField(
            label: s.appLockCurrentCredentialLabel,
            controller: controller,
            focusNode: focusNode,
            obscureText: true,
            keyboardType: isPin ? TextInputType.number : TextInputType.text,
            textInputAction: TextInputAction.done,
            inputFormatters: isPin
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ]
                : null,
            onSubmitted: (_) => Navigator.of(context).pop(controller.text),
          ),
          const SizedBox(height: FxSpacing.lg),
          FxButton(
            label: s.appLockVerify,
            icon: Icons.verified_user_rounded,
            expand: true,
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
          const SizedBox(height: FxSpacing.sm),
          FxButton.text(
            label: s.commonCancel,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
