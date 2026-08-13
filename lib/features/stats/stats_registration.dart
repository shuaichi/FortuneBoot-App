import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/stats_assets_page.dart';
import 'package:fortuneboot/features/stats/presentation/stats_loans_page.dart';
import 'package:fortuneboot/features/stats/presentation/stats_page.dart';
import 'package:fortuneboot/features/stats/presentation/stats_policy_page.dart';

/// 统计 tab 注入入口。由 main.dart 在启动时统一调用（本文件不碰 main.dart）。
void registerStatsSlot() {
  MainShellSlots.stats = (context) {
    final session = context.read<SessionCubit>().state;
    final monthStartDay = context
        .read<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    return BlocProvider<StatsBloc>(
      create: (_) => StatsBloc(
        bookId: session.currentBookId,
        currencyCode: session.defaultCurrency,
        monthStartDay: monthStartDay,
      )..add(const StatsRefreshed()),
      child: const StatsPage(),
    );
  };

  AppRouter.register(Routes.statsAssets, (_) => const StatsAssetsPage());
  AppRouter.register(Routes.statsLoans, (_) => const StatsLoansPage());
  AppRouter.register(Routes.statsPolicy, (_) => const StatsPolicyPage());
}
