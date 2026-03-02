import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/hjds_components.dart';
import '../../../design_system/hjds_theme.dart';

class ApiInfoDialog extends StatelessWidget {
  final String? apiDetail;

  const ApiInfoDialog({super.key, required this.apiDetail});

  @override
  Widget build(BuildContext context) {
    final detail = apiDetail ?? '无内容';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('API 配置信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  detail,
                  style: HJTypography.tabularBody.copyWith(color: Colors.black87, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children:[
                Expanded(child: HJButton.secondary(text: '关闭', onPressed: () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(
                  child: HJButton.primary(
                    text: '复制',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: detail));
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}