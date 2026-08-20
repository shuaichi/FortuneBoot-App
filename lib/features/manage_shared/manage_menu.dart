import 'package:flutter/material.dart';
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
  return showModalBottomSheet<ManageMenuAction>(
    context: context,
    backgroundColor: FxPalette.of(context).surface,
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
                  color: FxPalette.of(ctx).border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: FxSpacing.sm),
            if (inRecycleBin) ...[
              _item(
                ctx,
                Icons.restore_rounded,
                S.of(ctx).manageSharedPutBack,
                ManageMenuAction.putBack,
              ),
              _item(
                ctx,
                Icons.delete_forever_rounded,
                S.of(ctx).manageSharedDeleteForever,
                ManageMenuAction.remove,
                danger: true,
              ),
            ] else ...[
              _item(
                ctx,
                Icons.edit_rounded,
                S.of(ctx).manageSharedEdit,
                ManageMenuAction.edit,
              ),
              _item(
                ctx,
                Icons.delete_outline_rounded,
                S.of(ctx).manageSharedMoveToRecycleBin,
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
Future<bool?> confirmManageAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: FxPalette.of(context).surface,
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
                      S.of(ctx).commonCancel,
                      onTap: () => Navigator.of(ctx).pop(false),
                      color: FxPalette.of(ctx).surfaceMuted,
                      fg: FxPalette.of(ctx).textSecondary,
                    ),
                  ),
                  const SizedBox(width: FxSpacing.md),
                  Expanded(
                    child: _confirmBtn(
                      confirmLabel,
                      onTap: () => Navigator.of(ctx).pop(true),
                      color: FxPalette.of(ctx).danger,
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
  return Semantics(
    button: true,
    label: label,
    child: Material(
      color: color,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: FxTypography.bodyStrong.copyWith(color: fg),
          ),
        ),
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
