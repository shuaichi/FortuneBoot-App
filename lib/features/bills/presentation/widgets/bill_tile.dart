import 'package:flutter/material.dart';
import 'package:fortuneboot/core/icon/fx_icon_badge.dart';
import 'package:fortuneboot/core/icon/smart_category_engine.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

enum BillTileAction { copy, toggleConfirm, delete }

/// 单条账单行：左图标徽标 + 标题/副行，右金额/时间/附件/标签。
class BillTile extends StatelessWidget {
  final FortuneBillVo bill;
  final VoidCallback? onTap;
  final ValueChanged<BillTileAction>? onAction;
  final bool masked;

  const BillTile({
    super.key,
    required this.bill,
    this.onTap,
    this.onAction,
    this.masked = false,
  });

  BillIconInput get _iconInput => BillIconInput(
    billType: bill.billType,
    title: bill.title,
    payeeName: bill.payeeName,
    remark: bill.remark,
    accountName: bill.accountName,
    categoryNames: bill.categoryNamesByAmount,
    tagNames: bill.tagList
        .map((t) => t.tagName ?? '')
        .where((s) => s.isNotEmpty)
        .toList(),
    toAccountId: bill.toAccountId,
  );

  String _titleOf(BuildContext context) {
    final t = bill.title;
    if (t != null && t.isNotEmpty) return t;
    final cat = bill.primaryCategoryName;
    if (cat.isNotEmpty) return cat;
    return FxBillType.fromValue(bill.billType)?.localizedLabel(context) ??
        S.of(context).billTypeFallback;
  }

  /// 副行：转账显"转出 → 转入",其余显账户名(+ 主分类)。
  String get _subtitle {
    if (bill.billType == FxBillType.transfer.value) {
      final from = bill.accountName ?? '';
      final to = bill.toAccountName ?? '';
      return '$from → $to';
    }
    final parts = <String>[];
    final cat = bill.primaryCategoryName;
    if (cat.isNotEmpty) parts.add(cat);
    if (bill.accountName != null && bill.accountName!.isNotEmpty) {
      parts.add(bill.accountName!);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final tags = bill.tagList
        .map((t) => t.tagName ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.lg,
          vertical: FxSpacing.md,
        ),
        child: Row(
          children: [
            FxIconBadge.forBill(_iconInput),
            const SizedBox(width: FxSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _titleOf(context),
                          style: FxTypography.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bill.hasFile) ...[
                        const SizedBox(width: FxSpacing.xs),
                        Icon(
                          Icons.attach_file_rounded,
                          size: 14,
                          color: palette.textTertiary,
                        ),
                      ],
                      if (!bill.confirm) ...[
                        const SizedBox(width: FxSpacing.xs),
                        _flagDot(
                          S.of(context).billsPendingConfirm,
                          palette.warning,
                        ),
                      ],
                    ],
                  ),
                  if (_subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      style: FxTypography.caption.copyWith(
                        color: FxPalette.of(context).textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: FxSpacing.xs),
                    Wrap(
                      spacing: FxSpacing.xs,
                      runSpacing: FxSpacing.xs,
                      children: [
                        ...tags.take(3).map((tag) => FxTagChip(label: tag)),
                        if (tags.length > 3)
                          FxTagChip(label: '+${tags.length - 3}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: FxSpacing.sm),
            if (onAction != null)
              PopupMenuButton<BillTileAction>(
                tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                onSelected: onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: BillTileAction.copy,
                    child: Text(S.of(context).billsCopy),
                  ),
                  PopupMenuItem(
                    value: BillTileAction.toggleConfirm,
                    child: Text(
                      bill.confirm
                          ? S.of(context).billsUnconfirm
                          : S.of(context).confirm,
                    ),
                  ),
                  PopupMenuItem(
                    value: BillTileAction.delete,
                    child: Text(S.of(context).billsDelete),
                  ),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FxMoneyText(
                  amount: bill.displayAmount,
                  currencyCode: bill.currencyCode,
                  billType: bill.billType,
                  showSign: true,
                  masked: masked,
                ),
                if (bill.tradeTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.Hm(
                      Localizations.localeOf(context).toString(),
                    ).format(bill.tradeTime!),
                    style: FxTypography.caption.copyWith(
                      color: FxPalette.of(context).textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _flagDot(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: FxTypography.caption.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
