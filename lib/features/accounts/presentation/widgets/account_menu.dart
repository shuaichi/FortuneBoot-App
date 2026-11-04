import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账户 ⋯ 菜单动作。
enum AccountMenuAction { edit, adjustBalance, moveToRecycleBin, remove }

/// 弹出账户操作菜单（编辑 / 调整余额 / 移入回收站 / 删除）。
/// [canAdjust] 为 false 时禁用"调整余额"（无 bookId）。
Future<AccountMenuAction?> showAccountMenu(
  BuildContext context, {
  required bool canAdjust,
}) {
  return FxSheet.show<AccountMenuAction>(
    context,
    title: S.of(context).commonMoreActions,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _item(
          context,
          Icons.edit_rounded,
          S.of(context).accountsEditTitle,
          AccountMenuAction.edit,
        ),
        _item(
          context,
          Icons.tune_rounded,
          canAdjust
              ? S.of(context).accountsAdjustBalance
              : S.of(context).accountsAdjustBalanceNeedBook,
          AccountMenuAction.adjustBalance,
          enabled: canAdjust,
        ),
        _item(
          context,
          Icons.delete_outline_rounded,
          S.of(context).accountsMoveToRecycleBinTitle,
          AccountMenuAction.moveToRecycleBin,
        ),
        _item(
          context,
          Icons.delete_forever_rounded,
          S.of(context).accountsDeletePermanently,
          AccountMenuAction.remove,
          danger: true,
        ),
      ],
    ),
  );
}

Widget _item(
  BuildContext context,
  IconData icon,
  String label,
  AccountMenuAction action, {
  bool danger = false,
  bool enabled = true,
}) {
  final palette = FxPalette.of(context);
  final color = danger ? palette.danger : palette.textPrimary;
  return Opacity(
    opacity: enabled ? 1 : 0.4,
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: FxTypography.body.copyWith(color: color)),
      onTap: enabled ? () => Navigator.of(context).pop(action) : null,
    ),
  );
}

/// 危险操作二次确认（回收站/删除通用）。返回 true 表示确认。
Future<bool?> confirmDangerAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return FxConfirmSheet.show(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: S.of(context).commonCancel,
    destructive: true,
    onConfirm: () async => true,
  );
}
