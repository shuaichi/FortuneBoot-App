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
              Expanded(
                child: Text(
                  order.title ?? S.of(context).ordersUnnamedOrder,
                  style: FxTypography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((order.typeDesc ?? '').isNotEmpty)
                _tag(order.typeDesc!, palette.info),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Row(
            children: [
              Text(
                S.of(context).ordersOutLabel,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              FxMoneyText(
                amount: order.outAmount ?? 0,
                currencyCode: _currency,
                fontSize: 13,
                color: finance.expense,
              ),
              const SizedBox(width: FxSpacing.md),
              Text(
                S.of(context).ordersInLabel,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              FxMoneyText(
                amount: order.inAmount ?? 0,
                currencyCode: _currency,
                fontSize: 13,
                color: finance.income,
              ),
              const Spacer(),
              if ((order.statusDesc ?? '').isNotEmpty)
                _tag(
                  order.statusDesc!,
                  order.isUsing ? palette.success : palette.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  _timeLine(context, order),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ..._actionButtons(context, order),
            ],
          ),
        ],
      ),
    );
  }

  String _timeLine(BuildContext context, FortuneFinanceOrderVo order) {
    final parts = <String>[];
    if ((order.submitTime ?? '').isNotEmpty) {
      parts.add(S.of(context).ordersSubmitTime(order.submitTime!));
    }
    if ((order.closeTime ?? '').isNotEmpty) {
      parts.add(S.of(context).ordersCloseTime(order.closeTime!));
    }
    return parts.join(' · ');
  }

  /// 状态机按钮：使用中→[关闭]；已关闭→[重开]。附删除。
  List<Widget> _actionButtons(
    BuildContext context,
    FortuneFinanceOrderVo order,
  ) {
    final buttons = <Widget>[];
    if (order.isUsing) {
      buttons.add(
        _miniButton(context, S.of(context).ordersClose, () {
          HapticFeedback.selectionClick();
          _bloc.add(OrderTransitioned(order: order, action: 'close'));
        }),
      );
      buttons.add(const SizedBox(width: FxSpacing.sm));
    } else if (order.isClosed) {
      buttons.add(
        _miniButton(context, S.of(context).ordersReopen, () {
          HapticFeedback.selectionClick();
          _bloc.add(OrderTransitioned(order: order, action: 'reopen'));
        }),
      );
      buttons.add(const SizedBox(width: FxSpacing.sm));
    }
    // 未知/无法识别的状态：不猜测流转按钮，仅保留删除，避免对已关闭单据非法流转。
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

  Widget _miniButton(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    final palette = FxPalette.of(context);
    final color = danger ? palette.danger : palette.primary;
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
              color: color.withValues(alpha: 0.1),
              borderRadius: FxRadius.pillBorder,
            ),
            child: Text(
              label,
              style: FxTypography.label.copyWith(
                color: color,
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
