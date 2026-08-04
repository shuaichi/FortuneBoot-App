import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({FortuneFinanceOrderVo? order}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: order == null ? '新增单据' : '编辑单据',
      expand: true,
      child: OrderFormSheet(service: _service, bookId: bookId, order: order),
    );
    if (changed == true && mounted) _bloc.add(const OrdersMutated());
  }

  Future<void> _remove(FortuneFinanceOrderVo order) async {
    final bookId = _bookId;
    final orderId = order.orderId;
    if (bookId == null || orderId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除单据'),
        content: Text('确定删除「${order.title ?? '该单据'}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除', style: TextStyle(color: FxColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, orderId: orderId);
      if (mounted) _bloc.add(const OrdersMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    return _BookSync(
      bookId: bookId,
      child: Scaffold(
        backgroundColor: FxColors.canvas,
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
                  _buildHeader(),
                  Expanded(child: _buildBody(state, bookId)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: () => Navigator.of(context).maybePop(),
            radius: 22,
            child: const Padding(
              padding: EdgeInsets.all(FxSpacing.xs),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: FxColors.textPrimary,
              ),
            ),
          ),
          const Expanded(child: Text('单据', style: FxTypography.title)),
          InkResponse(
            onTap: () => _openForm(),
            radius: 22,
            child: const Padding(
              padding: EdgeInsets.all(FxSpacing.xs),
              child: Icon(
                Icons.add_rounded,
                size: 26,
                color: FxColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(OrdersState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: '请先选择账本');
    }
    switch (state.status) {
      case OrdersStatus.initial:
      case OrdersStatus.loading:
        return FxStateView.loading();
      case OrdersStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
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
                  message: '暂无单据，点击右上角 + 新增',
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
            separatorBuilder: (_, i) =>
                const SizedBox(height: FxSpacing.md),
            itemBuilder: (context, i) =>
                _orderCard(state.orders[i]),
          ),
        );
    }
  }

  Widget _orderCard(FortuneFinanceOrderVo order) {
    return FxCard(
      onTap: () => _openForm(order: order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: FxColors.primary,
              ),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Text(
                  order.title ?? '未命名单据',
                  style: FxTypography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((order.typeDesc ?? '').isNotEmpty)
                _tag(order.typeDesc!, FxColors.info),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Row(
            children: [
              const Text('支出 ', style: FxTypography.caption),
              FxMoneyText(
                amount: order.outAmount ?? 0,
                currencyCode: _currency,
                fontSize: 13,
                color: FxColors.expense,
              ),
              const SizedBox(width: FxSpacing.md),
              const Text('转入 ', style: FxTypography.caption),
              FxMoneyText(
                amount: order.inAmount ?? 0,
                currencyCode: _currency,
                fontSize: 13,
                color: FxColors.income,
              ),
              const Spacer(),
              if ((order.statusDesc ?? '').isNotEmpty)
                _tag(
                  order.statusDesc!,
                  order.isUsing ? FxColors.success : FxColors.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  _timeLine(order),
                  style: FxTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ..._actionButtons(order),
            ],
          ),
        ],
      ),
    );
  }

  String _timeLine(FortuneFinanceOrderVo order) {
    final parts = <String>[];
    if ((order.submitTime ?? '').isNotEmpty) {
      parts.add('提交 ${order.submitTime}');
    }
    if ((order.closeTime ?? '').isNotEmpty) {
      parts.add('关闭 ${order.closeTime}');
    }
    return parts.join(' · ');
  }

  /// 状态机按钮：使用中→[关闭]；已关闭→[重开]。附删除。
  List<Widget> _actionButtons(FortuneFinanceOrderVo order) {
    final buttons = <Widget>[];
    if (order.isUsing) {
      buttons.add(
        _miniButton('关闭', () {
          HapticFeedback.selectionClick();
          _bloc.add(OrderTransitioned(order: order, action: 'close'));
        }),
      );
      buttons.add(const SizedBox(width: FxSpacing.sm));
    } else if (order.isClosed) {
      buttons.add(
        _miniButton('重开', () {
          HapticFeedback.selectionClick();
          _bloc.add(OrderTransitioned(order: order, action: 'reopen'));
        }),
      );
      buttons.add(const SizedBox(width: FxSpacing.sm));
    }
    // 未知/无法识别的状态：不猜测流转按钮，仅保留删除，避免对已关闭单据非法流转。
    buttons.add(
      _miniButton('删除', () => _remove(order), danger: true),
    );
    return buttons;
  }

  Widget _miniButton(String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? FxColors.danger : FxColors.primary;
    return GestureDetector(
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
