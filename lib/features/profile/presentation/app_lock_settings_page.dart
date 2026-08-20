import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';
import 'package:fortuneboot/core/app_lock/presentation/pattern_lock_grid.dart';
import 'package:fortuneboot/generated/l10n.dart';

class AppLockSettingsPage extends StatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  final _credentialController = TextEditingController();
  final _confirmationController = TextEditingController();
  AppLockMethod _method = AppLockMethod.pin;
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppLockCubit>().state;
    final s = S.of(context);
    final settings = state.settings;
    final isEnabled =
        settings != null && state.status != AppLockStatus.disabled;
    final activeMethod = isEnabled ? settings.method : _method;
    return Scaffold(
      appBar: AppBar(title: Text(s.appLockSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            isEnabled ? s.appLockEnabledHeading : s.appLockEnableHeading,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            isEnabled
                ? s.appLockEnabledDescription
                : s.appLockEnableDescription,
          ),
          const SizedBox(height: 24),
          if (!isEnabled) ...[
            SegmentedButton<AppLockMethod>(
              segments: [
                ButtonSegment(
                  value: AppLockMethod.pin,
                  label: Text(s.appLockPinMethod),
                ),
                ButtonSegment(
                  value: AppLockMethod.pattern,
                  label: Text(s.appLockPatternMethod),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (values) => setState(() {
                _method = values.first;
                _initialPattern = null;
                _isPatternConfirmed = false;
                _patternError = null;
                _patternResetToken++;
                _credentialController.clear();
                _confirmationController.clear();
              }),
            ),
            const SizedBox(height: 20),
            if (activeMethod == AppLockMethod.pin) ...[
              TextField(
                controller: _credentialController,
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
                  labelText: s.appLockPinSetupLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmationController,
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
                  labelText: s.appLockConfirmCredentialLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ] else ...[
              Text(
                _initialPattern == null
                    ? s.appLockDrawPattern
                    : s.appLockConfirmPattern,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _patternError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              TextButton(
                onPressed: _isSaving ? null : _resetPattern,
                child: Text(s.appLockPatternReset),
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(s.appLockBiometricToggleTitle),
              subtitle: Text(
                _isBiometricAvailable
                    ? s.appLockBiometricAvailableSubtitle
                    : s.appLockBiometricUnavailableSubtitle,
              ),
              value: _biometricEnabled,
              onChanged: _isBiometricAvailable
                  ? (value) => setState(() => _biometricEnabled = value)
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _enable,
              child: Text(_isSaving ? s.appLockSaving : s.appLockEnable),
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline_rounded),
              title: Text(s.appLockCurrentMethod),
              subtitle: Text(
                activeMethod == AppLockMethod.pin
                    ? s.appLockPinMethod
                    : s.appLockPatternMethod,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<AppLockCubit>().lockNow(),
              icon: const Icon(Icons.lock_rounded),
              label: Text(s.appLockLockNow),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _isSaving ? null : _disable,
              icon: const Icon(Icons.lock_open_rounded),
              label: Text(s.appLockDisable),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadBiometricAvailability() async {
    final available = await context.read<AppLockCubit>().isBiometricAvailable();
    if (!mounted) return;
    setState(() {
      _isBiometricAvailable = available;
      if (!available) _biometricEnabled = false;
    });
  }

  Future<void> _enable() async {
    final value = switch (_method) {
      AppLockMethod.pin => _credentialController.text,
      AppLockMethod.pattern =>
        _isPatternConfirmed ? _initialPattern?.traditionalCanonicalCsv : null,
    };
    if (_method == AppLockMethod.pin &&
        _credentialController.text != _confirmationController.text) {
      _showMessage(S.of(context).appLockCredentialMismatch);
      return;
    }
    if (value == null) {
      _showMessage(S.of(context).appLockPatternMinimumPoints);
      return;
    }
    setState(() => _isSaving = true);
    final ok = await context.read<AppLockCubit>().configure(
      method: _method,
      value: value,
      biometricEnabled: _biometricEnabled,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
    if (!ok) _showMessage(S.of(context).appLockConfigurationInvalid);
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
    final credential = await _askForCredential();
    if (credential == null || !mounted) return;
    setState(() => _isSaving = true);
    final ok = await context.read<AppLockCubit>().disable(credential);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
    if (!ok) _showMessage(S.of(context).appLockDisableVerificationFailed);
  }

  Future<void> _askForPattern() async {
    var resetToken = 0;
    var error = false;
    var isVerifying = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(S.of(dialogContext).appLockDisableDialogTitle),
          content: SizedBox(
            width: 280,
            child: PatternLockGrid(
              enabled: !isVerifying,
              error: error,
              resetToken: resetToken,
              semanticLabel: S
                  .of(dialogContext)
                  .appLockPatternAccessibilityLabel,
              minimumPointsMessage: S
                  .of(dialogContext)
                  .appLockPatternMinimumPoints,
              progressSemanticLabel: S.of(dialogContext).appLockPatternProgress,
              nodeSemanticLabel: (row, column, selected) => S
                  .of(dialogContext)
                  .appLockPatternNodeAccessibility(
                    row + 1,
                    column + 1,
                    selected
                        ? S.of(dialogContext).appLockPatternNodeSelected
                        : S.of(dialogContext).appLockPatternNodeUnselected,
                  ),
              onCompleted: (pattern) async {
                setDialogState(() => isVerifying = true);
                final ok = await context
                    .read<AppLockCubit>()
                    .disableWithPattern(pattern);
                if (!dialogContext.mounted) return;
                if (ok) {
                  Navigator.of(dialogContext).pop();
                  if (mounted) Navigator.of(context).pop();
                  return;
                }
                setDialogState(() {
                  error = true;
                  isVerifying = false;
                  resetToken++;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(S.of(dialogContext).commonCancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _askForCredential() async {
    final method =
        context.read<AppLockCubit>().state.settings?.method ?? _method;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(dialogContext).appLockDisableDialogTitle),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: method == AppLockMethod.pin
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: S.of(dialogContext).appLockCurrentCredentialLabel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(dialogContext).commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(S.of(dialogContext).appLockVerify),
          ),
        ],
      ),
    );
    controller.clear();
    controller.dispose();
    return value;
  }

  void _showMessage(String message) {
    FxFeedback.error(context, message: message);
  }
}
