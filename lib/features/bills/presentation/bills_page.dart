import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/time/month_window_resolver.dart';
import 'package:fortuneboot/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bill_detail_sheet.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bill_tile.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bills_filter_sheet.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 账单列表页（MainShell 账单 tab）。
class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final ScrollController _scrollController = ScrollController();
  final BillService _service = BillService();

  /// 时间流当前可见账期锚点；null 时回退当前选择账期（state.month）。
  final ValueNotifier<DateTime?> _visibleAnchor = ValueNotifier<DateTime?>(
    null,
  );

  /// 每个账期分组顶部探针 key（零高标记，用于滚动定位当前可见账期）。
  final Map<DateTime, GlobalKey> _monthKeys = {};

  GlobalKey _monthKeyFor(DateTime anchor) =>
      _monthKeys.putIfAbsent(anchor, () => GlobalKey());

  static final DateFormat _monthFormat = DateFormat('yyyy年M月');
  static final DateFormat _dayFormat = DateFormat('M月d日');
  static final DateFormat _rangeFormat = DateFormat('M月d日');

  List<String> _weekdays(BuildContext context) => [
    S.of(context).billsWeekdayMon,
    S.of(context).billsWeekdayTue,
    S.of(context).billsWeekdayWed,
    S.of(context).billsWeekdayThu,
    S.of(context).billsWeekdayFri,
    S.of(context).billsWeekdaySat,
    S.of(context).billsWeekdaySun,
  ];

  String _dayLabel(DateTime day) {
    final w = _weekdays(context)[(day.weekday - 1) % 7];
    return '${_dayFormat.format(day)} $w';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BillMutations.revision.addListener(_onExternalMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onExternalMutation);
    _visibleAnchor.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// 外部（中央 FAB 记账等）产生的账单变更 → 刷新列表。
  void _onExternalMutation() {
    if (mounted) _bloc.add(const BillsRefreshed());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<BillsBloc>().add(const BillsNextPageRequested());
    }
    _updateVisibleAnchor();
  }

  /// 根据各账期探针相对视口顶部的位置，选出"最后一个已越过顶部"的账期，
  /// 即当前时间流顶部正在展示的账期，写入 [_visibleAnchor]。
  void _updateVisibleAnchor() {
    DateTime? current;
    double bestTop = double.negativeInfinity;
    for (final entry in _monthKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      // 探针已滚过顶部（dy<=阈值）且最靠近顶部者胜出。
      if (dy <= _anchorThreshold && dy > bestTop) {
        bestTop = dy;
        current = entry.key;
      }
    }
    // 尚无探针越过顶部时，取第一个（最新账期）。
    current ??= _firstAnchor();
    if (current != null && current != _visibleAnchor.value) {
      _visibleAnchor.value = current;
    }
  }

  /// 顶栏下沿的 y 阈值：探针 dy 小于它即视为"已进入顶部区域"。
  double get _anchorThreshold {
    final topPad = MediaQuery.of(context).padding.top;
    return topPad + 120;
  }

  DateTime? _firstAnchor() {
    if (_monthKeys.isEmpty) return null;
    final keys = _monthKeys.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.first;
  }

  BillsBloc get _bloc => context.read<BillsBloc>();

  Future<void> _refresh() async {
    _bloc.add(const BillsRefreshed());
  }

  void _openFilter(BillsState state) {
    FxSheet.show<void>(
      context,
      title: S.of(context).billsFilterTitle,
      child: BillsFilterSheet(
        initial: state.filter,
        onApply: (filter) {
          Navigator.of(context).pop();
          _bloc.add(BillsFilterApplied(filter));
        },
      ),
    );
  }

  void _openDetail(FortuneBillVo bill) {
    FxSheet.show<void>(
      context,
      expand: true,
      child: BillDetailSheet(
        bill: bill,
        service: _service,
        onEdit: () {
          Navigator.of(context).pop();
          _goEdit(bill);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _confirmDelete(bill);
        },
        onConfirmToggle: (confirm) {
          Navigator.of(context).pop();
          if (bill.billId != null) {
            _bloc.add(BillsConfirmToggled(bill.billId!, confirm: confirm));
          }
        },
      ),
    );
  }

  Future<bool> _confirmDelete(FortuneBillVo bill) async {
    if (bill.billId == null) return false;
    final palette = FxPalette.of(context);
    final ok =
        await FxSheet.show<bool>(
          context,
          title: S.of(context).billsDeleteTitle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              0,
              FxSpacing.lg,
              FxSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.of(context).billsDeleteConfirm(
                    bill.title ?? bill.primaryCategoryName,
                  ),
                  style: FxTypography.body,
                ),
                const SizedBox(height: FxSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _sheetButton(
                        S.of(context).commonCancel,
                        onTap: () => Navigator.of(context).pop(false),
                        color: palette.surfaceMuted,
                        fg: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: FxSpacing.md),
                    Expanded(
                      child: _sheetButton(
                        S.of(context).billsDelete,
                        onTap: () => Navigator.of(context).pop(true),
                        color: palette.danger,
                        fg: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
    if (ok && mounted) {
      _bloc.add(BillsBillDeleted(bill.billId!));
    }
    return ok;
  }

  Widget _sheetButton(
    String label, {
    required VoidCallback onTap,
    required Color color,
    required Color fg,
  }) {
    return Material(
      color: color,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: FxTypography.bodyStrong.copyWith(color: fg),
          ),
        ),
      ),
    );
  }

  /// 右滑复制：跳 BillEditor，约定 Map 参数 {'mode':'copy','bill': vo}。
  void _goCopy(FortuneBillVo bill) {
    AppRouter.push<void>(
      context,
      Routes.billEditor,
      args: {'mode': 'copy', 'bill': bill},
    ).then((_) {
      if (mounted) _bloc.add(const BillsRefreshed());
    });
  }

  /// 编辑：跳 BillEditor，传完整 VO 预填（后端无单账单查询端点，用列表已持有的 VO）。
  void _goEdit(FortuneBillVo bill) {
    AppRouter.push<void>(
      context,
      Routes.billEditor,
      args: {'mode': 'edit', 'billId': bill.billId, 'bill': bill},
    ).then((_) {
      if (mounted) _bloc.add(const BillsRefreshed());
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    // 订阅 book 变化，自动重拉。
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );

    return _BookSync(
      bookId: bookId,
      child: BlocListener<PreferencesCubit, PreferencesState>(
        listenWhen: (prev, next) =>
            prev.billing.monthStartDay != next.billing.monthStartDay,
        listener: (context, preferences) {
          _bloc.add(
            BillsMonthStartDayChanged(preferences.billing.monthStartDay),
          );
        },
        child: Scaffold(
          backgroundColor: palette.canvas,
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<BillsBloc, BillsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    ValueListenableBuilder<DateTime?>(
                      valueListenable: _visibleAnchor,
                      builder: (context, anchor, _) {
                        final effective = anchor ?? state.month;
                        return Column(
                          children: [
                            _buildHeader(state, effective),
                            _buildSummaryBar(state, effective),
                          ],
                        );
                      },
                    ),
                    Expanded(child: _buildBody(state, bookId)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BillsState state, DateTime anchor) {
    final palette = FxPalette.of(context);
    final activeCount = state.filter.activeCount;
    final monthStartDay = context
        .watch<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    final window = MonthWindowResolver.resolveForAnchor(
      anchor,
      monthStartDay,
    );
    final rangeLabel =
        '${_rangeFormat.format(window.start)} - '
        '${_rangeFormat.format(window.end)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          _iconButton(Icons.chevron_left_rounded, () {
            HapticFeedback.selectionClick();
            _visibleAnchor.value = null;
            _bloc.add(const BillsMonthChanged(-1));
          }),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).billsBillingCycle(_monthFormat.format(anchor)),
                    style: FxTypography.title,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rangeLabel,
                    style: FxTypography.caption.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _iconButton(Icons.chevron_right_rounded, () {
            HapticFeedback.selectionClick();
            _visibleAnchor.value = null;
            _bloc.add(const BillsMonthChanged(1));
          }),
          const SizedBox(width: FxSpacing.sm),
          _filterButton(state, activeCount),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    final palette = FxPalette.of(context);
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xs),
        child: Icon(icon, size: 26, color: palette.textPrimary),
      ),
    );
  }

  Widget _filterButton(BillsState state, int activeCount) {
    final palette = FxPalette.of(context);
    return InkResponse(
      onTap: () => _openFilter(state),
      radius: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(FxSpacing.xs),
            child: Icon(
              Icons.tune_rounded,
              size: 24,
              color: palette.textPrimary,
            ),
          ),
          if (activeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: palette.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$activeCount',
                  textAlign: TextAlign.center,
                  style: FxTypography.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BillsState state, DateTime anchor) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final stats = state.summaryForAnchor(
      anchor,
      context.watch<PreferencesCubit>().state.billing.monthStartDay,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: FxRadius.cardBorder,
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryItem(S.of(context).billsExpense, stats.expense, finance.expense),
          _divider(),
          _summaryItem(S.of(context).billsIncome, stats.income, finance.income),
          _divider(),
          _summaryItem(
            S.of(context).billsBalance,
            stats.surplus,
            palette.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
          ),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(
            amount: amount,
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 28,
    color: FxPalette.of(context).border,
    margin: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
  );

  Widget _buildBody(BillsState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).billsSelectBookFirst);
    }
    switch (state.status) {
      case BillsStatus.initial:
      case BillsStatus.loading:
        return FxStateView.loading();
      case BillsStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const BillsRefreshed()),
        );
      case BillsStatus.loaded:
        if (state.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: FxStateView.empty(
                    message: S.of(context).billsEmpty,
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
              ],
            ),
          );
        }
        return _buildList(state);
    }
  }

  Widget _buildList(BillsState state) {
    final monthStartDay = context
        .watch<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    final groups = state.monthGroups(monthStartDay);
    // 重建探针 key 集合，仅保留当前分组锚点。
    final anchors = groups.map((g) => g.window.anchorMonth).toSet();
    _monthKeys.removeWhere((k, _) => !anchors.contains(k));
    // 分组结构可能在本帧变化，下一帧重新定位可见账期。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateVisibleAnchor();
    });
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (var i = 0; i < groups.length; i++) ...[
            SliverToBoxAdapter(
              child: SizedBox(
                key: _monthKeyFor(groups[i].window.anchorMonth),
                height: 0,
              ),
            ),
            if (i > 0) SliverToBoxAdapter(child: _monthHeader(groups[i])),
            for (final group in groups[i].dayGroups)
              SliverStickyGroup(
                header: _dayHeader(group),
                children: [
                  for (final bill in group.bills) _dismissibleTile(bill),
                ],
              ),
          ],
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(FxSpacing.lg),
                child: Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: FxSpacing.xxxl * 2)),
        ],
      ),
    );
  }

  Widget _monthHeader(BillMonthGroup group) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final stats = group.statistics;
    final range =
        '${_rangeFormat.format(group.window.start)} - '
        '${_rangeFormat.format(group.window.end)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        FxSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(FxSpacing.md),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: FxRadius.cardBorder,
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  S.of(context).billsBillingCycle(
                    _monthFormat.format(group.window.anchorMonth),
                  ),
                  style: FxTypography.label.copyWith(
                    color: FxPalette.of(context).textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  range,
                  style: FxTypography.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
            if (stats != null) ...[
              const SizedBox(height: FxSpacing.sm),
              Row(
                children: [
                  _miniSummary(
                    S.of(context).billsExpense,
                    stats.expense,
                    finance.expense,
                  ),
                  _miniSummary(
                    S.of(context).billsIncome,
                    stats.income,
                    finance.income,
                  ),
                  _miniSummary(
                    S.of(context).billsBalance,
                    stats.surplus,
                    palette.textPrimary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniSummary(String label, double amount, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
          ),
          Flexible(
            child: FxMoneyText(
              amount: amount,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayHeader(BillDayGroup group) {
    final dayExpense = group.bills
        .where((b) => _isExpenseType(b.billType))
        .fold<double>(0, (s, b) => s + b.displayAmount.abs());
    final dayIncome = group.bills
        .where((b) => b.billType == FxBillType.income.value)
        .fold<double>(0, (s, b) => s + b.displayAmount.abs());

    return Container(
      color: FxPalette.of(context).canvas,
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            _dayLabel(group.day),
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
          const Spacer(),
          if (dayExpense > 0)
            Text(
              S.of(context).billsDayExpense(_compact(dayExpense)),
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textTertiary,
              ),
            ),
          if (dayIncome > 0) ...[
            const SizedBox(width: FxSpacing.sm),
            Text(
              S.of(context).billsDayIncome(_compact(dayIncome)),
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isExpenseType(int? billType) =>
      billType == FxBillType.expense.value ||
      billType == FxBillType.advance.value ||
      billType == FxBillType.reimburse.value;

  String _compact(double v) => NumberFormat('#,##0.##').format(v);

  Widget _dismissibleTile(FortuneBillVo bill) {
    final palette = FxPalette.of(context);
    final tile = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: FxRadius.cardBorder,
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: FxRadius.cardBorder,
        child: BillTile(bill: bill, onTap: () => _openDetail(bill)),
      ),
    );

    if (bill.billId == null) return tile;

    return Dismissible(
      key: ValueKey('bill_${bill.billId}'),
      background: _swipeBg(
        alignment: Alignment.centerLeft,
        color: palette.primary,
        icon: Icons.copy_rounded,
        label: S.of(context).billsCopy,
      ),
      secondaryBackground: _swipeBg(
        alignment: Alignment.centerRight,
        color: palette.danger,
        icon: Icons.delete_outline_rounded,
        label: S.of(context).billsDelete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 右滑 → 复制（不消除该行）。
          _goCopy(bill);
          return false;
        }
        // 左滑 → 删除二次确认。返回 false，等待 Bloc 成功删除后由状态移除该行，
        // 避免 Dismissible 动画结束时同 key 账单仍在树上导致崩溃。
        await _confirmDelete(bill);
        return false;
      },
      child: tile,
    );
  }

  Widget _swipeBg({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: FxRadius.cardBorder,
      ),
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xl),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: FxSpacing.xs),
          Text(
            label,
            style: FxTypography.bodyStrong.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// 把 SessionCubit 的 bookId 变化派发给 BillsBloc。
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
      context.read<BillsBloc>().add(BillsBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<BillsBloc>().add(BillsBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 简单的 sticky group：分组头 + 该组账单，多个拼成账单流。
/// 用 SliverMainAxisGroup + SliverPersistentHeader 实现 header 粘顶。
class SliverStickyGroup extends StatelessWidget {
  final Widget header;
  final List<Widget> children;
  const SliverStickyGroup({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _DayHeaderDelegate(child: header),
        ),
        SliverList(delegate: SliverChildListDelegate(children)),
      ],
    );
  }
}

class _DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _DayHeaderDelegate({required this.child});

  static const double _height = 32;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: _height, child: child);
  }

  @override
  bool shouldRebuild(_DayHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
