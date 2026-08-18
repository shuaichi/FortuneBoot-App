import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
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
              onSelectionChanged: (values) =>
                  setState(() => _method = values.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _credentialController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: activeMethod == AppLockMethod.pin
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: activeMethod == AppLockMethod.pin
                    ? s.appLockPinSetupLabel
                    : s.appLockPatternSetupLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmationController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: activeMethod == AppLockMethod.pin
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: s.appLockConfirmCredentialLabel,
                border: const OutlineInputBorder(),
              ),
            ),
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
    if (_credentialController.text != _confirmationController.text) {
      _showMessage(S.of(context).appLockCredentialMismatch);
      return;
    }
    setState(() => _isSaving = true);
    final ok = await context.read<AppLockCubit>().configure(
      method: _method,
      value: _credentialController.text,
      biometricEnabled: _biometricEnabled,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
    if (!ok) _showMessage(S.of(context).appLockConfigurationInvalid);
  }

  Future<void> _disable() async {
    final credential = await _askForCredential();
    if (credential == null || !mounted) return;
    setState(() => _isSaving = true);
    final ok = await context.read<AppLockCubit>().disable(credential);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
    if (!ok) _showMessage(S.of(context).appLockDisableVerificationFailed);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
