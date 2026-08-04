import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 账户 ⋯ 菜单动作。
enum AccountMenuAction { edit, adjustBalance, moveToRecycleBin, remove }

/// 弹出账户操作菜单（编辑 / 调整余额 / 移入回收站 / 删除）。
/// [canAdjust] 为 false 时禁用"调整余额"（无 bookId）。
Future<AccountMenuAction?> showAccountMenu(
  BuildContext context, {
  required bool canAdjust,
}) {
  return showModalBottomSheet<AccountMenuAction>(
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
            _item(ctx, Icons.edit_rounded, '编辑账户', AccountMenuAction.edit),
            _item(
              ctx,
              Icons.tune_rounded,
              canAdjust ? '调整余额' : '调整余额（需先选账本）',
              AccountMenuAction.adjustBalance,
              enabled: canAdjust,
            ),
            _item(
              ctx,
              Icons.delete_outline_rounded,
              '移入回收站',
              AccountMenuAction.moveToRecycleBin,
            ),
            _item(
              ctx,
              Icons.delete_forever_rounded,
              '彻底删除',
              AccountMenuAction.remove,
              danger: true,
            ),
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
                    child: _btn(
                      '取消',
                      onTap: () => Navigator.of(ctx).pop(false),
                      color: FxPalette.of(ctx).surfaceMuted,
                      fg: FxPalette.of(ctx).textSecondary,
                    ),
                  ),
                  const SizedBox(width: FxSpacing.md),
                  Expanded(
                    child: _btn(
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

Widget _btn(
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
