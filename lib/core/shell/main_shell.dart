import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_permission.dart';
import 'package:fortuneboot/core/shell/bills_navigation_controller.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// MainShell 的 tab 内容槽。各 feature 阶段落地后通过 [MainShellSlots.register] 注入
/// 真实页面 builder；未注入时显示占位，保证骨架先编译可跑。
class MainShellSlots {
  const MainShellSlots._();

  static WidgetBuilder? dashboard;
  static WidgetBuilder? bills;
  static WidgetBuilder? stats;
  static WidgetBuilder? profile;
}

enum MainShellTab { dashboard, bills, stats, profile }

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
    HapticFeedback.selectionClick();
    final group = context.read<SessionCubit>().state.currentGroup;
    if (!SessionPermission.canWrite(group)) {
      FxFeedback.info(
        context,
        message: S.of(context).permissionVisitorNoAccess,
      );
      return;
    }
    AppRouter.push<void>(context, Routes.billEditor);
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final wide = MediaQuery.widthOf(context) >= _desktopBreakpoint;
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
    final content = SafeArea(
      top: false,
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: SizedBox(
            width: double.infinity,
            child: IndexedStack(index: _index, children: pages),
          ),
        ),
      ),
    );

    return BillsNavigationScope(
      controller: _billsNavigation,
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
                          child: FxButton(
                            label: s.dashboardQuickAdd,
                            icon: Icons.add_rounded,
                            expand: true,
                            onPressed: _openQuickAdd,
                          ),
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
        floatingActionButton: wide
            ? null
            : FloatingActionButton(
                tooltip: s.dashboardQuickAdd,
                onPressed: _openQuickAdd,
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                elevation: 0,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                height: 64,
                selectedIndex: _index,
                onDestinationSelected: (value) =>
                    _selectTab(MainShellTab.values[value]),
                backgroundColor: palette.surface,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                indicatorColor: palette.primaryContainer,
                destinations: [
                  for (final destination in destinations)
                    NavigationDestination(
                      icon: Icon(destination.$1),
                      selectedIcon: Icon(destination.$2),
                      label: destination.$3,
                    ),
                ],
              ),
      ),
    );
  }
}
