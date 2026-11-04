import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_ledger_row.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据流水条目。
class OrderEntryTile extends StatelessWidget {
  /// 入账方向的流水类型：2收入、8报销到账、10收回本金、11借入。
  /// 其余（1/4/7/9/12）按出账方向处理。
  static const Set<int> _incomeBillTypes = {2, 8, 10, 11};

  /// 统一现金方向签名：入账为正、出账为负。颜色语义由 billType 决定，
  /// 与账单列表共用同一套“入账/出账遵从用户偏好”的颜色规则。
  static double signedAmount(FinanceOrderEntry entry) {
    final cents = entry.amount?.cents ?? 0;
    final sign = _incomeBillTypes.contains(entry.billType) ? 1 : -1;
    return sign * cents / 100;
  }

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
    final time = entry.tradeTime;
    final metadata = <String>[
      _componentLabel(context),
      if (entry.accountName?.isNotEmpty == true) entry.accountName!,
      if (!entry.confirm) S.of(context).ordersPendingConfirmation,
      if (entry.recycleBin) S.of(context).ordersVoided,
      if (time != null) _format(time),
    ];
    return FxLedgerRow(
      title: entry.title ?? '',
      subtitle: metadata.join(' · '),
      onTap: onPreview == null ? null : () => onPreview!(entry),
      amount: FxMoneyText(
        amount: signedAmount(entry),
        currencyCode: entry.currencyCode,
        billType: entry.billType,
        masked: hideAmounts,
        showSign: true,
        compactWhenNeeded: true,
      ),
      actions: [
        if (_allowed('EDIT'))
          FxIconButton(
            icon: Icons.edit_outlined,
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
}
