import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hjproject/home/design_system/hjds_components.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class SaveOptionsSheet extends StatelessWidget {
  final String assetPath;
  final String suggestedName;
  final Future<void> Function() onDownloadOrSave;
  final VoidCallback? onClose;

  const SaveOptionsSheet({
    super.key,
    required this.assetPath,
    required this.suggestedName,
    required this.onDownloadOrSave,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: HJSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('操作',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            if (kIsWeb)
              HJChevronItem(
                // ← 修复此处
                icon: Icons.download,
                title: '下载图片',
                onTap: () async {
                  Navigator.pop(context);
                  await onDownloadOrSave();
                },
              )
            else ...[
              HJChevronItem(
                // ← 修复此处
                icon: Icons.save_alt,
                title: '保存到相册',
                onTap: () async {
                  Navigator.pop(context);
                  await onDownloadOrSave();
                },
              ),
              HJValueItem(
                // ← 修复此处
                icon: Icons.info_outline,
                title: '说明',
                valueText: '如保存失败，请检查权限',
                onTap: () => Navigator.pop(context),
              ),
            ],
            HJChevronItem(
              // ← 修复此处
              icon: Icons.link,
              title: '复制资源路径',
              onTap: () {
                Clipboard.setData(ClipboardData(text: assetPath));
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('已复制')));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: HJSpacing.md, vertical: HJSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: HJButton.secondary(
                  text: '取消',
                  onPressed: () {
                    Navigator.pop(context);
                    onClose?.call();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
