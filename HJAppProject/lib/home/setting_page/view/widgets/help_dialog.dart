import 'package:flutter/material.dart';
import '../../../design_system/hjds_components.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

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
            Row(
              children:[
                Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 12),
                const Text('帮助说明', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '这里是应用的帮助与说明文档。\n\n1. 您可以在设置中切换账本和分组。\n2. 所有的更改都会同步到云端。\n3. 如遇问题，请尝试重新登录。',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: HJButton.primary(text: '我知道了', onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}