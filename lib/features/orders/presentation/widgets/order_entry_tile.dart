import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据流水条目。
class OrderEntryTile extends StatelessWidget {
  final FinanceOrderEntry entry;
  final bool hideAmounts;
  final ValueChanged<FinanceOrderEntry>? onPreview;
  final ValueChanged<FinanceOrderEntry>? onEdit;
  final ValueChanged<FinanceOrderEntry>? onConfirm;
  final ValueChanged<FinanceOrderEntry>? onUnconfirm;
  final ValueChanged<FinanceOrderEntry>? onVoid;
  final ValueChanged<FinanceOrderEntry>? onRestore;

  const OrderEntryTile({
    super.key,
    required this.entry,
    required this.hideAmounts,
    this.onPreview,
    this.onEdit,
    this.onConfirm,
    this.onUnconfirm,
    this.onVoid,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final time = entry.tradeTime;
    return FxCard(
      onTap: () => onPreview?.call(entry),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.title ?? '',
                  style: FxTypography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FxMoneyText(
                amount: (entry.amount?.cents ?? 0) / 100,
                currencyCode: entry.currencyCode,
                masked: hideAmounts,
                showSign: true,
                colorBySign: true,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.xs),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.xs,
            children: [
              _tag(_componentLabel(context)),
              if (entry.accountName != null) _tag(entry.accountName!),
              if (!entry.confirm) _tag(S.of(context).ordersPendingConfirmation),
              if (entry.recycleBin) _tag(S.of(context).ordersVoided),
            ],
          ),
          if (time != null)
            Padding(
              padding: const EdgeInsets.only(top: FxSpacing.xs),
              child: Text(
                _format(time),
                style: FxTypography.caption.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_allowed('EDIT'))
                FxIconButton(
                  icon: Icons.edit_rounded,
                  tooltip: S.of(context).ordersEditEntry,
                  onPressed: () => onEdit?.call(entry),
                ),
              if (_allowed('CONFIRM'))
                FxIconButton(
                  icon: Icons.check_rounded,
                  tooltip: S.of(context).commonConfirm,
                  onPressed: () => onConfirm?.call(entry),
                ),
              if (_allowed('UNCONFIRM'))
                FxIconButton(
                  icon: Icons.undo_rounded,
                  tooltip: S.of(context).ordersUnconfirm,
                  onPressed: () => onUnconfirm?.call(entry),
                ),
              if (_allowed('VOID'))
                FxIconButton(
                  key: ValueKey('order-entry-void-${entry.billId}'),
                  icon: Icons.block_rounded,
                  tooltip: S.of(context).ordersVoid,
                  onPressed: () => onVoid?.call(entry),
                ),
              if (_allowed('RESTORE'))
                FxIconButton(
                  key: ValueKey('order-entry-restore-${entry.billId}'),
                  icon: Icons.restore_rounded,
                  tooltip: S.of(context).ordersRestore,
                  onPressed: () => onRestore?.call(entry),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _allowed(String action) => entry.allowedActions.contains(action);

  String _componentLabel(BuildContext context) =>
      switch (entry.orderComponent) {
        FinanceOrderComponent.principal =>
          S.of(context).ordersComponentPrincipal,
        FinanceOrderComponent.interest => S.of(context).ordersComponentInterest,
        FinanceOrderComponent.fee => S.of(context).ordersComponentFee,
        FinanceOrderComponent.writeOff => S.of(context).ordersComponentWriteOff,
        null => S.of(context).ordersComponentUnknown,
      };

  String _format(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  Widget _tag(String label) =>
      FxChip(label: label, selected: false, isAction: true, onTap: () {});
}
