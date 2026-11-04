import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_action_sheet.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_audit_sheet.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_entry_tile.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_form_sheet.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_summary_strip.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据详情页。所有网络调用在 Bloc/Service 中完成。
class OrderDetailPage extends StatefulWidget {
  final OrdersService service;
  final int bookId;
  final int orderId;
  final Future<bool> Function(BillEditorArgs args)? editorLauncher;

  const OrderDetailPage({
    super.key,
    required this.service,
    required this.bookId,
    required this.orderId,
    this.editorLauncher,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailBloc _bloc;
  late final BillDetailFlow _detailFlow = BillDetailFlow();

  @override
  void initState() {
    super.initState();
    _bloc = OrderDetailBloc(
      bookId: widget.bookId,
      orderId: widget.orderId,
      service: widget.service,
    )..add(const OrderDetailLoaded());
    BillMutations.revision.addListener(_onExternalMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onExternalMutation);
    _bloc.close();
    super.dispose();
  }

  void _onExternalMutation() {
    if (mounted) _bloc.add(const OrderDetailRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hideAmounts = context.select<PreferencesCubit, bool>(
      (cubit) => cubit.state.dashboard.hideAmounts,
    );
    return BlocProvider<OrderDetailBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: palette.canvas,
        body: SafeArea(
          child: BlocConsumer<OrderDetailBloc, OrderDetailState>(
            listener: _listenState,
            builder: (context, state) {
              if (state.status == OrderDetailStatus.loading ||
                  state.status == OrderDetailStatus.initial) {
                return FxStateView.loading();
              }
              if (state.status == OrderDetailStatus.error ||
                  state.detail == null) {
                return FxStateView.error(
                  message: state.errorMessage,
                  onRetry: () => _bloc.add(const OrderDetailRefreshed()),
                  retryLabel: S.of(context).commonRetry,
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(const OrderDetailRefreshed());
                  await _bloc.stream.firstWhere(
                    (state) => state.status != OrderDetailStatus.loading,
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    FxSpacing.lg,
                    FxSpacing.lg,
                    FxSpacing.lg,
                    FxSpacing.xxxl,
                  ),
                  children: [
                    _header(context, state),
                    const SizedBox(height: FxSpacing.md),
                    OrderSummaryStrip(
                      summary: state.summary,
                      currencyCode: state.detail!.currencyCode,
                      hideAmounts: hideAmounts,
                    ),
                    const SizedBox(height: FxSpacing.md),
                    _amountBreakdown(context, state.detail!, hideAmounts),
                    const SizedBox(height: FxSpacing.md),
                    _actions(context, state),
                    const SizedBox(height: FxSpacing.md),
                    _entryFilter(context, state),
                    const SizedBox(height: FxSpacing.sm),
                    ..._entryTiles(context, state, hideAmounts),
                    if (state.loadingMore)
                      const Padding(
                        padding: EdgeInsets.all(FxSpacing.md),
                        child: CircularProgressIndicator(),
                      )
                    else if (state.loadMoreError != null)
                      ListTile(
                        title: Text(state.loadMoreError!),
                        trailing: Text(S.of(context).commonRetry),
                        onTap: () =>
                            _bloc.add(const OrderDetailLoadMoreRequested()),
                      )
                    else if (state.hasMore)
                      FxButton.tonal(
                        label: S.of(context).ordersLoadMore,
                        onPressed: () =>
                            _bloc.add(const OrderDetailLoadMoreRequested()),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _listenState(BuildContext context, OrderDetailState state) {
    if (state.removed) {
      // 删除成功后直接返回列表页，避免展示已删除单据的错误视图。
      Navigator.of(context).maybePop();
      return;
    }
    final message = state.toastMessage;
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _header(BuildContext context, OrderDetailState state) {
    final detail = state.detail!;
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Text(
                detail.title ?? '',
                style: FxTypography.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _moreActionsMenu(context, detail),
          ],
        ),
        const SizedBox(height: FxSpacing.md),
        FxMoneyText(
          amount: (detail.pendingAmount?.cents ?? 0) / 100,
          currencyCode: detail.currencyCode,
          fontSize: 28,
        ),
        const SizedBox(height: FxSpacing.xs),
        Text(
          _pendingLabel(context, detail),
          style: FxTypography.body.copyWith(color: palette.textSecondary),
        ),
        if (detail.settlementState == 'SETTLED' ||
            detail.settlementState == 'PARTIAL') ...[
          const SizedBox(height: FxSpacing.xs),
          FxChip(
            label: detail.settlementState == 'SETTLED'
                ? S.of(context).ordersSettledTag
                : S.of(context).ordersPartiallySettled,
            selected: detail.settlementState == 'SETTLED',
            isAction: true,
            onTap: () {},
          ),
        ],
      ],
    );
  }

  /// 元数据编辑、差额结清、审计、归档、重开、删除统一收进“更多操作”菜单。
  /// 契约 C10：详情主按钮只放业务动作，其余入口进更多菜单，图标不裸奔。
  Widget _moreActionsMenu(BuildContext context, FinanceOrderDetail detail) {
    final l10n = S.of(context);
    return PopupMenuButton<String>(
      key: const ValueKey('order-more'),
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: l10n.ordersMoreActions,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _editMetadata();
          case 'writeOff':
            _confirmWriteOff();
          case 'audit':
            OrderAuditSheet.show(
              context,
              service: widget.service,
              bookId: widget.bookId,
              orderId: widget.orderId,
            );
          case 'close':
            _confirmClose();
          case 'reopen':
            _confirmReopen();
          case 'delete':
            _confirmDelete();
        }
      },
      itemBuilder: (context) => [
        if (detail.canEdit)
          PopupMenuItem(
            key: const ValueKey('order-edit-metadata'),
            value: 'edit',
            child: Text(l10n.ordersEditMetadata),
          ),
        if (detail.allowedEntryActions.contains('WRITE_OFF'))
          PopupMenuItem(
            key: const ValueKey('order-write-off'),
            value: 'writeOff',
            child: Text(l10n.ordersWriteOff),
          ),
        PopupMenuItem(
          key: const ValueKey('order-audit'),
          value: 'audit',
          child: Text(l10n.ordersAuditTitle),
        ),
        if (detail.canClose)
          PopupMenuItem(
            key: const ValueKey('order-archive'),
            value: 'close',
            child: Text(l10n.ordersArchive),
          ),
        if (detail.canReopen)
          PopupMenuItem(
            key: const ValueKey('order-reopen'),
            value: 'reopen',
            child: Text(l10n.ordersReopen),
          ),
        if (detail.canDelete)
          PopupMenuItem(
            key: const ValueKey('order-delete'),
            value: 'delete',
            child: Text(l10n.ordersDelete),
          ),
      ],
    );
  }

  Widget _amountBreakdown(
    BuildContext context,
    FinanceOrderDetail detail,
    bool hideAmounts,
  ) {
    return FxCard(
      child: Column(
        children: [
          _amountRow(
            context,
            label: S.of(context).ordersIssuedAmount,
            money: detail.issuedAmount,
            currencyCode: detail.currencyCode,
            hideAmounts: hideAmounts,
          ),
          _amountRow(
            context,
            label: S.of(context).ordersSettledAmount,
            money: detail.settledAmount,
            currencyCode: detail.currencyCode,
            hideAmounts: hideAmounts,
          ),
          _amountRow(
            context,
            label: S.of(context).ordersAdjustedAmount,
            money: detail.adjustedAmount,
            currencyCode: detail.currencyCode,
            hideAmounts: hideAmounts,
          ),
          const Divider(height: FxSpacing.lg),
          _amountRow(
            context,
            label: S.of(context).ordersInterestIncome,
            money: detail.interestIncome,
            currencyCode: detail.currencyCode,
            hideAmounts: hideAmounts,
          ),
          _amountRow(
            context,
            label: S.of(context).ordersInterestExpense,
            money: detail.interestExpense,
            currencyCode: detail.currencyCode,
            hideAmounts: hideAmounts,
          ),
          _amountRow(
            context,
            label: S.of(context).ordersFeeAmount,
            money: detail.feeAmount,
            currencyCode: detail.currencyCode,
            hideAmounts: hideAmounts,
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
    BuildContext context, {
    required String label,
    required OrderMoney? money,
    required String? currencyCode,
    required bool hideAmounts,
  }) {
    final cents = money?.cents;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (cents == null)
            Text(S.of(context).ordersAmountUnknown)
          else
            FxMoneyText(
              amount: cents / 100,
              currencyCode: currencyCode,
              masked: hideAmounts,
            ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, OrderDetailState state) {
    final detail = state.detail!;
    final actions = _visibleActions(detail);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actions.isNotEmpty)
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: [
              for (final action in actions.take(2))
                FxButton(
                  label: _actionLabel(context, action),
                  onPressed: () => _openEditor(action: action),
                ),
            ],
          ),
        if (detail.isReviewRequired ||
            detail.readOnlyReason?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: FxSpacing.sm),
            child: Text(
              _readOnlyReasonLabel(context, detail),
              style: FxTypography.body.copyWith(
                color: FxPalette.of(context).textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  /// 服务端可能直接回枚举值（如 REVIEW_REQUIRED），转成可读说明。
  String _readOnlyReasonLabel(BuildContext context, FinanceOrderDetail detail) {
    final s = S.of(context);
    final raw = detail.readOnlyReason?.trim();
    if (detail.isReviewRequired || raw == 'REVIEW_REQUIRED') {
      return s.ordersReviewRequiredHint;
    }
    return raw ?? '';
  }

  Widget _entryFilter(BuildContext context, OrderDetailState state) {
    return Wrap(
      spacing: FxSpacing.sm,
      children: [
        for (final status in const ['ACTIVE', 'VOIDED', 'ALL'])
          FxChip(
            label: _entryStatusLabel(context, status),
            selected: status == state.entryStatus,
            onTap: () => _bloc.add(OrderDetailEntryStatusChanged(status)),
          ),
      ],
    );
  }

  List<Widget> _entryTiles(
    BuildContext context,
    OrderDetailState state,
    bool hideAmounts,
  ) {
    if (state.entries.isEmpty) {
      return [
        SizedBox(
          height: 240,
          child: FxStateView.empty(message: S.of(context).ordersEntriesEmpty),
        ),
      ];
    }
    return [
      FxListSection(
        dividerIndent: FxSpacing.lg,
        children: [
          for (final entry in state.entries)
            OrderEntryTile(
              entry: entry,
              hideAmounts: hideAmounts,
              onPreview: _previewEntry,
              onEdit: (entry) => _openEntryEditor(entry),
              onConfirm: (entry) =>
                  _entryAction(entry, FinanceOrderEntryAction.confirm),
              onUnconfirm: (entry) =>
                  _entryAction(entry, FinanceOrderEntryAction.unconfirm),
              onVoid: (entry) => _confirmVoid(entry),
              onRestore: (entry) => _confirmRestore(entry),
            ),
        ],
      ),
    ];
  }

  List<FinanceOrderEntryActionKind> _visibleActions(FinanceOrderDetail detail) {
    final pending = detail.pendingAmount?.cents ?? 0;
    return OrderActionSheet.actions(detail).where((action) {
      if (!detail.allowedEntryActions.contains(action.code)) return false;
      if (pending <= 0) {
        return switch (action) {
          FinanceOrderEntryActionKind.loanRecover ||
          FinanceOrderEntryActionKind.reimburse ||
          FinanceOrderEntryActionKind.loanRepay => false,
          _ => true,
        };
      }
      return true;
    }).toList();
  }

  Future<bool> _openEditor({
    FinanceOrderEntryActionKind? action,
    FinanceOrderComponent component = FinanceOrderComponent.principal,
    FinanceOrderEntry? entry,
  }) async {
    final state = _bloc.state;
    final detail = state.detail;
    if (detail == null) return false;
    // 差额结清的 billType 由单据类型决定：债务单是收入（2），其余是支出（1）。
    final billType =
        action?.billType ??
        entry?.billType ??
        (component == FinanceOrderComponent.writeOff &&
                detail.type == FinanceOrderType.payable
            ? 2
            : 1);
    // 契约 C10：结算动作的默认金额为当前待结清金额。
    final settlePrefill =
        entry == null &&
        (action == FinanceOrderEntryActionKind.loanRecover ||
            action == FinanceOrderEntryActionKind.loanRepay ||
            action == FinanceOrderEntryActionKind.reimburse ||
            component == FinanceOrderComponent.writeOff);
    final args = BillEditorArgs(
      mode: entry == null ? 'new' : 'edit',
      billId: entry?.billId,
      sourceBill: entry?.toBillVo(),
      presetBillType: billType,
      presetBookId: widget.bookId,
      presetOrderId: widget.orderId,
      presetOrderComponent: entry?.orderComponent ?? component,
      expectedOrderVersion: detail.version,
      lockOrderContext: true,
      presetAmountCents: settlePrefill ? detail.pendingAmount?.cents : null,
    );
    final launcher = widget.editorLauncher ?? _routeEditor;
    final changed = await launcher(args);
    if (changed) {
      BillMutations.bump();
      _bloc.add(const OrderDetailRefreshed());
    }
    return changed;
  }

  Future<bool> _routeEditor(BillEditorArgs args) async {
    final result = await AppRouter.push<bool>(
      context,
      Routes.billEditor,
      args: {
        'mode': args.mode,
        'billId': args.billId,
        'bill': args.sourceBill,
        'presetBillType': args.presetBillType,
        'presetBookId': args.presetBookId,
        'presetOrderId': args.presetOrderId,
        'presetOrderComponent': args.presetOrderComponent?.value,
        'expectedOrderVersion': args.expectedOrderVersion,
        'lockOrderContext': args.lockOrderContext,
        'presetAmountCents': args.presetAmountCents,
      },
    );
    return result == true;
  }

  Future<void> _openEntryEditor(FinanceOrderEntry entry) async {
    await _openEditor(entry: entry);
  }

  void _previewEntry(FinanceOrderEntry entry) {
    _detailFlow.show(context, bookId: widget.bookId, bill: entry.toBillVo());
  }

  Future<void> _editMetadata() async {
    final detail = _bloc.state.detail;
    if (detail == null) return;
    final key = GlobalKey<OrderFormSheetState>();
    final typeLabel = switch (detail.type) {
      FinanceOrderType.receivable => S.of(context).ordersTypeReceivable,
      FinanceOrderType.payable => S.of(context).ordersTypePayable,
      FinanceOrderType.reimbursement => S.of(context).ordersTypeReimbursement,
      null => S.of(context).ordersTypeReimbursement,
    };
    await FxSheet.show<FinanceOrderMutationResult>(
      context,
      title: S.of(context).ordersEditTitle(typeLabel),
      expand: true,
      child: OrderFormSheet(
        key: key,
        service: widget.service,
        bookId: widget.bookId,
        order: detail,
      ),
    );
    _bloc.add(const OrderDetailRefreshed());
  }

  Future<void> _confirmWriteOff() async {
    final detail = _bloc.state.detail;
    if (detail == null) return;
    final confirmed = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersWriteOffConfirmTitle,
      message:
          '${S.of(context).ordersWriteOffConfirmMessage(_moneyText(detail.pendingAmount))}\n${S.of(context).ordersWriteOffNoCashChange}',
      confirmLabel: S.of(context).commonConfirm,
      cancelLabel: S.of(context).commonCancel,
      onConfirm: () async => true,
    );
    if (confirmed != true) return;
    await _openEditor(component: FinanceOrderComponent.writeOff);
  }

  Future<void> _confirmVoid(FinanceOrderEntry entry) async {
    final confirmed = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersVoidConfirmTitle,
      message: entry.orderComponent == FinanceOrderComponent.writeOff
          ? S.of(context).ordersVoidNoCashChange
          : S.of(context).ordersVoidCashRollback(_moneyText(entry.amount)),
      confirmLabel: S.of(context).commonConfirm,
      cancelLabel: S.of(context).commonCancel,
      onConfirm: () async => true,
    );
    if (confirmed != true) return;
    _bloc.add(
      OrderDetailEntryActionRequested(
        entry: entry,
        action: FinanceOrderEntryAction.voidEntry,
      ),
    );
  }

  Future<void> _confirmRestore(FinanceOrderEntry entry) async {
    final confirmed = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersRestoreConfirmTitle,
      message: S.of(context).ordersRestoreConfirmMessage,
      confirmLabel: S.of(context).commonConfirm,
      cancelLabel: S.of(context).commonCancel,
      onConfirm: () async => true,
    );
    if (confirmed != true) return;
    _bloc.add(
      OrderDetailEntryActionRequested(
        entry: entry,
        action: FinanceOrderEntryAction.restore,
      ),
    );
  }

  Future<void> _entryAction(
    FinanceOrderEntry entry,
    FinanceOrderEntryAction action,
  ) async {
    _bloc.add(OrderDetailEntryActionRequested(entry: entry, action: action));
  }

  Future<void> _confirmClose() async {
    final confirmed = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersArchiveConfirmTitle,
      message: S.of(context).ordersArchiveConfirmMessage,
      confirmLabel: S.of(context).ordersArchive,
      cancelLabel: S.of(context).commonCancel,
      onConfirm: () async => true,
    );
    if (confirmed == true) {
      _bloc.add(const OrderDetailTransitionRequested('close'));
    }
  }

  Future<void> _confirmReopen() async {
    final confirmed = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersReopenConfirmTitle,
      message: S.of(context).ordersReopenConfirmMessage,
      confirmLabel: S.of(context).ordersReopen,
      cancelLabel: S.of(context).commonCancel,
      onConfirm: () async => true,
    );
    if (confirmed == true) {
      _bloc.add(const OrderDetailTransitionRequested('reopen'));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersRemoveTitle,
      message: S.of(context).ordersDeleteOnlyEmptyMessage,
      confirmLabel: S.of(context).ordersDelete,
      cancelLabel: S.of(context).commonCancel,
      destructive: true,
      onConfirm: () async => true,
    );
    if (confirmed == true) {
      _bloc.add(const OrderDetailTransitionRequested('remove'));
    }
  }

  String _pendingLabel(BuildContext context, FinanceOrderDetail detail) =>
      switch (detail.type) {
        FinanceOrderType.receivable => S.of(context).ordersPendingReceivable,
        FinanceOrderType.payable => S.of(context).ordersPendingPayable,
        FinanceOrderType.reimbursement =>
          S.of(context).ordersPendingReimbursement,
        null => '',
      };

  String _actionLabel(
    BuildContext context,
    FinanceOrderEntryActionKind action,
  ) => switch (action) {
    FinanceOrderEntryActionKind.advance => S.of(context).ordersActionAdvance,
    FinanceOrderEntryActionKind.reimburse =>
      S.of(context).ordersActionReimburse,
    FinanceOrderEntryActionKind.loanOut => S.of(context).ordersActionLoanOut,
    FinanceOrderEntryActionKind.loanRecover =>
      S.of(context).ordersActionLoanRecover,
    FinanceOrderEntryActionKind.loanIn => S.of(context).ordersActionLoanIn,
    FinanceOrderEntryActionKind.loanRepay =>
      S.of(context).ordersActionLoanRepay,
    FinanceOrderEntryActionKind.interestIn =>
      S.of(context).ordersActionInterestIn,
    FinanceOrderEntryActionKind.interestOut =>
      S.of(context).ordersActionInterestOut,
    FinanceOrderEntryActionKind.fee => S.of(context).ordersActionFee,
  };

  String _entryStatusLabel(BuildContext context, String status) =>
      switch (status) {
        'VOIDED' => S.of(context).ordersVoided,
        'ALL' => S.of(context).ordersAllEntries,
        _ => S.of(context).ordersActiveEntries,
      };

  String _moneyText(OrderMoney? money) => money == null
      ? S.of(context).ordersAmountUnknown
      : (money.cents / 100).toStringAsFixed(2);
}
