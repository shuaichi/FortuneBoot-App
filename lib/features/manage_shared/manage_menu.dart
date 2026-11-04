import 'package:flutter/material.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
  return FxSheet.show<ManageMenuAction>(
    context,
    title: S.of(context).commonMoreActions,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (inRecycleBin) ...[
          _item(
            context,
            Icons.restore_rounded,
            S.of(context).manageSharedPutBack,
            ManageMenuAction.putBack,
          ),
          _item(
            context,
            Icons.delete_forever_rounded,
            S.of(context).manageSharedDeleteForever,
            ManageMenuAction.remove,
            danger: true,
          ),
        ] else ...[
          _item(
            context,
            Icons.edit_rounded,
            S.of(context).manageSharedEdit,
            ManageMenuAction.edit,
          ),
          _item(
            context,
            Icons.delete_outline_rounded,
            S.of(context).manageSharedMoveToRecycleBin,
            ManageMenuAction.moveToRecycleBin,
          ),
        ],
      ],
    ),
  );
}

Widget _item(
  BuildContext context,
  IconData icon,
  String label,
  ManageMenuAction action, {
  bool danger = false,
}) {
  final palette = FxPalette.of(context);
  final color = danger ? palette.danger : palette.textPrimary;
  return Semantics(
    button: true,
    label: label,
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: FxTypography.body.copyWith(color: color)),
      onTap: () => Navigator.of(context).pop(action),
    ),
  );
}

/// 危险操作二次确认（回收站/删除通用）。返回 true 表示确认。
Future<bool> confirmManageAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String objectName,
}) {
  return DestructiveConfirmSheet.show(
    context,
    title: title,
    message: message,
    nameToMatch: objectName,
    checkboxLabel: S.of(context).booksDefaultDestructiveCheckbox,
    confirmLabel: confirmLabel,
    cancelLabel: S.of(context).commonCancel,
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
            activeColor: FxPalette.of(context).primary,
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
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );
}

/// 表单文本框统一装饰。
InputDecoration manageInputDecoration(BuildContext context, String hint) =>
    InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: FxPalette.of(context).surfaceMuted,
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
