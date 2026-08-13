import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';

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
    final settings = state.settings;
    final isEnabled =
        settings != null && state.status != AppLockStatus.disabled;
    final activeMethod = isEnabled ? settings.method : _method;
    return Scaffold(
      appBar: AppBar(title: const Text('应用锁')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            isEnabled ? '已开启应用锁' : '开启应用锁',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(isEnabled ? '离开应用前台后需要重新验证。' : '设置后，离开应用前台或再次进入主界面时需要验证。'),
          const SizedBox(height: 24),
          if (!isEnabled) ...[
            SegmentedButton<AppLockMethod>(
              segments: const [
                ButtonSegment(value: AppLockMethod.pin, label: Text('数字密码')),
                ButtonSegment(
                  value: AppLockMethod.pattern,
                  label: Text('手势序列'),
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
                    ? '设置 6–12 位数字密码'
                    : '输入手势节点，例如 0,1,2,5',
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
              decoration: const InputDecoration(
                labelText: '再次确认',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('使用生物识别快捷解锁'),
              subtitle: Text(
                _isBiometricAvailable ? '仍需保留密码或手势作为回退方式' : '当前设备不支持或未设置生物识别',
              ),
              value: _biometricEnabled,
              onChanged: _isBiometricAvailable
                  ? (value) => setState(() => _biometricEnabled = value)
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _enable,
              child: Text(_isSaving ? '正在保存…' : '开启应用锁'),
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline_rounded),
              title: const Text('当前解锁方式'),
              subtitle: Text(
                activeMethod == AppLockMethod.pin ? '数字密码' : '手势序列',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<AppLockCubit>().lockNow(),
              icon: const Icon(Icons.lock_rounded),
              label: const Text('立即锁定'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _isSaving ? null : _disable,
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('关闭应用锁'),
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
      _showMessage('两次输入不一致');
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
    if (!ok) _showMessage('请检查密码或手势格式后重试');
  }

  Future<void> _disable() async {
    final credential = await _askForCredential();
    if (credential == null || !mounted) return;
    setState(() => _isSaving = true);
    final ok = await context.read<AppLockCubit>().disable(credential);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.of(context).pop();
    if (!ok) _showMessage('验证失败，请重试');
  }

  Future<String?> _askForCredential() async {
    final method =
        context.read<AppLockCubit>().state.settings?.method ?? _method;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('验证后关闭应用锁'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: method == AppLockMethod.pin
              ? TextInputType.number
              : TextInputType.text,
          decoration: const InputDecoration(labelText: '当前密码或手势'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('验证'),
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
