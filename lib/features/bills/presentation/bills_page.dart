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

  static final DateFormat _monthFormat = DateFormat('yyyy年M月');
  static final DateFormat _dayFormat = DateFormat('M月d日');
  static final DateFormat _rangeFormat = DateFormat('M月d日');
  static const List<String> _weekdays = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  String _dayLabel(DateTime day) {
    final w = _weekdays[(day.weekday - 1) % 7];
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
  }

  BillsBloc get _bloc => context.read<BillsBloc>();

  Future<void> _refresh() async {
    _bloc.add(const BillsRefreshed());
  }

  void _openFilter(BillsState state) {
    FxSheet.show<void>(
      context,
      title: '筛选',
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
          title: '删除账单',
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
                  '确定删除「${bill.title ?? bill.primaryCategoryName}」吗？此操作不可撤销。',
                  style: FxTypography.body,
                ),
                const SizedBox(height: FxSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _sheetButton(
                        '取消',
                        onTap: () => Navigator.of(context).pop(false),
                        color: palette.surfaceMuted,
                        fg: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: FxSpacing.md),
                    Expanded(
                      child: _sheetButton(
                        '删除',
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
                    _buildHeader(state),
                    _buildSummaryBar(state),
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

  Widget _buildHeader(BillsState state) {
    final palette = FxPalette.of(context);
    final activeCount = state.filter.activeCount;
    final monthStartDay = context
        .watch<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    final window = MonthWindowResolver.resolveForAnchor(
      state.month,
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
            _bloc.add(const BillsMonthChanged(-1));
          }),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_monthFormat.format(state.month)}账期',
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

  Widget _buildSummaryBar(BillsState state) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final stats = state.statistics;
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
          _summaryItem('支出', stats?.expense ?? 0, finance.expense),
          _divider(),
          _summaryItem('收入', stats?.income ?? 0, finance.income),
          _divider(),
          _summaryItem('结余', stats?.surplus ?? 0, palette.textPrimary),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: FxTypography.caption),
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
      return FxStateView.empty(message: '请先选择账本');
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
                    message: '本账期暂无账单',
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (final monthGroup in groups) ...[
            SliverToBoxAdapter(child: _monthHeader(monthGroup)),
            for (final group in monthGroup.dayGroups)
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
                  '${_monthFormat.format(group.window.anchorMonth)}账期',
                  style: FxTypography.label,
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
                  _miniSummary('支出', stats.expense, finance.expense),
                  _miniSummary('收入', stats.income, finance.income),
                  _miniSummary('结余', stats.surplus, palette.textPrimary),
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
          Text('$label ', style: FxTypography.caption),
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
          Text(_dayLabel(group.day), style: FxTypography.label),
          const Spacer(),
          if (dayExpense > 0)
            Text('支 ${_compact(dayExpense)}', style: FxTypography.caption),
          if (dayIncome > 0) ...[
            const SizedBox(width: FxSpacing.sm),
            Text('收 ${_compact(dayIncome)}', style: FxTypography.caption),
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
        label: '复制',
      ),
      secondaryBackground: _swipeBg(
        alignment: Alignment.centerRight,
        color: palette.danger,
        icon: Icons.delete_outline_rounded,
        label: '删除',
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
