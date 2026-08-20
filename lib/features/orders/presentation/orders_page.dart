import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据列表页（Routes.orders）。状态机按钮随状态显隐。
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrdersService _service = OrdersService();

  OrdersBloc get _bloc => context.read<OrdersBloc>();
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;
  String? get _currency => context.read<SessionCubit>().state.defaultCurrency;

  void _showToast(String message) {
    FxFeedback.info(context, message: message);
  }

  Future<void> _openForm({FortuneFinanceOrderVo? order}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).ordersSelectBookFirst);
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: order == null
          ? S.of(context).ordersAddTitle
          : S.of(context).ordersEditTitle,
      expand: true,
      child: OrderFormSheet(service: _service, bookId: bookId, order: order),
    );
    if (changed == true && mounted) _bloc.add(const OrdersMutated());
  }

  Future<void> _remove(FortuneFinanceOrderVo order) async {
    final bookId = _bookId;
    final orderId = order.orderId;
    if (bookId == null || orderId == null) return;
    final ok = await FxConfirmSheet.show(
      context,
      title: S.of(context).ordersRemoveTitle,
      message: S
          .of(context)
          .ordersRemoveMessage(order.title ?? S.of(context).ordersThisOrder),
      confirmLabel: S.of(context).ordersDelete,
      cancelLabel: S.of(context).commonCancel,
      destructive: true,
      failureMessage: S.of(context).profileSaveFailedRetry,
      onConfirm: () async {
        await _service.remove(bookId: bookId, orderId: orderId);
        return true;
      },
    );
    if (ok == true && mounted) _bloc.add(const OrdersMutated());
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    return _BookSync(
      bookId: bookId,
      child: Scaffold(
        backgroundColor: FxPalette.of(context).canvas,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<OrdersBloc, OrdersState>(
            listenWhen: (p, c) =>
                c.toastMessage != null && p.toastMessage != c.toastMessage,
            listener: (context, state) {
              final msg = state.toastMessage;
              if (msg != null) _showToast(msg);
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildBody(state, bookId)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(S.of(context).ordersTitle, style: FxTypography.title),
          ),
          FxIconButton(
            icon: Icons.add_rounded,
            tooltip: S.of(context).ordersAddTitle,
            onPressed: () => _openForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(OrdersState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).ordersSelectBookFirst);
    }
    switch (state.status) {
      case OrdersStatus.initial:
      case OrdersStatus.loading:
        return FxStateView.loading();
      case OrdersStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          retryLabel: S.of(context).commonRetry,
          onRetry: () => _bloc.add(const OrdersLoaded()),
        );
      case OrdersStatus.empty:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const OrdersLoaded()),
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: FxStateView.empty(
                  message: S.of(context).ordersEmpty,
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
        );
      case OrdersStatus.loaded:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const OrdersLoaded()),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.xxxl,
            ),
            itemCount: state.orders.length,
            separatorBuilder: (_, i) => const SizedBox(height: FxSpacing.md),
            itemBuilder: (context, i) => _orderCard(context, state.orders[i]),
          ),
        );
    }
  }

  Widget _orderCard(BuildContext context, FortuneFinanceOrderVo order) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return FxCard(
      onTap: () => _openForm(order: order),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: palette.primary,
                    ),
                    const SizedBox(width: FxSpacing.sm),
                    if ((order.typeDesc ?? '').isNotEmpty) ...[
                      _tag(order.typeDesc!, palette.info),
                      const SizedBox(width: FxSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        order.title ?? S.of(context).ordersUnnamedOrder,
                        style: FxTypography.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FxSpacing.sm),
                Wrap(
                  spacing: FxSpacing.md,
                  runSpacing: FxSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _amountInline(
                      context,
                      label: S.of(context).ordersOutLabel,
                      amount: order.outAmount ?? 0,
                      color: finance.expense,
                    ),
                    _amountInline(
                      context,
                      label: S.of(context).ordersInLabel,
                      amount: order.inAmount ?? 0,
                      color: finance.income,
                    ),
                  ],
                ),
                const SizedBox(height: FxSpacing.sm),
                if ((order.submitTime ?? '').isNotEmpty)
                  _timeText(
                    context,
                    S.of(context).ordersSubmitTime(order.submitTime!),
                  ),
                if ((order.closeTime ?? '').isNotEmpty) ...[
                  const SizedBox(height: FxSpacing.xs),
                  _timeText(
                    context,
                    S.of(context).ordersCloseTime(order.closeTime!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          _metaActionsColumn(context, order),
        ],
      ),
    );
  }

  Widget _amountInline(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) {
    final palette = FxPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
        FxMoneyText(
          amount: amount,
          currencyCode: _currency,
          fontSize: 13,
          color: color,
        ),
      ],
    );
  }

  Widget _timeText(BuildContext context, String text) {
    final palette = FxPalette.of(context);
    return Text(
      text,
      style: FxTypography.caption.copyWith(color: palette.textTertiary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _metaActionsColumn(BuildContext context, FortuneFinanceOrderVo order) {
    final chips = <Widget>[];
    if ((order.statusDesc ?? '').isNotEmpty) {
      chips.add(_tag(order.statusDesc!, _statusColor(context, order)));
    }
    chips.addAll(_actionButtons(context, order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0) const SizedBox(height: FxSpacing.sm),
          chips[i],
        ],
      ],
    );
  }

  Color _statusColor(BuildContext context, FortuneFinanceOrderVo order) {
    final palette = FxPalette.of(context);
    if (order.isUsing) return palette.success;
    if (order.isInitial) return palette.textTertiary;
    if (order.isClosed) return palette.textTertiary;
    return palette.textTertiary;
  }

  /// 状态机按钮：初始化→[使用]；使用中→[关闭]；已关闭→[重开]。附删除。
  List<Widget> _actionButtons(
    BuildContext context,
    FortuneFinanceOrderVo order,
  ) {
    final buttons = <Widget>[];
    final action = order.nextTransitionAction;
    if (action != null) {
      buttons.add(
        _miniButton(
          context,
          _transitionLabel(context, action),
          () {
            HapticFeedback.selectionClick();
            _bloc.add(OrderTransitioned(order: order, action: action.value));
          },
          color: _transitionColor(context, action),
        ),
      );
    }
    // 未知状态：不猜测流转按钮，仅保留删除，避免非法流转。
    buttons.add(
      _miniButton(
        context,
        S.of(context).ordersDelete,
        () => _remove(order),
        danger: true,
      ),
    );
    return buttons;
  }

  String _transitionLabel(
    BuildContext context,
    FinanceOrderTransitionAction action,
  ) {
    return switch (action) {
      FinanceOrderTransitionAction.using => S.of(context).ordersUse,
      FinanceOrderTransitionAction.close => S.of(context).ordersClose,
      FinanceOrderTransitionAction.reopen => S.of(context).ordersReopen,
    };
  }

  Color _transitionColor(
    BuildContext context,
    FinanceOrderTransitionAction action,
  ) {
    final palette = FxPalette.of(context);
    return switch (action) {
      FinanceOrderTransitionAction.using => palette.success,
      FinanceOrderTransitionAction.close => palette.warning,
      FinanceOrderTransitionAction.reopen => palette.info,
    };
  }

  Widget _miniButton(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    bool danger = false,
    Color? color,
  }) {
    final palette = FxPalette.of(context);
    final resolvedColor = color ?? (danger ? palette.danger : palette.primary);
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.md,
              vertical: FxSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: resolvedColor.withValues(alpha: 0.1),
              borderRadius: FxRadius.pillBorder,
            ),
            child: Text(
              label,
              style: FxTypography.label.copyWith(
                color: resolvedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(
        label,
        style: FxTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 把 SessionCubit 的 bookId 变化派发给 OrdersBloc。
class _BookSync extends StatefulWidget {
  final int? bookId;
  final Widget child;
  const _BookSync({required this.bookId, required this.child});

  @override
  State<_BookSync> createState() => _BookSyncState();
}

class _BookSyncState extends State<_BookSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrdersBloc>().add(OrdersBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<OrdersBloc>().add(OrdersBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
