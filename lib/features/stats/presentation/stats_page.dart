import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_overview_bar.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_pie_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_tag_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_top_bar.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_trend_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 统计图表页：时间区间 + 支/收分段（全页联动）+ 概览条 + 4 图表卡。
/// 订阅 SessionCubit 切账本重拉，并监听 BillMutations 在记账/编辑后刷新。
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    BillMutations.revision.addListener(_onExternalMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onExternalMutation);
    super.dispose();
  }

  /// 外部（中央 FAB 记账、编辑、确认/计入切换等）账单变更 → 重拉统计。
  void _onExternalMutation() {
    if (mounted) context.read<StatsBloc>().add(const StatsRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (prev, next) => prev.currentBookId != next.currentBookId,
      listener: (context, session) {
        context.read<StatsBloc>().add(
          StatsBookChanged(bookId: session.currentBookId),
        );
      },
      child: BlocListener<PreferencesCubit, PreferencesState>(
        listenWhen: (prev, next) =>
            prev.billing.monthStartDay != next.billing.monthStartDay,
        listener: (context, preferences) {
          context.read<StatsBloc>().add(
            StatsMonthStartDayChanged(preferences.billing.monthStartDay),
          );
        },
        child: Scaffold(
          backgroundColor: FxPalette.of(context).canvas,
          body: Column(
            children: [
              const StatsTopBar(),
              Expanded(child: _Body()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (!state.hasBook) {
          return FxStateView.empty(message: '请先选择一个账本');
        }

        final bloc = context.read<StatsBloc>();
        void retry() => bloc.add(const StatsRefreshed());
        final currency = state.currencyCode;

        return RefreshIndicator(
          onRefresh: () async => bloc.add(const StatsRefreshed()),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.xxxl,
            ),
            children: [
              StatsOverviewBar(section: state.overview, currencyCode: currency),
              const SizedBox(height: FxSpacing.md),
              StatsTrendCard(
                section: state.trends,
                type: state.type,
                onRetry: retry,
              ),
              const SizedBox(height: FxSpacing.md),
              StatsPieCard(
                label: '分类占比',
                section: state.categories,
                currencyCode: currency,
                onRetry: retry,
              ),
              const SizedBox(height: FxSpacing.md),
              StatsTagCard(section: state.tags, onRetry: retry),
              const SizedBox(height: FxSpacing.md),
              StatsPieCard(
                label: '交易对象',
                section: state.payees,
                currencyCode: currency,
                onRetry: retry,
              ),
            ],
          ),
        );
      },
    );
  }
}
