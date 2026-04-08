import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class SettingDetailDialog extends StatelessWidget {
  final String title;
  final String? contentText;
  final String? detailText;

  const SettingDetailDialog(
      {super.key, required this.title, this.contentText, this.detailText});

  @override
  Widget build(BuildContext context) {
    return HJDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          if (contentText != null) ...[
            Text('当前选择: $contentText',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HJColors.textPrimary)),
            const SizedBox(height: 12)
          ],
          if (detailText != null)
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: HJColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.transparent)),
                child: SelectableText(detailText!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: HJColors.textSecondary,
                        height: 1.5))),
        ],
      ),
      primaryAction:
      HJButton.primary(text: '确定', onPressed: () => Navigator.pop(context)),
    );
  }
}