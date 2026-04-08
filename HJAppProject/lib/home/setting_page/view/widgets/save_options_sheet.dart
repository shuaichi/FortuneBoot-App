import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fortuneboot/home/design_system/hjds_components.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

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
          children:[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: HJColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('操作',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HJColors.textPrimary)),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: HJColors.divider),
            if (kIsWeb)
              HJChevronItem(
                icon: Icons.download,
                iconColor: HJColors.primary,
                title: '下载图片',
                onTap: () async {
                  Navigator.pop(context);
                  await onDownloadOrSave();
                },
              )
            else ...[
              HJChevronItem(
                icon: Icons.save_alt,
                iconColor: HJColors.primary,
                title: '保存到相册',
                onTap: () async {
                  Navigator.pop(context);
                  await onDownloadOrSave();
                },
              ),
              HJValueItem(
                icon: Icons.info_outline,
                iconColor: HJColors.textSecondary,
                title: '说明',
                valueText: '如保存失败，请检查权限',
                onTap: () => Navigator.pop(context),
              ),
            ],
            HJChevronItem(
              icon: Icons.link,
              iconColor: HJColors.primary,
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
                  horizontal: HJSpacing.md, vertical: HJSpacing.md),
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