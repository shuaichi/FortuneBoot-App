import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class ApiInfoDialog extends StatelessWidget {
  final String? apiDetail;

  const ApiInfoDialog({super.key, required this.apiDetail});

  @override
  Widget build(BuildContext context) {
    final detail = apiDetail ?? '无内容';
    return HJDialog(
      title: 'API 配置信息',
      content: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!)),
        child: SingleChildScrollView(
            child: SelectableText(detail,
                style: HJTypography.tabularBody
                    .copyWith(color: Colors.black87, height: 1.4))),
      ),
      secondaryAction: HJButton.secondary(
          text: '关闭', onPressed: () => Navigator.pop(context)),
      primaryAction: HJButton.primary(
          text: '复制',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: detail));
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('已复制')));
            }
          }),
    );
  }
}
