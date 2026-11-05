import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/fx_page_route.dart';
import 'package:fortuneboot/core/navigation/fx_route_unavailable_page.dart';
import 'package:fortuneboot/core/navigation/pending_deep_link.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_permission.dart';
import 'package:fortuneboot/core/session/widgets/session_scope_strip.dart';
import 'package:fortuneboot/core/shell/bills_navigation_controller.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// MainShell 的 tab 内容槽。各 feature 阶段落地后通过 [MainShellSlots] 注入
/// 真实页面 builder；未注入时显示占位，保证骨架先编译可跑。
class MainShellSlots {
  const MainShellSlots._();

  static WidgetBuilder? dashboard;
  static WidgetBuilder? bills;
  static WidgetBuilder? stats;
  static WidgetBuilder? profile;
}

enum MainShellTab { dashboard, bills, stats, profile }

/// 主壳层统一发布的滚动内容底部避让空间。
///
/// Scaffold 的 bottomNavigationBar 已经占掉导航栏和安全区，页面不再重复预留整条
/// 导航高度；只在 FAB 实际覆盖内容时保留可滚动空间。
class ShellContentInsets extends InheritedWidget {
  const ShellContentInsets({
    super.key,
    required this.bottom,
    required super.child,
  });

  final double bottom;

  static double bottomOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<ShellContentInsets>();
    return inherited?.bottom ??
        FxSpacing.xxl + MediaQuery.paddingOf(context).bottom;
  }

  @override
  bool updateShouldNotify(ShellContentInsets oldWidget) =>
      bottom != oldWidget.bottom;
}

/// 响应式主导航：窄屏底部 Tab，宽屏侧边栏。IndexedStack 保活。
/// 首次进入时触发 SessionCubit.load() 拉取分组/账本。
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// 切换当前 Shell 内的 tab。仅能在 [MainShell] 子树中调用。
  static void selectTab(BuildContext context, MainShellTab tab) {
    final state = context.findAncestorStateOfType<_MainShellState>();
    if (state == null) {
      throw FlutterError('MainShell.selectTab must be called below MainShell.');
    }
    state._selectTab(tab);
  }

  static void openBills(BuildContext context, BillsEntryRequest request) {
    final state = context.findAncestorStateOfType<_MainShellState>();
    if (state == null) {
      throw FlutterError('MainShell.openBills must be called below MainShell.');
    }
    state._openBills(request);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _billsNavigation = BillsNavigationController();
  var _index = MainShellTab.dashboard.index;
  var _restoringDeepLink = false;
  var _deepLinkFallbackOpen = false;

  void _selectTab(MainShellTab tab) {
    if (_index == tab.index) return;
    setState(() => _index = tab.index);
  }

  void _openBills(BillsEntryRequest request) {
    _billsNavigation.open(request);
    _selectTab(MainShellTab.bills);
  }

  @override
  void dispose() {
    _billsNavigation.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>();
    // 进入主壳即拉取；换服务器登录后若未 reset，也能用新地址重拉账本。
    if (session.state.status != SessionStatus.loading) {
      unawaited(session.load());
    }
    // 标记已进入受保护会话；否则后台/恢复时不会上锁。
    unawaited(context.read<AppLockCubit>().onAuthenticated());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeRestoreDeepLink(),
    );
  }

  Widget _slot(WidgetBuilder? builder, String label) {
    if (builder == null) {
      return Builder(
        builder: (context) => Center(
          child: Text(
            '$label（${S.of(context).navInDevelopment}）',
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ),
      );
    }
    return Builder(builder: builder);
  }

  static const double _desktopBreakpoint = 1000;
  static const double _contentMaxWidth = 1120;

  void _openQuickAdd() {
    final session = context.read<SessionCubit>().state;
    if (session.status != SessionStatus.ready ||
        session.currentBook == null ||
        !SessionPermission.canWrite(session.currentGroup)) {
      return;
    }
    HapticFeedback.selectionClick();
    // 路由 builder 会读取点击瞬间的当前范围；提交期间范围变化不会重绑旧页面。
    AppRouter.push<void>(context, Routes.billEditor);
  }

  MainShellTab? _tabForRoute(String route) => switch (route) {
    Routes.dashboard => MainShellTab.dashboard,
    Routes.bills => MainShellTab.bills,
    Routes.stats => MainShellTab.stats,
    Routes.profile => MainShellTab.profile,
    _ => null,
  };

  /// 等会话恢复后再进入被保存的深链目标；不在登录前或范围未知时强开页面。
  void _maybeRestoreDeepLink() {
    if (!mounted || _restoringDeepLink || _deepLinkFallbackOpen) return;
    final target = PendingDeepLink.instance.peek();
    if (target == null) return;
    final session = context.read<SessionCubit>().state;
    if (session.status == SessionStatus.initial ||
        session.status == SessionStatus.loading) {
      return;
    }

    final tab = _tabForRoute(target.route);
    if (tab != null) {
      PendingDeepLink.instance.take();
      if (tab != MainShellTab.values[_index]) {
        _selectTab(tab);
      }
      return;
    }

    if (session.status == SessionStatus.error) {
      _showDeepLinkFallback(
        FxRouteUnavailableReason.sessionUnavailable,
        keepTargetForRetry: true,
      );
      return;
    }
    if (!AppRouter.isRegistered(target.route)) {
      PendingDeepLink.instance.take();
      _showDeepLinkFallback(FxRouteUnavailableReason.unknownRoute);
      return;
    }
    if (!AppRouter.canRestore(target)) {
      PendingDeepLink.instance.take();
      _showDeepLinkFallback(FxRouteUnavailableReason.missingContext);
      return;
    }
    if (AppRouter.requiresWriteAccess(target.route) &&
        !SessionPermission.canWrite(session.currentGroup)) {
      PendingDeepLink.instance.take();
      _showDeepLinkFallback(FxRouteUnavailableReason.noPermission);
      return;
    }

    final route = target.route;
    final arguments = target.arguments;
    PendingDeepLink.instance.take();
    _restoringDeepLink = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamed<dynamic>(route, arguments: arguments)
          .whenComplete(() => _restoringDeepLink = false);
    });
  }

  void _showDeepLinkFallback(
    FxRouteUnavailableReason reason, {
    bool keepTargetForRetry = false,
  }) {
    if (!mounted || _deepLinkFallbackOpen) return;
    _deepLinkFallbackOpen = true;
    Navigator.of(context)
        .push<void>(
          buildFxRoute<void>(
            settings: const RouteSettings(name: 'fx://route-unavailable'),
            builder: (_) => FxRouteUnavailablePage(
              reason: reason,
              onRetry: keepTargetForRetry
                  ? () {
                      final cubit = context.read<SessionCubit>();
                      Navigator.of(context).maybePop();
                      unawaited(cubit.load());
                    }
                  : null,
            ),
          ),
        )
        .whenComplete(() {
          if (!mounted) return;
          _deepLinkFallbackOpen = false;
          if (!keepTargetForRetry) return;
          final session = context.read<SessionCubit>().state;
          if (session.status == SessionStatus.ready ||
              session.status == SessionStatus.empty) {
            _maybeRestoreDeepLink();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final wide = MediaQuery.widthOf(context) >= _desktopBreakpoint;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final sessionState = context.watch<SessionCubit>().state;
    final currentTab = MainShellTab.values[_index];
    final canWrite = SessionPermission.canWrite(sessionState.currentGroup);
    final quickAddAvailable =
        sessionState.status == SessionStatus.ready &&
        sessionState.currentBook != null &&
        canWrite;
    // 看板已有自己的分组/账本切换头；只在等待、失败、只读或无账本时补一条
    // 全壳范围说明，避免同一屏重复两套范围文字。
    final showScopeStrip =
        currentTab != MainShellTab.dashboard ||
        sessionState.status != SessionStatus.ready ||
        sessionState.currentBook == null ||
        !canWrite;
    final pages = [
      _slot(MainShellSlots.dashboard, s.navDashboard),
      _slot(MainShellSlots.bills, s.navBills),
      _slot(MainShellSlots.stats, s.navStats),
      _slot(MainShellSlots.profile, s.navProfile),
    ];
    final destinations = [
      (Icons.dashboard_outlined, Icons.dashboard_rounded, s.navDashboard),
      (Icons.receipt_long_outlined, Icons.receipt_long_rounded, s.navBills),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, s.navStats),
      (Icons.person_outline_rounded, Icons.person_rounded, s.navProfile),
    ];
    final stack = IndexedStack(index: _index, children: pages);
    final content = SafeArea(
      top: false,
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            children: [
              if (showScopeStrip)
                SessionScopeStrip(
                  state: sessionState,
                  interactive: true,
                  showTopInset: true,
                ),
              Expanded(
                child: showScopeStrip
                    ? MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: stack,
                      )
                    : stack,
              ),
            ],
          ),
        ),
      ),
    );

    final showFab = !wide && quickAddAvailable && !keyboardOpen;
    final contentBottomInset = wide
        ? FxSpacing.xxxl + MediaQuery.paddingOf(context).bottom
        : showFab
        ? 72 + FxSpacing.lg
        : FxSpacing.xxl;
    return ShellContentInsets(
      bottom: contentBottomInset,
      child: BillsNavigationScope(
        controller: _billsNavigation,
        child: BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.currentBookId != current.currentBookId ||
              previous.currentGroupId != current.currentGroupId,
          listener: (_, _) => _maybeRestoreDeepLink(),
          child: Scaffold(
            body: wide
                ? Row(
                    children: [
                      SafeArea(
                        top: false,
                        right: false,
                        bottom: false,
                        child: NavigationRail(
                          extended: true,
                          minExtendedWidth: 224,
                          labelType: NavigationRailLabelType.none,
                          backgroundColor: palette.surface,
                          selectedIndex: _index,
                          onDestinationSelected: (value) =>
                              _selectTab(MainShellTab.values[value]),
                          indicatorColor: palette.primaryContainer,
                          indicatorShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                            child: SizedBox(
                              width: 192,
                              child: quickAddAvailable
                                  ? FxButton(
                                      label: s.dashboardQuickAdd,
                                      icon: Icons.add_rounded,
                                      expand: true,
                                      onPressed: _openQuickAdd,
                                    )
                                  : _RailScopeNotice(state: sessionState),
                            ),
                          ),
                          destinations: [
                            for (final destination in destinations)
                              NavigationRailDestination(
                                icon: Icon(destination.$1),
                                selectedIcon: Icon(destination.$2),
                                label: Text(destination.$3),
                              ),
                          ],
                        ),
                      ),
                      VerticalDivider(width: 1, color: palette.border),
                      Expanded(child: content),
                    ],
                  )
                : content,
            floatingActionButton: showFab
                ? FloatingActionButton(
                    tooltip: s.dashboardQuickAdd,
                    onPressed: _openQuickAdd,
                    backgroundColor: palette.textPrimary,
                    foregroundColor: palette.surface,
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add_rounded, size: 28),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: wide
                ? null
                : _ShellBottomNav(
                    selectedIndex: _index,
                    destinations: destinations,
                    onSelected: (value) =>
                        _selectTab(MainShellTab.values[value]),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 底部导航按内容决定高度，不夹断系统 TextScaler；至少保留 48 逻辑像素触区。
class _ShellBottomNav extends StatelessWidget {
  const _ShellBottomNav({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<(IconData, IconData, String)> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Material(
      color: palette.surface,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _ShellNavItem(
                    icon: destinations[index].$1,
                    selectedIcon: destinations[index].$2,
                    label: destinations[index].$3,
                    selected: index == selectedIndex,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelected(index);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final foreground = selected ? palette.primary : palette.textSecondary;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: FxSpacing.touchTarget,
              minHeight: FxSpacing.controlHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FxSpacing.xs,
                vertical: 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: FxMotion.resolve(
                      context,
                      const Duration(milliseconds: 160),
                    ),
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? palette.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      selected ? selectedIcon : icon,
                      size: 22,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: FxTypography.caption.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailScopeNotice extends StatelessWidget {
  const _RailScopeNotice({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final (icon, text) = switch (state.status) {
      SessionStatus.loading => (
        Icons.sync_rounded,
        state.pendingGroup?.groupName == null
            ? s.navScopeLoading
            : s.navScopeSwitching(state.pendingGroup!.groupName!),
      ),
      SessionStatus.error => (
        Icons.error_outline_rounded,
        s.navScopeSwitchFailed,
      ),
      SessionStatus.ready || SessionStatus.empty
          when state.currentBook == null =>
        (Icons.menu_book_outlined, s.navScopeNoBook),
      _ => (Icons.lock_outline_rounded, s.navScopeReadOnlyHint),
    };
    return Semantics(
      label: text,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: palette.textSecondary),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
