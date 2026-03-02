import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

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
        children: [
          if (contentText != null) ...[
            Text('当前选择: $contentText',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
            const SizedBox(height: 8)
          ],
          if (detailText != null)
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[100]!)),
                child: Text(detailText!,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[700], height: 1.5))),
        ],
      ),
      primaryAction:
          HJButton.primary(text: '确定', onPressed: () => Navigator.pop(context)),
    );
  }
}
