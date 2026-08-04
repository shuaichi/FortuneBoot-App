import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 管理类模块通用 ⋯ 菜单动作。
enum ManageMenuAction { edit, moveToRecycleBin, putBack, remove }

/// 弹出管理项操作菜单。
///
/// - [inRecycleBin] 为 true 时展示「移出回收站 / 彻底删除」；
///   否则展示「编辑 / 移入回收站」。
Future<ManageMenuAction?> showManageMenu(
  BuildContext context, {
  required bool inRecycleBin,
}) {
  return showModalBottomSheet<ManageMenuAction>(
    context: context,
    backgroundColor: FxColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: FxSpacing.sm),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FxColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: FxSpacing.sm),
            if (inRecycleBin) ...[
              _item(
                ctx,
                Icons.restore_rounded,
                '移出回收站',
                ManageMenuAction.putBack,
              ),
              _item(
                ctx,
                Icons.delete_forever_rounded,
                '彻底删除',
                ManageMenuAction.remove,
                danger: true,
              ),
            ] else ...[
              _item(ctx, Icons.edit_rounded, '编辑', ManageMenuAction.edit),
              _item(
                ctx,
                Icons.delete_outline_rounded,
                '移入回收站',
                ManageMenuAction.moveToRecycleBin,
              ),
            ],
            const SizedBox(height: FxSpacing.md),
          ],
        ),
      );
    },
  );
}

Widget _item(
  BuildContext context,
  IconData icon,
  String label,
  ManageMenuAction action, {
  bool danger = false,
}) {
  final color = danger ? FxColors.danger : FxColors.textPrimary;
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(label, style: FxTypography.body.copyWith(color: color)),
    onTap: () => Navigator.of(context).pop(action),
  );
}

/// 危险操作二次确认（回收站/删除通用）。返回 true 表示确认。
Future<bool?> confirmManageAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: FxColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: FxTypography.title),
              const SizedBox(height: FxSpacing.sm),
              Text(message, style: FxTypography.body),
              const SizedBox(height: FxSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _confirmBtn(
                      '取消',
                      onTap: () => Navigator.of(ctx).pop(false),
                      color: FxColors.surfaceMuted,
                      fg: FxColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: FxSpacing.md),
                  Expanded(
                    child: _confirmBtn(
                      confirmLabel,
                      onTap: () => Navigator.of(ctx).pop(true),
                      color: FxColors.danger,
                      fg: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _confirmBtn(
  String label, {
  required VoidCallback onTap,
  required Color color,
  required Color fg,
}) {
  return Material(
    color: color,
    borderRadius: FxRadius.tileBorder,
    child: InkWell(
      borderRadius: FxRadius.tileBorder,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        child: Text(label, style: FxTypography.bodyStrong.copyWith(color: fg)),
      ),
    ),
  );
}

/// 表单内通用开关行（标签 + Switch）。
class ManageSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ManageSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: FxTypography.body)),
          Switch.adaptive(
            value: value,
            activeColor: FxColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// 表单内通用字段标签。
class ManageFieldLabel extends StatelessWidget {
  final String text;
  const ManageFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(text, style: FxTypography.label),
  );
}

/// 表单文本框统一装饰。
InputDecoration manageInputDecoration(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: FxColors.surfaceMuted,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(
    horizontal: FxSpacing.md,
    vertical: FxSpacing.md,
  ),
  border: OutlineInputBorder(
    borderRadius: FxRadius.tileBorder,
    borderSide: BorderSide.none,
  ),
);
