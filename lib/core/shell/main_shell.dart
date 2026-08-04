import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// MainShell 的 tab 内容槽。各 feature 阶段落地后通过 [MainShellSlots.register] 注入
/// 真实页面 builder；未注入时显示占位，保证骨架先编译可跑。
class MainShellSlots {
  const MainShellSlots._();

  static WidgetBuilder? dashboard;
  static WidgetBuilder? bills;
  static WidgetBuilder? stats;
  static WidgetBuilder? profile;
}

/// 底部导航容器：4 tab + 中央 FAB 记一笔。IndexedStack 保活。
/// 首次进入时触发 SessionCubit.load() 拉取分组/账本。
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>();
    if (session.state.status == SessionStatus.initial) {
      session.load();
    }
  }

  Widget _slot(WidgetBuilder? builder, String label) {
    if (builder == null) {
      return Center(child: Text('$label（开发中）', style: FxTypography.label));
    }
    return Builder(builder: builder);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _slot(MainShellSlots.dashboard, '仪表盘'),
      _slot(MainShellSlots.bills, '账单'),
      _slot(MainShellSlots.stats, '统计'),
      _slot(MainShellSlots.profile, '我的'),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FxPalette.of(context).primary,
        elevation: 2,
        shape: const CircleBorder(),
        onPressed: () {
          HapticFeedback.selectionClick();
          AppRouter.push<void>(context, Routes.billEditor);
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _FxBottomBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
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
    return BottomAppBar(
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, 0, Icons.dashboard_rounded, '仪表盘'),
          _item(context, 1, Icons.receipt_long_rounded, '账单'),
          const SizedBox(width: 48), // FAB 缺口
          _item(context, 2, Icons.bar_chart_rounded, '统计'),
          _item(context, 3, Icons.person_rounded, '我的'),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int i, IconData icon, String label) {
    final palette = FxPalette.of(context);
    final selected = index == i;
    final color = selected ? palette.primary : palette.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(i);
        },
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
    );
  }
}
