import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class ApiInfoDialog extends StatelessWidget {
  final String? apiDetail;

  const ApiInfoDialog({super.key, required this.apiDetail});

  @override
  Widget build(BuildContext context) {
    final detail = apiDetail ?? '无内容';
    return HJDialog(
      title: 'API 配置信息',
      headerIcon: Icons.api_rounded,
      headerIconColor: HJColors.primary,
      content: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: HJColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent)),
        child: SingleChildScrollView(
            child: SelectableText(detail,
                style: HJTypography.tabularBody
                    .copyWith(color: HJColors.textPrimary, height: 1.4))),
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
