import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return HJDialog(
      title: '帮助说明',
      headerIcon: Icons.help_outline,
      headerIconColor: HJColors.primary,
      content: const Text(
          '这里是应用的帮助与说明文档。\n\n1. 您可以在设置中切换账本和分组。\n2. 所有的更改都会同步到云端。\n3. 如遇问题，请加QQ群：1009576058。',
          style: TextStyle(
              fontSize: 15, color: HJColors.textSecondary, height: 1.6)),
      primaryAction: HJButton.primary(
          text: '我知道了', onPressed: () => Navigator.pop(context)),
    );
  }
}