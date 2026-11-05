import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/bills_navigation_controller.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/core/time/month_window_resolver.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:fortuneboot/features/bills/presentation/pages/bills_filter_page.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bill_tile.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bills_period_picker.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bills_period_summary.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_delete_confirmation.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
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
  const BillsPage({super.key, this.entryRequest, this.detailService});

  final BillsEntryRequest? entryRequest;
  final BillService? detailService;

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  static const _paginationTriggerDistance = 240.0;
  static const _headerAnchorOffset = 64.0;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();
  late final BillService _service;
  BillsNavigationController? _billsNavigation;
  var _lastNavigationRevision = 0;

  /// 时间流当前可见账期锚点；null 时回退当前选择账期（state.month）。
  final ValueNotifier<DateTime?> _visibleAnchor = ValueNotifier<DateTime?>(
    null,
  );

  /// 每个账期分组顶部探针 key（零高标记，用于滚动定位当前可见账期）。
  final Map<DateTime, GlobalKey> _monthKeys = {};

  GlobalKey _monthKeyFor(DateTime anchor) =>
      _monthKeys.putIfAbsent(anchor, () => GlobalKey());

  String get _localeName => Localizations.localeOf(context).toString();

  DateFormat get _monthFormat => DateFormat.yMMMM(_localeName);
  DateFormat get _dayFormat => DateFormat.MMMd(_localeName);
  DateFormat get _rangeFormat => DateFormat.MMMd(_localeName);

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
    _service = widget.detailService ?? BillService();
    _scrollController.addListener(_onScroll);
    BillMutations.revision.addListener(_onExternalMutation);
    if (widget.entryRequest case final request?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _bloc.add(BillsEntryApplied(request));
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navigation = BillsNavigationScope.maybeOf(context);
    if (navigation != _billsNavigation) {
      _billsNavigation?.removeListener(_consumeNavigationRequest);
      _billsNavigation = navigation;
      _billsNavigation?.addListener(_consumeNavigationRequest);
    }
    _consumeNavigationRequest();
  }

  void _consumeNavigationRequest() {
    final request = _billsNavigation?.request;
    if (request == null || request.revision <= _lastNavigationRevision) return;
    _lastNavigationRevision = request.revision;
    _bloc.add(BillsEntryApplied(request.entryRequest));
  }

  @override
  void didUpdateWidget(BillsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final request = widget.entryRequest;
    if (oldWidget.entryRequest != request && request != null) {
      _bloc.add(BillsEntryApplied(request));
    }
  }

  @override
  void dispose() {
    _billsNavigation?.removeListener(_consumeNavigationRequest);
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
    if (position.pixels >=
        position.maxScrollExtent - _paginationTriggerDistance) {
      context.read<BillsBloc>().add(const BillsNextPageRequested());
    }
    _updateVisibleAnchor();
  }

  /// 选择距列表顶部最近的账期。最后一个账期内容较短时无法滚到顶，
  /// 仍应成为当前定位结果，而不是回退到最新账期。
  void _updateVisibleAnchor() {
    DateTime? current;
    var bestDistance = double.infinity;
    final threshold = _anchorThreshold;
    for (final entry in _monthKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      final distance = (dy - threshold).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        current = entry.key;
      }
    }
    current ??= _firstAnchor();
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent == 0 &&
        _monthKeys.containsKey(_visibleAnchor.value)) {
      return;
    }
    if (current != null && current != _visibleAnchor.value) {
      _visibleAnchor.value = current;
    }
  }

  /// 顶栏下沿的 y 阈值：探针 dy 小于它即视为"已进入顶部区域"。
  double get _anchorThreshold {
    final listBox = _listKey.currentContext?.findRenderObject();
    if (listBox is RenderBox && listBox.hasSize) {
      return listBox.localToGlobal(Offset.zero).dy + 1;
    }
    final topPad = MediaQuery.of(context).padding.top;
    return topPad + _headerAnchorOffset;
  }

  DateTime? _firstAnchor() {
    if (_monthKeys.isEmpty) return null;
    final keys = _monthKeys.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.first;
  }

  DateTime _normalizeAnchor(DateTime d) => DateTime(d.year, d.month);

  /// 当前已加载账单归属的账期锚点（降序，最新在前）。
  List<DateTime> _presentAnchors() {
    final monthStartDay = context
        .read<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    return _bloc.state
        .monthGroups(monthStartDay)
        .map((g) => g.window.anchorMonth)
        .toList(growable: false);
  }

  /// 箭头切月：基于当前可见账期，在时间流中滚动到相邻账期。
  /// delta<0 更早（更旧，需要时向后翻页加载）；delta>0 更新（更近）。
  Future<void> _navigateMonth(int delta) async {
    HapticFeedback.selectionClick();
    final current = _normalizeAnchor(_visibleAnchor.value ?? _bloc.state.month);
    var anchors = _presentAnchors();
    var idx = anchors.indexOf(current);
    if (idx < 0) idx = 0;
    // delta>0 更新→上移(idx-1)，delta<0 更旧→下移(idx+1)。
    var target = idx - delta;
    // 目标更旧但尚未加载，则按需翻页直至出现或无更多数据。
    while (delta < 0 && target >= anchors.length && _bloc.state.hasMore) {
      final grew = await _loadMoreAndWait();
      anchors = _presentAnchors();
      if (!grew) break;
    }
    if (anchors.isEmpty) return;
    target = target.clamp(0, anchors.length - 1);
    await _scrollToAnchor(anchors[target]);
  }

  Future<void> _openPeriodPicker() async {
    final current = _normalizeAnchor(_visibleAnchor.value ?? _bloc.state.month);
    final selected = await FxSheet.show<DateTime>(
      context,
      title: S.of(context).billsPeriodPickerTitle,
      maxHeightFactor: FxSheet.pickerHeightFactor,
      child: BillsPeriodPicker(
        loadedAnchors: _presentAnchors(),
        currentAnchor: current,
        onSelected: (anchor) => Navigator.of(context).pop(anchor),
      ),
    );
    if (selected != null && mounted) await _jumpToPeriod(selected);
  }

  Future<void> _jumpToPeriod(DateTime selected) async {
    final target = _normalizeAnchor(selected);
    var anchors = _presentAnchors();
    if (anchors.contains(target)) {
      await _scrollToAnchor(target);
      return;
    }
    while (anchors.isNotEmpty &&
        target.isBefore(anchors.last) &&
        _bloc.state.hasMore) {
      final grew = await _loadMoreAndWait();
      if (!mounted) return;
      anchors = _presentAnchors();
      if (anchors.contains(target)) {
        await _scrollToAnchor(target);
        return;
      }
      if (!grew) break;
    }
    if (!mounted) return;
    if (_bloc.state.paginationErrorMessage != null) {
      FxFeedback.show(
        context,
        message: S.of(context).billsPeriodLoadFailed,
        tone: FxFeedbackTone.error,
        actionLabel: S.of(context).commonRetry,
        onAction: () => _jumpToPeriod(target),
      );
    } else {
      FxFeedback.info(context, message: S.of(context).billsPeriodUnavailable);
    }
  }

  /// 触发下一页加载并等待其完成，返回列表是否增长。
  Future<bool> _loadMoreAndWait() async {
    final before = _bloc.state.bills.length;
    _bloc.add(const BillsNextPageRequested());
    try {
      await _bloc.stream
          .firstWhere(
            (s) =>
                s.bills.length != before ||
                s.paginationErrorMessage != null ||
                (!s.hasMore && !s.isLoadingMore),
          )
          .timeout(const Duration(seconds: 6));
    } on Object {
      return _bloc.state.bills.length != before;
    }
    return _bloc.state.bills.length != before;
  }

  /// 平滑滚动到指定账期 section 的顶部探针。
  Future<void> _scrollToAnchor(DateTime anchor) async {
    final key = _monthKeys[_normalizeAnchor(anchor)];
    var ctx = key?.currentContext;
    if (ctx == null) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      ctx = _monthKeys[_normalizeAnchor(anchor)]?.currentContext;
    }
    if (ctx == null || !ctx.mounted) return;
    final probeBox = ctx.findRenderObject();
    final listBox = _listKey.currentContext?.findRenderObject();
    if (probeBox is RenderBox && listBox is RenderBox) {
      final delta =
          probeBox.localToGlobal(Offset.zero).dy -
          listBox.localToGlobal(Offset.zero).dy;
      final position = _scrollController.position;
      final offset = (position.pixels + delta).clamp(
        0.0,
        position.maxScrollExtent,
      );
      await _scrollController.animateTo(
        offset,
        duration: FxMotion.normal,
        curve: FxMotion.standard,
      );
    } else {
      await Scrollable.ensureVisible(
        ctx,
        duration: FxMotion.normal,
        curve: FxMotion.standard,
      );
    }
    if (mounted) {
      _visibleAnchor.value = _normalizeAnchor(anchor);
    }
  }

  BillsBloc get _bloc => context.read<BillsBloc>();

  Future<void> _refresh() async {
    final completion = _bloc.stream.firstWhere(
      (state) =>
          !state.isRefreshing &&
          (state.status == BillsStatus.loaded ||
              state.status == BillsStatus.error),
    );
    _bloc.add(const BillsRefreshed());
    await completion;
  }

  int? get _activeBookId => _bloc.bookId;

  void _openFilter(BillsState state) {
    FxSheet.show<void>(
      context,
      title: S.of(context).billsFilterTitle,
      scrollable: false,
      maxHeightFactor: FxSheet.pickerHeightFactor,
      child: BillsFilterPage(
        initial: state.filter,
        bookId: _activeBookId,
        groupId:
            widget.entryRequest?.groupId ??
            context.read<SessionCubit>().state.currentGroupId,
        onApply: (filter) {
          Navigator.of(context).pop();
          _bloc.add(BillsFilterApplied(filter));
        },
      ),
    );
  }

  void _openDetail(FortuneBillVo bill) {
    BillDetailFlow(
      service: _service,
    ).show(context, bookId: _activeBookId, bill: bill);
  }

  Future<bool> _confirmDelete(FortuneBillVo bill) async {
    if (bill.billId == null) return false;
    final bookId = _activeBookId;
    final confirmed = await showBillDeleteConfirmation(context, bill);
    if (confirmed && mounted && bookId != null) {
      _bloc.add(BillsBillDeleted(bookId: bookId, billId: bill.billId!));
    }
    return confirmed;
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

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    // 订阅 book 变化，自动重拉。
    final sessionBookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    final hideAmounts = context.select<PreferencesCubit, bool>(
      (cubit) => cubit.state.dashboard.hideAmounts,
    );
    final monthStartDay = context.select<PreferencesCubit, int>(
      (cubit) => cubit.state.billing.monthStartDay,
    );
    final request = widget.entryRequest;
    final bookId = request?.bookId ?? sessionBookId;

    return _BookSync(
      bookId: bookId,
      child: MultiBlocListener(
        listeners: [
          BlocListener<PreferencesCubit, PreferencesState>(
            listenWhen: (prev, next) =>
                prev.billing.monthStartDay != next.billing.monthStartDay,
            listener: (context, preferences) {
              _bloc.add(
                BillsMonthStartDayChanged(preferences.billing.monthStartDay),
              );
            },
          ),
          BlocListener<BillsBloc, BillsState>(
            listenWhen: (prev, next) {
              return prev.errorMessageSerial != next.errorMessageSerial &&
                  next.errorMessage != null &&
                  next.status == BillsStatus.loaded;
            },
            listener: (context, state) {
              FxFeedback.error(context, message: state.errorMessage!);
              _bloc.add(const BillsErrorMessageCleared());
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: palette.canvas,
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<BillsBloc, BillsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildTitleBar(state),
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _visibleAnchor,
                        builder: (context, anchor, _) => _buildBody(
                          state,
                          bookId,
                          hideAmounts,
                          monthStartDay,
                          anchor ?? state.month,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BillsState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.of(context).navBills,
              textAlign: TextAlign.start,
              style: FxTypography.titleLarge,
            ),
          ),
          _filterButton(state, state.filter.activeCount),
        ],
      ),
    );
  }

  Widget _buildPeriodControls(
    BillsState state,
    DateTime anchor,
    bool hideAmounts,
    int monthStartDay,
  ) {
    final palette = FxPalette.of(context);
    final anchors = _presentAnchors();
    final currentIndex = anchors.indexOf(_normalizeAnchor(anchor));
    final canNavigateOlder =
        (currentIndex >= 0 && currentIndex < anchors.length - 1) ||
        (state.hasMore && !state.isLoadingMore);
    final canNavigateNewer = currentIndex > 0;
    final window = MonthWindowResolver.resolveForAnchor(anchor, monthStartDay);
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
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final older = _iconButton(
                key: const ValueKey('bills-older-period'),
                Icons.chevron_left_rounded,
                tooltip: S.of(context).billsPreviousCycle,
                enabled: canNavigateOlder,
                onTap: () => _navigateMonth(-1),
              );
              final newer = _iconButton(
                key: const ValueKey('bills-newer-period'),
                Icons.chevron_right_rounded,
                tooltip: S.of(context).billsNextCycle,
                enabled: canNavigateNewer,
                onTap: () => _navigateMonth(1),
              );
              final visibility = _amountVisibilityButton(hideAmounts);
              final selector = InkResponse(
                key: const ValueKey('bills-period-selector'),
                onTap: _openPeriodPicker,
                radius: 24,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FxSpacing.xs,
                    vertical: FxSpacing.xs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        key: const ValueKey('bills-current-period-label'),
                        S
                            .of(context)
                            .billsBillingCycle(_monthFormat.format(anchor)),
                        textAlign: TextAlign.center,
                        style: FxTypography.title,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rangeLabel,
                        textAlign: TextAlign.center,
                        style: FxTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                return Column(
                  children: [
                    selector,
                    const SizedBox(height: FxSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [older, visibility, newer],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  older,
                  Expanded(child: selector),
                  newer,
                  const SizedBox(width: FxSpacing.xs),
                  visibility,
                ],
              );
            },
          ),
          _buildSummaryBar(state, anchor, hideAmounts, monthStartDay),
          if (state.errorMessage != null && state.status == BillsStatus.loaded)
            _buildRefreshError(),
          if (!state.filter.isEmpty) _buildActiveFilterSummary(state),
        ],
      ),
    );
  }

  Widget _iconButton(
    IconData icon, {
    Key? key,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          key: key,
          onTap: enabled ? onTap : null,
          radius: 22,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                icon,
                size: 26,
                color: enabled ? palette.textPrimary : palette.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountVisibilityButton(bool hidden) {
    final tooltip = hidden
        ? S.of(context).commonShowAmounts
        : S.of(context).commonHideAmounts;
    return FxIconButton(
      icon: hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      tooltip: tooltip,
      onPressed: () => _toggleAmountVisibility(hidden),
    );
  }

  Future<void> _toggleAmountVisibility(bool hidden) async {
    HapticFeedback.selectionClick();
    final saved = await context.read<PreferencesCubit>().setHideAmounts(
      !hidden,
    );
    if (!saved && mounted) {
      FxFeedback.error(context, message: S.of(context).profileSaveFailedRetry);
    }
  }

  Widget _filterButton(BillsState state, int activeCount) {
    final palette = FxPalette.of(context);
    final label = activeCount == 0
        ? S.of(context).billsFilterTitle
        : '${S.of(context).billsFilterTitle}，'
              '$activeCount ${S.of(context).billsFilterActiveCount}';
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: () => _openFilter(state),
          radius: 22,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(child: Icon(Icons.tune_rounded, size: 24)),
                if (activeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$activeCount',
                        textAlign: TextAlign.center,
                        style: FxTypography.caption.copyWith(
                          color: palette.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar(
    BillsState state,
    DateTime anchor,
    bool hideAmounts,
    int monthStartDay,
  ) {
    BillStatistics? stats;
    var filteredRange = false;
    if (state.filter.dateRange != null) {
      filteredRange = true;
      stats = state.isSummaryAvailable ? state.statistics : null;
    } else if (_normalizeAnchor(anchor) == _normalizeAnchor(state.month)) {
      stats = state.isSummaryAvailable ? state.statistics : null;
    } else {
      final key = MonthWindowResolver.resolveForAnchor(
        anchor,
        monthStartDay,
      ).anchorMonth;
      stats = state.monthStatistics[key];
    }
    if (stats == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredRange)
            Padding(
              padding: const EdgeInsets.only(bottom: FxSpacing.xs),
              child: Text(
                S.of(context).billsFilteredRangeSummary,
                style: FxTypography.caption.copyWith(
                  color: FxPalette.of(context).textSecondary,
                ),
              ),
            ),
          BillsPeriodSummary(statistics: stats, masked: hideAmounts),
        ],
      ),
    );
  }

  Widget _buildActiveFilterSummary(BillsState state) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(FxSpacing.md),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: FxRadius.cardBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${state.filter.activeCount} '
                    '${S.of(context).billsFilterActiveCount}',
                    style: FxTypography.label,
                  ),
                ),
                if (!state.isEmpty)
                  TextButton(
                    onPressed: () =>
                        _bloc.add(BillsFilterApplied(BillsFilter.empty)),
                    child: Text(S.of(context).billsClearFilters),
                  ),
              ],
            ),
            Text(
              _filterDescription(state),
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _filterDescription(BillsState state) {
    final filter = state.filter;
    final locale = _localeName;
    final parts = <String>[
      if (filter.title?.isNotEmpty == true)
        '${S.of(context).billsFilterByTitle}：${filter.title}',
      if (filter.billTypes.isNotEmpty)
        '${S.of(context).billsFilterBillType}：${(filter.billTypes.toList()..sort()).map((value) => FxBillType.fromValue(value)?.localizedLabel(context) ?? '$value').join('、')}',
      if (filter.amountMin != null || filter.amountMax != null)
        '${S.of(context).billsFilterAmountRange}：${filter.amountMin?.toStringAsFixed(2) ?? '—'} – ${filter.amountMax?.toStringAsFixed(2) ?? '—'}',
      if (filter.dateRange != null)
        '${S.of(context).billsFilterTitle}：${DateFormat.yMMMd(locale).format(filter.dateRange!.start)} – ${DateFormat.yMMMd(locale).format(filter.dateRange!.end)}',
      if (filter.confirm != null)
        filter.confirm!
            ? S.of(context).billsFilterConfirmed
            : S.of(context).billsFilterUnconfirmed,
      if (filter.include != null)
        filter.include!
            ? S.of(context).billsFilterIncluded
            : S.of(context).billsFilterExcluded,
      if (filter.categoryIds?.isNotEmpty == true)
        '${S.of(context).billsCategoryDetail} ${filter.categoryIds!.length}',
      if (filter.tagIds?.isNotEmpty == true)
        '${S.of(context).billsTags} ${filter.tagIds!.length}',
      if (filter.accountId != null) S.of(context).billsTransferOutAccount,
      if (filter.payeeId != null) S.of(context).billsPayee,
      if (filter.memberIds?.isNotEmpty == true)
        '${S.of(context).billsMembers} ${filter.memberIds!.length}',
    ];
    return parts.join(' · ');
  }

  Widget _buildRefreshError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.of(context).billsRefreshFailed,
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).danger,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _bloc.add(const BillsRefreshed()),
            child: Text(S.of(context).commonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BillsState state,
    int? bookId,
    bool hideAmounts,
    int monthStartDay,
    DateTime anchor,
  ) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).billsSelectBookFirst);
    }
    switch (state.status) {
      case BillsStatus.initial:
      case BillsStatus.loading:
        return ListView(
          children: [
            _buildPeriodControls(state, anchor, hideAmounts, monthStartDay),
            FxStateView.loading(title: S.of(context).navBills),
          ],
        );
      case BillsStatus.error:
        return ListView(
          children: [
            _buildPeriodControls(state, anchor, hideAmounts, monthStartDay),
            FxStateView.error(
              title: S.of(context).navBills,
              message: state.errorMessage,
              onRetry: () => _bloc.add(const BillsRefreshed()),
            ),
          ],
        );
      case BillsStatus.loaded:
        if (state.isEmpty) {
          final filtered = !state.filter.isEmpty;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                _buildPeriodControls(state, anchor, hideAmounts, monthStartDay),
                FxStateView.empty(
                  title: S.of(context).navBills,
                  message: filtered
                      ? S.of(context).billsFilterNoResults
                      : S.of(context).billsEmpty,
                  icon: Icons.receipt_long_rounded,
                  onRetry: filtered
                      ? () => _bloc.add(BillsFilterApplied(BillsFilter.empty))
                      : null,
                  retryLabel: filtered ? S.of(context).billsClearFilters : null,
                ),
                if (filtered)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FxSpacing.lg,
                    ),
                    child: OutlinedButton(
                      onPressed: () => _openFilter(state),
                      child: Text(S.of(context).billsAdjustFilters),
                    ),
                  ),
              ],
            ),
          );
        }
        return _buildList(state, hideAmounts, monthStartDay, anchor);
    }
  }

  Widget _buildList(
    BillsState state,
    bool hideAmounts,
    int monthStartDay,
    DateTime anchor,
  ) {
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
        key: _listKey,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildPeriodControls(
              state,
              anchor,
              hideAmounts,
              monthStartDay,
            ),
          ),
          for (var i = 0; i < groups.length; i++) ...[
            SliverToBoxAdapter(
              child: SizedBox(
                key: _monthKeyFor(groups[i].window.anchorMonth),
                height: 0,
              ),
            ),
            if (i > 0)
              SliverToBoxAdapter(child: _monthHeader(groups[i], hideAmounts)),
            for (final group in groups[i].dayGroups)
              SliverStickyGroup(
                header: _dayHeader(group),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      FxSpacing.lg,
                      0,
                      FxSpacing.lg,
                      FxSpacing.md,
                    ),
                    child: FxListSection(
                      children: [
                        for (final bill in group.bills)
                          _dismissibleTile(bill, hideAmounts),
                      ],
                    ),
                  ),
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
            )
          else if (state.paginationErrorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(FxSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      S.of(context).billsPaginationLoadFailed,
                      textAlign: TextAlign.center,
                      style: FxTypography.caption.copyWith(
                        color: FxPalette.of(context).textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _bloc.add(const BillsPaginationRetried()),
                      child: Text(S.of(context).commonRetry),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: ShellContentInsets.bottomOf(context)),
          ),
        ],
      ),
    );
  }

  Widget _monthHeader(BillMonthGroup group, bool hideAmounts) {
    final palette = FxPalette.of(context);
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              constraints.maxWidth < 280 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          final title = Text(
            S
                .of(context)
                .billsBillingCycle(
                  _monthFormat.format(group.window.anchorMonth),
                ),
            style: FxTypography.title,
          );
          final rangeText = Text(
            range,
            textAlign: stacked ? TextAlign.start : TextAlign.end,
            style: FxTypography.caption.copyWith(color: palette.textSecondary),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stacked) ...[
                title,
                const SizedBox(height: FxSpacing.xs),
                rangeText,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: FxSpacing.md),
                    Flexible(child: rangeText),
                  ],
                ),
              if (stats != null) ...[
                const SizedBox(height: FxSpacing.md),
                BillsPeriodSummary(statistics: stats, masked: hideAmounts),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _dayHeader(BillDayGroup group) {
    return Container(
      color: FxPalette.of(context).canvas,
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.xs,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        _dayLabel(group.day),
        style: FxTypography.label.copyWith(
          color: FxPalette.of(context).textSecondary,
        ),
      ),
    );
  }

  Widget _dismissibleTile(FortuneBillVo bill, bool hideAmounts) {
    final palette = FxPalette.of(context);
    final tile = ClipRRect(
      borderRadius: FxRadius.cardBorder,
      child: BillTile(
        bill: bill,
        masked: hideAmounts,
        onTap: () => _openDetail(bill),
      ),
    );

    if (bill.billId == null) return tile;

    return Dismissible(
      key: ValueKey('bill_${bill.billId}'),
      background: _swipeBg(
        alignment: Alignment.centerLeft,
        color: palette.primary,
        foreground: palette.onPrimary,
        icon: Icons.copy_rounded,
        label: S.of(context).billsCopy,
      ),
      secondaryBackground: _swipeBg(
        alignment: Alignment.centerRight,
        color: palette.danger,
        foreground: palette.onDanger,
        icon: Icons.delete_outline_rounded,
        label: S.of(context).billsDelete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _goCopy(bill);
          return false;
        }
        await _confirmDelete(bill);
        return false;
      },
      child: tile,
    );
  }

  Widget _swipeBg({
    required Alignment alignment,
    required Color color,
    required Color foreground,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: FxRadius.cardBorder,
      ),
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.xl),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: FxSpacing.xs),
          Text(
            label,
            style: FxTypography.bodyStrong.copyWith(color: foreground),
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final headerHeight = 20 * textScale + FxSpacing.sm + FxSpacing.xs;
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _DayHeaderDelegate(child: header, height: headerHeight),
        ),
        SliverList(delegate: SliverChildListDelegate(children)),
      ],
    );
  }
}

class _DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  const _DayHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(_DayHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
