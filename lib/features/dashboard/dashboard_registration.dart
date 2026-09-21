import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/dashboard_page.dart';

/// 看板 tab 注入入口。由 main.dart 在启动时统一调用（本文件不碰 main.dart）。
void registerDashboardSlot() {
  MainShellSlots.dashboard = (context) {
    final session = context.read<SessionCubit>().state;
    final monthStartDay = context
        .read<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    return BlocProvider<DashboardBloc>(
      create: (_) => DashboardBloc(
        bookId: session.currentBookId,
        groupId: session.currentGroupId,
        currencyCode: session.defaultCurrency,
        monthStartDay: monthStartDay,
      )..add(const DashboardRefreshed()),
      child: const DashboardPage(),
    );
  };
}
