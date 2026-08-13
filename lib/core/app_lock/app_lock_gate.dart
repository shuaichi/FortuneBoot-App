import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

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
                    '好记已锁定',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.status == AppLockStatus.setupRequired
                        ? '应用锁配置不完整，请重新登录后在我的页面设置。'
                        : isPin
                        ? '请输入数字密码以继续'
                        : '请输入手势节点序列以继续',
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
                        errorText: state.errorMessage,
                        hintText: isPin ? '6–12 位数字密码' : '例如 0,1,2,5',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _unlock(),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _unlock, child: const Text('解锁')),
                    if (state.settings?.biometricEnabled == true) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: state.isAuthenticating
                            ? null
                            : () => context
                                  .read<AppLockCubit>()
                                  .unlockWithBiometrics(),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: const Text('使用生物识别'),
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

  Future<void> _unlock() async {
    final unlocked = await context.read<AppLockCubit>().unlockWithCredential(
      _controller.text,
    );
    if (unlocked) _controller.clear();
  }
}
