import 'package:flutter/material.dart';
import 'package:hjproject/Home/design_system/hjds_components.dart';

class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const LogoutConfirmDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children:[
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('退出登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('确定要退出当前账号吗？\n退出后需要重新登录才能使用云同步功能。', style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children:[
                Expanded(child: HJButton.secondary(text: '取消', onPressed: () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(child: HJButton.critical(text: '退出', onPressed: onConfirm)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}