import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/stats/data/stats_card_catalog.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_layout_editor.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_overview_bar.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_pie_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_tag_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_top_bar.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_trend_card.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 统计图表页：时间区间 + 支/收分段（全页联动）+ 概览条 + 图表卡。
/// 订阅 SessionCubit 切账本重拉，并监听 BillMutations 在记账/编辑后刷新。
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Completer<void>? _refreshCompleter;
  bool _editingLayout = false;

  @override
  void initState() {
    super.initState();
    BillMutations.revision.addListener(_onExternalMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onExternalMutation);
    _completeRefresh();
    super.dispose();
  }

  Future<void> _onRefresh() {
    _completeRefresh();
    final completer = Completer<void>();
    _refreshCompleter = completer;
    context.read<StatsBloc>().add(const StatsRefreshed());
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        if (identical(_refreshCompleter, completer)) {
          _completeRefresh();
        }
      },
    );
  }

  void _completeRefresh() {
    final completer = _refreshCompleter;
    if (completer == null) return;
    _refreshCompleter = null;
    if (!completer.isCompleted) completer.complete();
  }

  bool _isAnalyticsLoading(StatsState state) {
    return state.overview.status == StatsSectionStatus.loading ||
        state.trends.status == StatsSectionStatus.loading ||
        state.categories.status == StatsSectionStatus.loading ||
        state.tags.status == StatsSectionStatus.loading ||
        state.payees.status == StatsSectionStatus.loading;
  }

  /// 外部（中央 FAB 记账、编辑、确认/计入切换等）账单变更 → 重拉统计。
  void _onExternalMutation() {
    if (mounted) context.read<StatsBloc>().add(const StatsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, next) => prev.currentBookId != next.currentBookId,
      listener: (context, session) {
        context.read<StatsBloc>().add(
          StatsBookChanged(bookId: session.currentBookId),
        );
      },
      child: BlocListener<PreferencesCubit, PreferencesState>(
        listenWhen: (prev, next) =>
            prev.billing.monthStartDay != next.billing.monthStartDay,
        listener: (context, preferences) {
          context.read<StatsBloc>().add(
            StatsMonthStartDayChanged(preferences.billing.monthStartDay),
          );
        },
        child: BlocListener<StatsBloc, StatsState>(
          listenWhen: (previous, current) {
            return _refreshCompleter != null &&
                _isAnalyticsLoading(previous) &&
                !_isAnalyticsLoading(current);
          },
          listener: (_, _) => _completeRefresh(),
          child: Scaffold(
            backgroundColor: FxPalette.of(context).canvas,
            body: Column(
              children: [
                StatsTopBar(
                  editingLayout: _editingLayout,
                  onEditLayoutToggle: () {
                    setState(() => _editingLayout = !_editingLayout);
                  },
                ),
                Expanded(
                  child: _Body(
                    onRefresh: _onRefresh,
                    editingLayout: _editingLayout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.onRefresh, required this.editingLayout});

  final RefreshCallback onRefresh;
  final bool editingLayout;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final ValueNotifier<int> _dragCount = ValueNotifier<int>(0);
  List<StatsCardId>? _previewVisible;
  StatsCardId? _draggingId;
  List<StatsCardId> _committedVisible = const [];

  bool get _editingLayout => widget.editingLayout;

  List<StatsCardId> get _layoutVisible => _previewVisible ?? _committedVisible;

  @override
  void didUpdateWidget(covariant _Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editingLayout && !widget.editingLayout) {
      _previewVisible = null;
      _draggingId = null;
      _dragCount.value = 0;
    }
  }

  @override
  void dispose() {
    _dragCount.dispose();
    super.dispose();
  }

  void _onDragStarted(StatsCardId id) {
    _draggingId = id;
    _previewVisible = List<StatsCardId>.of(_committedVisible);
    _dragCount.value++;
    setState(() {});
  }

  void _onInsertNear(StatsCardId from, StatsCardId to, {required bool after}) {
    if (_draggingId != from) return;
    final current = _previewVisible ?? _committedVisible;
    final next = StatsCardCatalog.relocate(
      visible: current,
      from: from,
      to: to,
      after: after,
    );
    if (_sameOrder(next, current)) return;
    setState(() => _previewVisible = next);
  }

  Future<void> _onDragEnded(
    List<StatsCardId> placeable,
    Set<StatsCardId> hidden,
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
      await StatsLayoutController.persist(
        context,
        order: [...preview, ...placeable],
        hidden: hidden,
      );
      return;
    }
    _previewVisible = null;
    setState(() {});
  }

  bool _sameOrder(List<StatsCardId> a, List<StatsCardId> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (!state.hasBook) {
          return FxStateView.empty(message: S.of(context).statsSelectBookFirst);
        }

        return BlocBuilder<PreferencesCubit, PreferencesState>(
          buildWhen: (prev, next) =>
              prev.stats != next.stats ||
              prev.dashboard.hideAmounts != next.dashboard.hideAmounts,
          builder: (context, preferences) {
            final snap = StatsLayoutController.snapshot(preferences.stats);
            if (_draggingId == null) {
              _committedVisible = snap.visible;
            }
            final visibleIds = _editingLayout ? _layoutVisible : snap.visible;

            final bloc = context.read<StatsBloc>();
            void retry() => bloc.add(const StatsRefreshed());
            final currency = state.currencyCode;
            final hideAmounts = preferences.dashboard.hideAmounts;
            final expense = state.type == StatsType.expense;

            final children = <Widget>[];
            for (final id in visibleIds) {
              final card = _cardFor(
                context,
                id: id,
                state: state,
                currency: currency,
                onRetry: retry,
                bloc: bloc,
              );
              if (card == null) continue;
              final item = _editingLayout && id != StatsCardId.moreReports
                  ? StatsDraggableCard(
                      key: ValueKey(id),
                      id: id,
                      onDragStarted: () => _onDragStarted(id),
                      onDragEnded: () =>
                          _onDragEnded(snap.placeable, snap.hidden),
                      onInsertNear: _onInsertNear,
                      onRemove: () => StatsLayoutController.hide(
                        context,
                        id: id,
                        order: snap.order,
                        hidden: snap.hidden,
                      ),
                      child: card,
                    )
                  : card;
              if (children.isNotEmpty) {
                children.add(const SizedBox(height: FxSpacing.md));
              }
              children.add(item);
            }

            if (_editingLayout) {
              children.add(StatsLayoutTray(expense: expense));
            }

            if (children.isEmpty) {
              return FxStateView.empty(
                message: S.of(context).dashboardNoVisibleCards,
              );
            }

            final list = ValueListenableBuilder<int>(
              valueListenable: _dragCount,
              builder: (context, dragCount, child) {
                final bottomInset = ShellContentInsets.bottomOf(context);
                return ListView(
                  physics: dragCount > 0
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    FxSpacing.lg,
                    FxSpacing.sm,
                    FxSpacing.lg,
                    bottomInset,
                  ),
                  children: [child!],
                );
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            );

            return StatsPrivacy(
              hideAmounts: hideAmounts,
              child: _editingLayout
                  ? list
                  : RefreshIndicator(onRefresh: widget.onRefresh, child: list),
            );
          },
        );
      },
    );
  }

  Widget? _cardFor(
    BuildContext context, {
    required StatsCardId id,
    required StatsState state,
    required String? currency,
    required VoidCallback onRetry,
    required StatsBloc bloc,
  }) {
    return switch (id) {
      StatsCardId.moreReports => const _StatsEntryCard(),
      StatsCardId.overview => StatsOverviewBar(
        section: state.overview,
        currencyCode: currency,
      ),
      StatsCardId.calendar => StatsIncomeExpenseCalendarCard(
        section: state.calendar,
        view: state.calendarView,
        anchor: state.calendarAnchor,
        currencyCode: currency,
        bookId: bloc.bookId,
        onViewChanged: (view) => bloc.add(StatsCalendarViewChanged(view)),
        onNavigate: (delta) => bloc.add(StatsCalendarNavigate(delta)),
        onDrillDown: (view, anchor) =>
            bloc.add(StatsCalendarDrilledDown(view: view, anchor: anchor)),
        onBillsRequested: (date) {
          final statsBookId = bloc.bookId;
          final session = context.read<SessionCubit>().state;
          if (statsBookId == null || session.currentBookId != statsBookId) {
            return;
          }
          MainShell.openBills(
            context,
            BillsEntryRequest(
              bookId: statsBookId,
              groupId: session.currentGroupId,
              dateRange: BillDateRange(start: date, end: date),
            ),
          );
        },
        onRetry: () => bloc.add(const StatsCalendarRetried()),
      ),
      StatsCardId.insight => _StatsInsightCard(
        state: state,
        currencyCode: currency,
        showPlaceholder: _editingLayout,
      ),
      StatsCardId.dimensionPreview => _StatsDimensionPreviewCard(
        state: state,
        currencyCode: currency,
      ),
      StatsCardId.trend => StatsTrendCard(
        section: state.trends,
        type: state.type,
        currencyCode: currency,
        onRetry: onRetry,
      ),
      StatsCardId.categoryShare => StatsPieCard(
        label: _categoryLabel(context, state.type),
        section: state.categories,
        currencyCode: currency,
        onRetry: onRetry,
      ),
      StatsCardId.tags => StatsTagCard(
        label: _tagLabel(context, state.type),
        section: state.tags,
        currencyCode: currency,
        onRetry: onRetry,
      ),
      StatsCardId.payees => StatsPieCard(
        label: _payeeLabel(context, state.type),
        section: state.payees,
        currencyCode: currency,
        onRetry: onRetry,
      ),
    };
  }
}

String _analyticsLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpenseAnalytics
    : S.of(context).statsIncomeAnalytics;

String _categoryLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpenseCategoryShare
    : S.of(context).statsIncomeCategoryShare;

String _tagLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpenseTags
    : S.of(context).statsIncomeTags;

String _payeeLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpensePayees
    : S.of(context).statsIncomePayees;

class _StatsEntryCard extends StatelessWidget {
  const _StatsEntryCard();

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsMoreReports),
          const SizedBox(height: FxSpacing.sm),
          FxListItem(
            leading: _entryIcon(
              Icons.account_balance_wallet_rounded,
              finance.income,
            ),
            title: S.of(context).statsAssetsTitle,
            subtitle: S.of(context).statsAssetsEntrySubtitle,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.statsAssets),
          ),
          const Divider(height: FxSpacing.lg),
          FxListItem(
            leading: _entryIcon(Icons.savings_rounded, finance.transfer),
            title: S.of(context).statsLoansTitle,
            subtitle: S.of(context).statsLoansEntrySubtitle,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.statsLoans),
          ),
          const Divider(height: FxSpacing.lg),
          FxListItem(
            leading: _entryIcon(Icons.policy_rounded, palette.primary),
            title: S.of(context).statsPolicyTitle,
            subtitle: S.of(context).statsPolicyEntrySubtitle,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.statsPolicy),
          ),
        ],
      ),
    );
  }

  static Widget _entryIcon(IconData icon, Color tint) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: tint, size: 20),
    );
  }
}

class _StatsInsightCard extends StatelessWidget {
  final StatsState state;
  final String? currencyCode;
  final bool showPlaceholder;

  const _StatsInsightCard({
    required this.state,
    required this.currencyCode,
    this.showPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final stats = state.overview.data;
    if (stats == null) {
      if (!showPlaceholder) return const SizedBox.shrink();
      return FxCard(child: FxCardLabel(S.of(context).statsBasicTitle));
    }
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final totalFlow = stats.income + stats.expense;
    final expenseRatio = totalFlow <= 0 ? 0.0 : stats.expense / totalFlow;
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsBasicTitle),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InsightAmount(
                  label: S.of(context).statsExpense,
                  amount: stats.expense,
                  color: finance.expense,
                  currencyCode: currencyCode,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: _InsightAmount(
                  label: S.of(context).statsIncome,
                  amount: stats.income,
                  color: finance.income,
                  currencyCode: currencyCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          FxProgressBar(
            value: expenseRatio,
            color: finance.expense,
            height: 7,
            semanticsLabel: S.of(context).statsExpense,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            '${S.of(context).statsExpense} ${formats.percent(expenseRatio * 100)} · ${S.of(context).statsSurplus}',
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(
            amount: stats.surplus,
            currencyCode: currencyCode,
            showSign: true,
            colorBySign: true,
            fontSize: 14,
            masked: formats.masked,
          ),
        ],
      ),
    );
  }
}

class _StatsDimensionPreviewCard extends StatelessWidget {
  final StatsState state;
  final String? currencyCode;

  const _StatsDimensionPreviewCard({
    required this.state,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final category = state.categories.data
        ?.where((e) => e.value > 0)
        .firstOrNull;
    final tag = state.tags.data?.where((e) => e.value > 0).firstOrNull;
    final payee = state.payees.data?.where((e) => e.value > 0).firstOrNull;
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(_analyticsLabel(context, state.type)),
          const SizedBox(height: FxSpacing.md),
          _DimensionRow(
            title: _categoryLabel(context, state.type),
            name: category?.name,
            amount: category?.value,
            percent: category?.percent,
            currencyCode: currencyCode,
          ),
          const Divider(height: FxSpacing.lg),
          _DimensionRow(
            title: _tagLabel(context, state.type),
            name: tag?.name,
            amount: tag?.value,
            percent: tag?.percent,
            currencyCode: currencyCode,
          ),
          const Divider(height: FxSpacing.lg),
          _DimensionRow(
            title: _payeeLabel(context, state.type),
            name: payee?.name,
            amount: payee?.value,
            percent: payee?.percent,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).statsPolicyEntrySubtitle,
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _InsightAmount extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String? currencyCode;

  const _InsightAmount({
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final masked = StatsPrivacy.hideAmountsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
        const SizedBox(height: FxSpacing.xs),
        FxMoneyText(
          amount: amount,
          currencyCode: currencyCode,
          color: color,
          fontSize: 18,
          masked: masked,
        ),
      ],
    );
  }
}

class _DimensionRow extends StatelessWidget {
  final String title;
  final String? name;
  final double? amount;
  final double? percent;
  final String? currencyCode;

  const _DimensionRow({
    required this.title,
    required this.name,
    required this.amount,
    required this.percent,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final displayName = name == null || name!.isEmpty
        ? S.of(context).statsNoRecordsThisPeriod
        : name!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              const SizedBox(height: FxSpacing.xs),
              Text(
                displayName,
                style: FxTypography.bodyStrong.copyWith(
                  color: palette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (amount != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FxMoneyText(
                amount: amount!,
                currencyCode: currencyCode,
                fontSize: 13,
                color: palette.textPrimary,
                masked: formats.masked,
              ),
              if (percent != null)
                Text(
                  formats.percent(percent!),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
