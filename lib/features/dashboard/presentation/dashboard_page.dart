import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/assets_donut_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/category_top_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_top_bar.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/month_stat_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/net_worth_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/quick_add_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/recent_bills_card.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/trend_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/layout/fx_bento_grid.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 看板首页：粘顶栏 + Bento 卡片网格。订阅 SessionCubit 切账本重拉。
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 监听账本/分组切换,驱动 Bloc 重拉。
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, next) =>
          prev.currentBookId != next.currentBookId ||
          prev.currentGroupId != next.currentGroupId,
      listener: (context, session) {
        context.read<DashboardBloc>().add(
          DashboardBookChanged(
            bookId: session.currentBookId,
            groupId: session.currentGroupId,
          ),
        );
      },
      child: BlocListener<PreferencesCubit, PreferencesState>(
        listenWhen: (prev, next) =>
            prev.billing.monthStartDay != next.billing.monthStartDay,
        listener: (context, preferences) {
          context.read<DashboardBloc>().add(
            DashboardMonthStartDayChanged(preferences.billing.monthStartDay),
          );
        },
        child: _MutationRefresher(
          child: Scaffold(
            backgroundColor: FxPalette.of(context).canvas,
            body: Column(
              children: [
                const DashboardTopBar(),
                Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 监听全局账单变更（中央 FAB 记账、Bills 删除等），驱动看板重拉。
class _MutationRefresher extends StatefulWidget {
  const _MutationRefresher({required this.child});
  final Widget child;

  @override
  State<_MutationRefresher> createState() => _MutationRefresherState();
}

class _MutationRefresherState extends State<_MutationRefresher> {
  @override
  void initState() {
    super.initState();
    BillMutations.revision.addListener(_onMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onMutation);
    super.dispose();
  }

  void _onMutation() {
    if (mounted) {
      context.read<DashboardBloc>().add(const DashboardRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (!state.hasBook) {
          return FxStateView.empty(message: '请先选择一个账本');
        }

        final bloc = context.read<DashboardBloc>();
        void retry() => bloc.add(const DashboardRefreshed());
        final currency = state.currencyCode;
        final emptyUser = state.isEmptyUser;

        final tiles = <FxBentoTile>[
          // ① 净资产大卡(跨2列2行)
          FxBentoTile(
            colSpan: 2,
            rowSpan: 2,
            child: NetWorthCard(
              section: state.assets,
              currencyCode: currency,
              emptyUser: emptyUser,
              onRetry: retry,
            ),
          ),
        ];

        if (emptyUser) {
          // 空态：净资产引导 + 放大的快捷记账;隐藏趋势/Top3。
          tiles.add(
            const FxBentoTile(
              colSpan: 2,
              rowSpan: 2,
              child: QuickAddCard(enlarged: true),
            ),
          );
        } else {
          // ② 本月支出 ③ 本月收入
          tiles.add(
            FxBentoTile(
              child: MonthStatCard(
                section: state.monthStats,
                currencyCode: currency,
                isExpense: true,
                onRetry: retry,
              ),
            ),
          );
          tiles.add(
            FxBentoTile(
              child: MonthStatCard(
                section: state.monthStats,
                currencyCode: currency,
                isExpense: false,
                onRetry: retry,
              ),
            ),
          );
          // ④ 收支趋势(1格,rowSpan2)
          tiles.add(
            FxBentoTile(
              rowSpan: 2,
              child: TrendCard(section: state.trends, onRetry: retry),
            ),
          );
          // ⑤ 资产负债环
          tiles.add(
            FxBentoTile(
              child: AssetsDonutCard(
                section: state.assets,
                currencyCode: currency,
                onRetry: retry,
              ),
            ),
          );
          // ⑥ 快捷记账
          tiles.add(const FxBentoTile(child: QuickAddCard()));
        }

        // ⑦ 最近账单(跨满)
        tiles.add(
          FxBentoTile(
            colSpan: FxBentoTile.fullSpan,
            rowSpan: 2,
            child: RecentBillsCard(
              section: state.recentBills,
              currencyCode: currency,
              onRetry: retry,
            ),
          ),
        );

        // ⑧ 分类 Top3(跨满,可选:无数据整卡隐藏)
        final showCategories =
            !emptyUser &&
            (!state.categories.isReady ||
                (state.categories.data?.isNotEmpty ?? false));
        if (showCategories) {
          tiles.add(
            FxBentoTile(
              colSpan: FxBentoTile.fullSpan,
              rowSpan: 2,
              child: CategoryTopCard(
                section: state.categories,
                currencyCode: currency,
                onRetry: retry,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const DashboardRefreshed());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [FxBentoGrid(tiles: tiles)],
          ),
        );
      },
    );
  }
}
