import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class LogoutConfirmDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const LogoutConfirmDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return HJDialog(
      title: '退出登录',
      headerIcon: Icons.warning_amber_rounded,
      headerIconColor: HJColors.expense,
      content: const Text(
        '确定要退出当前账号吗？\n退出后需要重新登录才能使用记账功能。',
        style: TextStyle(
          fontSize: 15,
          color: HJColors.textSecondary,
          height: 1.6,
        ),
      ),
      secondaryAction: HJButton.secondary(
        text: '取消',
        onPressed: () => Navigator.pop(context),
      ),
      primaryAction: HJButton.critical(
        text: '退出',
        onPressed: () async {
          Navigator.pop(context);
          await onConfirm();
        },
      ),
    );
  }
}
