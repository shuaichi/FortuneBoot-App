import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/bills_navigation_controller.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
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

/// 底部导航容器：4 tab + 中央 FAB 记一笔。IndexedStack 保活。
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
    if (session.state.status == SessionStatus.initial) {
      unawaited(session.load());
    }
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pages = [
      _slot(MainShellSlots.dashboard, s.navDashboard),
      _slot(MainShellSlots.bills, s.navBills),
      _slot(MainShellSlots.stats, s.navStats),
      _slot(MainShellSlots.profile, s.navProfile),
    ];

    return BillsNavigationScope(
      controller: _billsNavigation,
      child: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        floatingActionButton: FloatingActionButton(
          tooltip: s.dashboardQuickAdd,
          backgroundColor: FxPalette.of(context).primary,
          foregroundColor: FxPalette.of(context).onPrimary,
          elevation: 2,
          shape: const CircleBorder(),
          onPressed: () {
            HapticFeedback.selectionClick();
            AppRouter.push<void>(context, Routes.billEditor);
          },
          child: const Icon(Icons.add_rounded, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _FxBottomBar(
          index: _index,
          onChanged: (index) => _selectTab(MainShellTab.values[index]),
        ),
      ),
    );
  }
}

class _FxBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _FxBottomBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return BottomAppBar(
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(context, 0, Icons.dashboard_rounded, s.navDashboard),
              _item(context, 1, Icons.receipt_long_rounded, s.navBills),
              const SizedBox(width: 48), // FAB 缺口
              _item(context, 2, Icons.bar_chart_rounded, s.navStats),
              _item(context, 3, Icons.person_rounded, s.navProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, IconData icon, String label) {
    final palette = FxPalette.of(context);
    final selected = index == i;
    final color = selected ? palette.primary : palette.textTertiary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(i);
            },
            child: SizedBox(
              height: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: FxTypography.caption.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
