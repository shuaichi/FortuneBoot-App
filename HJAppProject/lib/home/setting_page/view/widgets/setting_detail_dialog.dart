import 'package:flutter/material.dart';
import '../../../design_system/hjds_components.dart';

class SettingDetailDialog extends StatelessWidget {
  final String title;
  final String? contentText;
  final String? detailText;

  const SettingDetailDialog({super.key, required this.title, this.contentText, this.detailText});

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
          children:[
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            if (contentText != null) ...[
              Text('当前选择: $contentText', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 8),
            ],
            if (detailText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[100]!)),
                child: Text(detailText!, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: HJButton.primary(text: '确定', onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}