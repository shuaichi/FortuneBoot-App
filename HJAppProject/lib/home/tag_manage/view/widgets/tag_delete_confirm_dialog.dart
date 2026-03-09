import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

class TagDeleteConfirmDialog extends StatefulWidget {
  final String tagName;
  final Future<void> Function() onConfirm;

  const TagDeleteConfirmDialog({
    Key? key,
    required this.tagName,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<TagDeleteConfirmDialog> createState() => _TagDeleteConfirmDialogState();
}

class _TagDeleteConfirmDialogState extends State<TagDeleteConfirmDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return HJDialog(
      title: '确认移入回收站？',
      headerIcon: Icons.warning_rounded,
      headerIconColor: HJColors.expense,
      content: Text(
        '您确定要将标签 "${widget.tagName}" 移入回收站吗？\n此操作可以在回收站中撤销。',
        style: const TextStyle(color: HJColors.textSecondary, fontSize: 15, height: 1.5),
      ),
      secondaryAction: HJButton.secondary(
          text: '取消',
          onPressed: _isLoading ? () {} : () => Navigator.of(context).pop(false)
      ),
      // 复用刚刚新加的 HJSubmitButton 能够携带 loading 态，如果不使用带 Loading 的可直接用 HJButton.critical
      primaryAction: _isLoading
          ? HJSubmitButton(text: '处理中...', isLoading: true, onPressed: (){})
          : HJButton.critical(text: '移入回收站', onPressed: _handleConfirm),
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: ${e.toString()}'), backgroundColor: HJColors.expense));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}