import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// API 信息展示对话框 - Refactored for Design Skill
/// - Standard Dialog Style: White, Radius 16
/// - Handles text overflow
/// - Ensures text visibility
class ApiInfoDialog extends StatelessWidget {
  final String? apiDetail;

  const ApiInfoDialog({
    super.key,
    required this.apiDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = apiDetail ?? '无内容';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0, // Flat
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API 配置信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 200), // Limit height
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  detail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87, // Ensure visibility
                    height: 1.4,
                    fontFamily: 'Courier', // Monospace for technical info
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text('关闭'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: detail));
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已复制')),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  child: const Text('复制'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}