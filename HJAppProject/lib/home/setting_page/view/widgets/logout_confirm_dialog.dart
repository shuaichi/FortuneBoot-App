import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const LogoutConfirmDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return HJDialog(
      title: '退出登录',
      headerIcon: Icons.warning_amber_rounded,
      headerIconColor: Colors.red,
      content: const Text('确定要退出当前账号吗？\n退出后需要重新登录才能使用云同步功能。', style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
      secondaryAction: HJButton.secondary(text: '取消', onPressed: () => Navigator.pop(context)),
      primaryAction: HJButton.critical(
          text: '退出',
          onPressed: () {
            // 先关闭弹窗，再执行业务逻辑
            Navigator.pop(context);
            onConfirm();
          }
      ),
    );
  }
}