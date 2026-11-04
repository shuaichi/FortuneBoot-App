import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/category_top_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_draggable_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_layout_controller.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_layout_editor.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_top_bar.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/month_stat_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/net_worth_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/quick_add_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/recent_bills_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/trend_card.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/layout/fx_bento_grid.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 看板首页：粘顶栏 + Bento 卡片网格。订阅 SessionCubit 切账本重拉。
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _editingLayout = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, next) =>
          prev.currentBookId != next.currentBookId ||
          prev.currentGroupId != next.currentGroupId,
      listener: (context, session) {
        context.read<DashboardBloc>().add(
          DashboardBookChanged(
            bookId: session.currentBookId,
            groupId: session.currentGroupId,
          ),
        );
      },
      child: BlocListener<PreferencesCubit, PreferencesState>(
        listenWhen: (prev, next) =>
            prev.billing.monthStartDay != next.billing.monthStartDay,
        listener: (context, preferences) {
          context.read<DashboardBloc>().add(
            DashboardMonthStartDayChanged(preferences.billing.monthStartDay),
          );
        },
        child: _MutationRefresher(
          child: Scaffold(
            backgroundColor: FxPalette.of(context).canvas,
            body: Column(
              children: [
                DashboardTopBar(
                  editingLayout: _editingLayout,
                  onEditLayoutToggle: () {
                    setState(() => _editingLayout = !_editingLayout);
                  },
                ),
                Expanded(child: _Body(editingLayout: _editingLayout)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 监听全局账单变更（中央 FAB 记账、Bills 删除等），驱动看板重拉。
class _MutationRefresher extends StatefulWidget {
  const _MutationRefresher({required this.child});
  final Widget child;

  @override
  State<_MutationRefresher> createState() => _MutationRefresherState();
}

class _MutationRefresherState extends State<_MutationRefresher> {
  @override
  void initState() {
    super.initState();
    BillMutations.revision.addListener(_onMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onMutation);
    super.dispose();
  }

  void _onMutation() {
    if (mounted) {
      context.read<DashboardBloc>().add(const DashboardRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Body extends StatefulWidget {
  const _Body({required this.editingLayout});

  final bool editingLayout;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  static const double _desktopBreakpoint = 960;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _dragCount = ValueNotifier<int>(0);
  List<DashboardCardId>? _previewVisible;
  DashboardCardId? _draggingId;
  List<DashboardCardId> _committedVisible = const [];

  bool get _editingLayout => widget.editingLayout;

  List<DashboardCardId> get _layoutVisible =>
      _previewVisible ?? _committedVisible;

  @override
  void didUpdateWidget(covariant _Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editingLayout && !widget.editingLayout) {
      _previewVisible = null;
      _draggingId = null;
      _dragCount.value = 0;
    }
  }

  void _onDragStarted(DashboardCardId id) {
    _draggingId = id;
    _previewVisible = List<DashboardCardId>.of(_committedVisible);
    _dragCount.value++;
    setState(() {});
  }

  void _onInsertNear(
    DashboardCardId from,
    DashboardCardId to, {
    required bool after,
  }) {
    if (_draggingId != from) return;
    final current = _previewVisible ?? _committedVisible;
    final next = DashboardCardCatalog.relocate(
      visible: current,
      from: from,
      to: to,
      after: after,
    );
    if (_sameOrder(next, current)) return;
    setState(() => _previewVisible = next);
  }

  Future<void> _onDragEnded(
    List<DashboardCardId> placeable,
    Set<DashboardCardId> hidden,
  ) async {
    final preview = _previewVisible;
    final committed = _committedVisible;
    _draggingId = null;
    if (_dragCount.value > 0) _dragCount.value--;
    if (preview != null && !_sameOrder(preview, committed)) {
      _committedVisible = preview;
      _previewVisible = null;
      setState(() {});
      if (!mounted) return;
      await DashboardLayoutController.persist(
        context,
        order: [...preview, ...placeable],
        hidden: hidden,
      );
      return;
    }
    _previewVisible = null;
    setState(() {});
  }

  bool _sameOrder(List<DashboardCardId> a, List<DashboardCardId> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dragCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (!state.hasBook) {
          return FxStateView.empty(
            message: S.of(context).dashboardSelectBookFirst,
          );
        }

        return BlocBuilder<PreferencesCubit, PreferencesState>(
          buildWhen: (prev, next) => prev.dashboard != next.dashboard,
          builder: (context, preferences) {
            final snap = DashboardLayoutController.snapshot(
              preferences.dashboard,
            );
            if (_draggingId == null) {
              _committedVisible = snap.visible;
            }
            final visibleIds = _editingLayout ? _layoutVisible : snap.visible;
            final bloc = context.read<DashboardBloc>();
            void retry() => bloc.add(const DashboardRefreshed());
            final currency = state.currencyCode;
            final emptyUser = state.isEmptyUser;
            final showCategories =
                !emptyUser &&
                (!state.categories.isReady ||
                    (state.categories.data?.isNotEmpty ?? false));
            final showTrend =
                !emptyUser &&
                (!state.expenseTrends.isReady ||
                    !state.incomeTrends.isReady ||
                    (state.expenseTrends.data?.isNotEmpty ?? false) ||
                    (state.incomeTrends.data?.isNotEmpty ?? false));
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final accessibleSummary = textScale > 1.3;
            final gridRowHeight = 100 + 40 * (textScale - 1).clamp(0.0, 2.0);

            final tiles = <FxBentoTile>[];
            Widget? recentBills;
            for (final id in visibleIds) {
              final spec = DashboardCardCatalog.specOf(id);
              if (spec.requiresNonEmptyUser && emptyUser) continue;
              if (spec.hideWhenCategoryEmpty && !showCategories) continue;
              if (id == DashboardCardId.trend && !showTrend) continue;
              final card = _cardFor(
                context,
                id: id,
                state: state,
                currency: currency,
                emptyUser: emptyUser,
                onRetry: retry,
              );
              if (!_editingLayout && id == DashboardCardId.recentBills) {
                recentBills = card;
                continue;
              }
              tiles.add(
                FxBentoTile(
                  id: id,
                  colSpan:
                      accessibleSummary &&
                          (id == DashboardCardId.monthExpense ||
                              id == DashboardCardId.monthIncome)
                      ? FxBentoTile.fullSpan
                      : spec.colSpan,
                  rowSpan: spec.rowSpan,
                  child: _editingLayout
                      ? DashboardDraggableCard(
                          key: ValueKey(id),
                          id: id,
                          onDragStarted: () => _onDragStarted(id),
                          onDragEnded: () =>
                              _onDragEnded(snap.placeable, snap.hidden),
                          onInsertNear: _onInsertNear,
                          onRemove: () => DashboardLayoutController.hide(
                            context,
                            id: id,
                            order: snap.order,
                            hidden: snap.hidden,
                          ),
                          child: card,
                        )
                      : card,
                ),
              );
            }

            if (tiles.isEmpty && recentBills == null && !_editingLayout) {
              return FxStateView.empty(
                message: S.of(context).dashboardNoVisibleCards,
              );
            }

            final grid = FxBentoGrid(
              tiles: tiles,
              rowHeight: gridRowHeight,
              padding: EdgeInsets.zero,
              allowBackfill: !_editingLayout,
            );
            final browsingContent = LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= _desktopBreakpoint;
                if (!desktop || recentBills == null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tiles.isNotEmpty) grid,
                      if (tiles.isNotEmpty && recentBills != null)
                        const SizedBox(height: FxSpacing.xl),
                      if (recentBills != null) recentBills,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: grid),
                    const SizedBox(width: FxSpacing.xxl),
                    SizedBox(width: 360, child: recentBills),
                  ],
                );
              },
            );
            final gridChildren = <Widget>[
              if (_editingLayout)
                Padding(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  child: grid,
                )
              else
                Padding(
                  padding: const EdgeInsets.all(FxSpacing.xl),
                  child: browsingContent,
                ),
              if (tiles.isEmpty && recentBills == null)
                Padding(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  child: Text(
                    S.of(context).dashboardNoVisibleCards,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (_editingLayout) const DashboardLayoutTray(),
            ];

            final content = ValueListenableBuilder<int>(
              valueListenable: _dragCount,
              builder: (context, dragCount, child) {
                final desktop =
                    MediaQuery.widthOf(context) >= _desktopBreakpoint;
                final bottomInset = ShellContentInsets.bottomOf(context);
                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: desktop,
                  interactive: true,
                  child: ListView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: dragCount > 0
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: bottomInset),
                    children: [child!],
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: gridChildren,
              ),
            );

            if (_editingLayout) return content;

            return RefreshIndicator(
              onRefresh: () {
                final completer = Completer<void>();
                bloc.add(DashboardRefreshed(completer: completer));
                return completer.future;
              },
              child: content,
            );
          },
        );
      },
    );
  }

  Widget _cardFor(
    BuildContext context, {
    required DashboardCardId id,
    required DashboardState state,
    required String? currency,
    required bool emptyUser,
    required VoidCallback onRetry,
  }) {
    return switch (id) {
      DashboardCardId.netWorth => NetWorthCard(
        section: state.assets,
        currencyCode: currency,
        emptyUser: emptyUser,
        onRetry: onRetry,
      ),
      DashboardCardId.monthExpense => MonthStatCard(
        section: state.monthStats,
        currencyCode: currency,
        isExpense: true,
        onRetry: onRetry,
      ),
      DashboardCardId.monthIncome => MonthStatCard(
        section: state.monthStats,
        currencyCode: currency,
        isExpense: false,
        onRetry: onRetry,
      ),
      DashboardCardId.trend => TrendCard(
        expenseSection: state.expenseTrends,
        incomeSection: state.incomeTrends,
        onRetry: onRetry,
      ),
      DashboardCardId.recentBills => RecentBillsCard(
        section: state.recentBills,
        currencyCode: currency,
        onRetry: onRetry,
        onBillTap: (bill) => BillDetailFlow().show(
          context,
          bookId: context.read<SessionCubit>().state.currentBookId,
          bill: bill,
        ),
      ),
      DashboardCardId.categoryTop => CategoryTopCard(
        section: state.categories,
        currencyCode: currency,
        onRetry: onRetry,
      ),
      DashboardCardId.quickAdd => const QuickAddCard(),
    };
  }
}
