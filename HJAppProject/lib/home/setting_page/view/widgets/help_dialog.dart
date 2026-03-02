import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return HJDialog(
      title: '帮助说明',
      headerIcon: Icons.help_outline,
      content: const Text('这里是应用的帮助与说明文档。\n\n1. 您可以在设置中切换账本和分组。\n2. 所有的更改都会同步到云端。\n3. 如遇问题，请尝试重新登录。', style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.6)),
      primaryAction: HJButton.primary(text: '我知道了', onPressed: () => Navigator.pop(context)),
    );
  }
}