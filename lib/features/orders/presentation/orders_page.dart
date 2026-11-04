import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_permission.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_card.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_filter_sheet.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_form_sheet.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_summary_strip.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据列表页：C10 三类型、三状态、搜索、逾期和 20 条真实分页。
class OrdersPage extends StatefulWidget {
  final OrdersService? service;

  const OrdersPage({super.key, this.service});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrdersService? _service;
  final TextEditingController _searchController = TextEditingController();

  OrdersService get service => _service ??= widget.service ?? OrdersService();
  OrdersBloc get _bloc => context.read<OrdersBloc>();

  @override
  void initState() {
    super.initState();
    BillMutations.revision.addListener(_onMutated);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onMutated);
    _searchController.dispose();
    super.dispose();
  }

  void _onMutated() {
    if (mounted) _bloc.add(const OrdersLoaded());
  }

  Future<void> _openCreateForm() async {
    final bookId = context.read<SessionCubit>().state.currentBookId;
    if (bookId == null) return;
    final result = await FxSheet.show<OrderFormSheetResult>(
      context,
      title: S.of(context).ordersAddTitle,
      expand: true,
      child: OrderFormSheet(service: service, bookId: bookId),
    );
    if (result == null || !mounted) return;
    if (result.continueFlow && result.result.orderId != null) {
      final changed = await AppRouter.push<bool>(
        context,
        Routes.billEditor,
        args: {
          'mode': 'new',
          'presetBookId': bookId,
          'presetOrderId': result.result.orderId,
          'expectedOrderVersion': result.result.version,
          'lockOrderContext': true,
        },
      );
      if (changed == true) BillMutations.bump();
    }
    _bloc.add(const OrdersLoaded());
  }

  Future<void> _openDetail(FinanceOrderDetail order) async {
    if (order.orderId == null) return;
    await AppRouter.push<void>(
      context,
      Routes.orderDetail,
      args: {
        'bookId': order.bookId,
        'orderId': order.orderId,
        'service': service,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (cubit) => cubit.state.currentBookId,
    );
    final hideAmounts = context.select<PreferencesCubit, bool>(
      (cubit) => cubit.state.dashboard.hideAmounts,
    );
    return Scaffold(
      backgroundColor: FxPalette.of(context).canvas,
      body: SafeArea(
        child: BlocConsumer<OrdersBloc, OrdersState>(
          listener: (context, state) {
            if (state.toastMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.toastMessage!)));
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _header(context, state),
                Expanded(child: _body(context, state, bookId, hideAmounts)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, OrdersState state) {
    final canWrite = context.select<SessionCubit, bool>(
      (cubit) => SessionPermission.canWrite(cubit.state.currentGroup),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              FxIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  S.of(context).ordersTitle,
                  style: FxTypography.title,
                ),
              ),
              if (canWrite)
                FxIconButton(
                  icon: Icons.add_rounded,
                  tooltip: S.of(context).ordersAddTitle,
                  onPressed: _openCreateForm,
                ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          OrderSummaryStrip(
            summary: state.summary,
            currencyCode: context.read<SessionCubit>().state.defaultCurrency,
            hideAmounts: context.select<PreferencesCubit, bool>(
              (cubit) => cubit.state.dashboard.hideAmounts,
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          FxSegmented<FinanceOrderType>(
            value: state.type,
            onChanged: (type) => _bloc.add(OrdersTypeChanged(type)),
            segments: [
              FxSegment(
                FinanceOrderType.receivable,
                S.of(context).ordersTypeReceivable,
              ),
              FxSegment(
                FinanceOrderType.payable,
                S.of(context).ordersTypePayable,
              ),
              FxSegment(
                FinanceOrderType.reimbursement,
                S.of(context).ordersTypeReimbursement,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _bloc.add(OrdersSearchChanged(value)),
                  decoration: InputDecoration(
                    hintText: S.of(context).ordersSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
                  ),
                ),
              ),
              const SizedBox(width: FxSpacing.xs),
              _filterButton(context, state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterButton(BuildContext context, OrdersState state) {
    final activeCount =
        (state.statusFilter == FinanceOrderStatus.using.value ? 0 : 1) +
        (state.overdueOnly ? 1 : 0);
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      label: S.of(context).billsFilterTitle,
      value: activeCount == 0 ? null : '$activeCount',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FxIconButton(
            key: const ValueKey('orders-filter'),
            icon: Icons.tune_rounded,
            tooltip: S.of(context).billsFilterTitle,
            onPressed: () => FxSheet.show<void>(
              context,
              title: S.of(context).billsFilterTitle,
              actions: [
                Builder(
                  builder: (sheetContext) => FxIconButton(
                    icon: Icons.close_rounded,
                    tooltip: MaterialLocalizations.of(
                      sheetContext,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ],
              child: BlocProvider.value(
                value: _bloc,
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) => OrderFilterSheet(state: state),
                ),
              ),
            ),
          ),
          if (activeCount > 0)
            Positioned(
              right: 3,
              top: 3,
              child: IgnorePointer(
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$activeCount',
                    style: FxTypography.caption.copyWith(
                      color: palette.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    OrdersState state,
    int? bookId,
    bool hideAmounts,
  ) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).ordersSelectBookFirst);
    }
    if (state.status == OrdersLoadStatus.initial ||
        state.status == OrdersLoadStatus.loading) {
      return FxStateView.loading();
    }
    if (state.status == OrdersLoadStatus.error) {
      return FxStateView.error(
        message: state.errorMessage,
        onRetry: () => _bloc.add(const OrdersLoaded()),
        retryLabel: S.of(context).commonRetry,
      );
    }
    if (state.orders.isEmpty) {
      final message = state.keyword?.isNotEmpty == true || state.overdueOnly
          ? S.of(context).ordersFilterEmpty
          : S.of(context).ordersEmpty;
      return RefreshIndicator(
        onRefresh: () async => _bloc.add(const OrdersRefreshed()),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 96),
              child: FxStateView.empty(
                message: message,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const OrdersRefreshed()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.sm,
          FxSpacing.lg,
          FxSpacing.xxxl,
        ),
        children: [
          FxListSection(
            dividerIndent: FxSpacing.lg,
            children: [
              for (final order in state.orders)
                OrderCard(
                  order: order,
                  currencyCode: context
                      .read<SessionCubit>()
                      .state
                      .defaultCurrency,
                  hideAmounts: hideAmounts,
                  onTap: () => _openDetail(order),
                  onReport: order.isReviewRequired
                      ? () => _openReconciliation(focusOrderId: order.orderId)
                      : null,
                ),
            ],
          ),
          _footer(context, state),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, OrdersState state) {
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(FxSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreError != null) {
      return Column(
        children: [
          Text(state.loadMoreError!),
          FxButton.tonal(
            label: S.of(context).commonRetry,
            onPressed: () => _bloc.add(const OrdersLoadMoreRequested()),
          ),
        ],
      );
    }
    if (!state.hasMore) return const SizedBox.shrink();
    return FxButton.tonal(
      label: S.of(context).ordersLoadMore,
      onPressed: () => _bloc.add(const OrdersLoadMoreRequested()),
    );
  }

  Future<void> _openReconciliation({int? focusOrderId}) async {
    final bookId = context.read<SessionCubit>().state.currentBookId;
    if (bookId == null) return;
    await AppRouter.push<void>(
      context,
      Routes.orderReconciliation,
      args: {
        'bookId': bookId,
        'service': service,
        if (focusOrderId != null) 'focusOrderId': focusOrderId,
      },
    );
  }
}
