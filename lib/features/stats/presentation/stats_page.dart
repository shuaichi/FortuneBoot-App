import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/stats/presentation/bloc/stats_bloc.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_overview_bar.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_pie_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_tag_card.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_top_bar.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_trend_card.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 统计图表页：时间区间 + 支/收分段（全页联动）+ 概览条 + 图表卡。
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
    var refreshVersion = 0;
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (!state.hasBook) {
          return FxStateView.empty(message: S.of(context).statsSelectBookFirst);
        }

        final bloc = context.read<StatsBloc>();
        void retry() => bloc.add(const StatsRefreshed());
        final currency = state.currencyCode;
        final hideAmounts = context.select(
          (PreferencesCubit cubit) => cubit.state.dashboard.hideAmounts,
        );

        return StatsPrivacy(
          hideAmounts: hideAmounts,
          child: RefreshIndicator(
            onRefresh: () async {
              final current = ++refreshVersion;
              bloc.add(const StatsRefreshed());
              await bloc.stream.firstWhere(
                (next) =>
                    current == refreshVersion &&
                    next.overview.status != StatsSectionStatus.loading &&
                    next.trends.status != StatsSectionStatus.loading &&
                    next.categories.status != StatsSectionStatus.loading &&
                    next.tags.status != StatsSectionStatus.loading &&
                    next.payees.status != StatsSectionStatus.loading,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.sm,
                FxSpacing.lg,
                FxSpacing.xxxl,
              ),
              children: [
                const _StatsEntryCard(),
                const SizedBox(height: FxSpacing.md),
                StatsOverviewBar(
                  section: state.overview,
                  currencyCode: currency,
                ),
                const SizedBox(height: FxSpacing.md),
                StatsIncomeExpenseCalendarCard(
                  section: state.calendar,
                  view: state.calendarView,
                  anchor: state.calendarAnchor,
                  currencyCode: currency,
                  onViewChanged: (view) =>
                      bloc.add(StatsCalendarViewChanged(view)),
                  onNavigate: (delta) => bloc.add(StatsCalendarNavigate(delta)),
                  onDrillDown: (view, anchor) => bloc.add(
                    StatsCalendarDrilledDown(view: view, anchor: anchor),
                  ),
                  onRetry: () => bloc.add(const StatsCalendarRetried()),
                ),
                const SizedBox(height: FxSpacing.md),
                _StatsInsightCard(state: state, currencyCode: currency),
                const SizedBox(height: FxSpacing.md),
                _StatsDimensionPreviewCard(
                  state: state,
                  currencyCode: currency,
                ),
                const SizedBox(height: FxSpacing.md),
                StatsTrendCard(
                  section: state.trends,
                  type: state.type,
                  currencyCode: currency,
                  onRetry: retry,
                ),
                const SizedBox(height: FxSpacing.md),
                StatsPieCard(
                  label: _categoryLabel(context, state.type),
                  section: state.categories,
                  currencyCode: currency,
                  onRetry: retry,
                ),
                const SizedBox(height: FxSpacing.md),
                StatsTagCard(
                  label: _tagLabel(context, state.type),
                  section: state.tags,
                  currencyCode: currency,
                  onRetry: retry,
                ),
                const SizedBox(height: FxSpacing.md),
                StatsPieCard(
                  label: _payeeLabel(context, state.type),
                  section: state.payees,
                  currencyCode: currency,
                  onRetry: retry,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _analyticsLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpenseAnalytics
    : S.of(context).statsIncomeAnalytics;

String _categoryLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpenseCategoryShare
    : S.of(context).statsIncomeCategoryShare;

String _tagLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpenseTags
    : S.of(context).statsIncomeTags;

String _payeeLabel(BuildContext context, StatsType type) =>
    type == StatsType.expense
    ? S.of(context).statsExpensePayees
    : S.of(context).statsIncomePayees;

class _StatsEntryCard extends StatelessWidget {
  const _StatsEntryCard();

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsMoreReports),
          const SizedBox(height: FxSpacing.sm),
          FxListItem(
            leading: _entryIcon(
              Icons.account_balance_wallet_rounded,
              finance.income,
            ),
            title: S.of(context).statsAssetsTitle,
            subtitle: S.of(context).statsAssetsEntrySubtitle,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.statsAssets),
          ),
          const Divider(height: FxSpacing.lg),
          FxListItem(
            leading: _entryIcon(Icons.savings_rounded, finance.transfer),
            title: S.of(context).statsLoansTitle,
            subtitle: S.of(context).statsLoansEntrySubtitle,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.statsLoans),
          ),
          const Divider(height: FxSpacing.lg),
          FxListItem(
            leading: _entryIcon(Icons.policy_rounded, palette.primary),
            title: S.of(context).statsPolicyTitle,
            subtitle: S.of(context).statsPolicyEntrySubtitle,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.statsPolicy),
          ),
        ],
      ),
    );
  }

  static Widget _entryIcon(IconData icon, Color tint) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: tint, size: 20),
    );
  }
}

class _StatsInsightCard extends StatelessWidget {
  final StatsState state;
  final String? currencyCode;

  const _StatsInsightCard({required this.state, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final stats = state.overview.data;
    if (stats == null) return const SizedBox.shrink();
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final totalFlow = stats.income + stats.expense;
    final expenseRatio = totalFlow <= 0 ? 0.0 : stats.expense / totalFlow;
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsBasicTitle),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InsightAmount(
                  label: S.of(context).statsExpense,
                  amount: stats.expense,
                  color: finance.expense,
                  currencyCode: currencyCode,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: _InsightAmount(
                  label: S.of(context).statsIncome,
                  amount: stats.income,
                  color: finance.income,
                  currencyCode: currencyCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          FxProgressBar(value: expenseRatio, color: finance.expense, height: 7),
          const SizedBox(height: FxSpacing.xs),
          Text(
            '${S.of(context).statsExpense} ${formats.percent(expenseRatio * 100)} · ${S.of(context).statsSurplus}',
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(
            amount: stats.surplus,
            currencyCode: currencyCode,
            showSign: true,
            colorBySign: true,
            fontSize: 14,
            masked: formats.masked,
          ),
        ],
      ),
    );
  }
}

class _StatsDimensionPreviewCard extends StatelessWidget {
  final StatsState state;
  final String? currencyCode;

  const _StatsDimensionPreviewCard({
    required this.state,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final category = state.categories.data
        ?.where((e) => e.value > 0)
        .firstOrNull;
    final tag = state.tags.data?.where((e) => e.value > 0).firstOrNull;
    final payee = state.payees.data?.where((e) => e.value > 0).firstOrNull;
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(_analyticsLabel(context, state.type)),
          const SizedBox(height: FxSpacing.md),
          _DimensionRow(
            title: _categoryLabel(context, state.type),
            name: category?.name,
            amount: category?.value,
            percent: category?.percent,
            currencyCode: currencyCode,
          ),
          const Divider(height: FxSpacing.lg),
          _DimensionRow(
            title: _tagLabel(context, state.type),
            name: tag?.name,
            amount: tag?.value,
            percent: tag?.percent,
            currencyCode: currencyCode,
          ),
          const Divider(height: FxSpacing.lg),
          _DimensionRow(
            title: _payeeLabel(context, state.type),
            name: payee?.name,
            amount: payee?.value,
            percent: payee?.percent,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).statsPolicyEntrySubtitle,
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _InsightAmount extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String? currencyCode;

  const _InsightAmount({
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final masked = StatsPrivacy.hideAmountsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
        const SizedBox(height: FxSpacing.xs),
        FxMoneyText(
          amount: amount,
          currencyCode: currencyCode,
          color: color,
          fontSize: 18,
          masked: masked,
        ),
      ],
    );
  }
}

class _DimensionRow extends StatelessWidget {
  final String title;
  final String? name;
  final double? amount;
  final double? percent;
  final String? currencyCode;

  const _DimensionRow({
    required this.title,
    required this.name,
    required this.amount,
    required this.percent,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final displayName = name == null || name!.isEmpty
        ? S.of(context).statsNoRecordsThisPeriod
        : name!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              const SizedBox(height: FxSpacing.xs),
              Text(
                displayName,
                style: FxTypography.bodyStrong.copyWith(
                  color: palette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (amount != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FxMoneyText(
                amount: amount!,
                currencyCode: currencyCode,
                fontSize: 13,
                color: palette.textPrimary,
                masked: formats.masked,
              ),
              if (percent != null)
                Text(
                  formats.percent(percent!),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
