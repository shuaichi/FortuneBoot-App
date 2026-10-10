import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_load_error.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 借贷总览。待收/待还/待报销读取 V2 summary；旧 profit 仅展示已归档借款收支。
class StatsLoansPage extends StatefulWidget {
  const StatsLoansPage({super.key, StatsService? statsService})
    : _statsService = statsService;

  final StatsService? _statsService;

  @override
  State<StatsLoansPage> createState() => _StatsLoansPageState();
}

class _StatsLoansPageState extends State<StatsLoansPage> {
  late final StatsService _service;
  late Future<_LoansStatsData> _future;
  var _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _service = widget._statsService ?? StatsService();
    BillMutations.revision.addListener(_onExternalMutation);
    _future = _load(++_loadVersion);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onExternalMutation);
    super.dispose();
  }

  void _onExternalMutation() {
    if (mounted) _reload();
  }

  Future<_LoansStatsData> _load(int version) async {
    final session = context.read<SessionCubit>().state;
    final bookId = session.currentBookId;
    if (bookId == null) {
      return _LoansStatsData(
        hasBook: false,
        currencyCode: session.defaultCurrency,
      );
    }
    try {
      final results = await Future.wait<Object>([
        _service.getFinanceOrderSummary(bookId: bookId),
        _service.getFinanceProfit(bookId: bookId),
      ]);
      if (version != _loadVersion) {
        return _LoansStatsData(
          bookId: bookId,
          currencyCode: session.defaultCurrency,
          isStale: true,
        );
      }
      return _LoansStatsData(
        bookId: bookId,
        currencyCode: session.defaultCurrency,
        summary: results[0] as FinanceOrderSummary,
        profit: results[1] as FinanceProfit,
      );
    } on Object catch (error) {
      throw StatsLoadError.from(error);
    }
  }

  Future<void> _reload() {
    final next = _load(++_loadVersion);
    setState(() => _future = next);
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hideAmounts = context.select<PreferencesCubit, bool>(
      (cubit) => cubit.state.dashboard.hideAmounts,
    );
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (previous, current) =>
          previous.currentBookId != current.currentBookId ||
          previous.defaultCurrency != current.defaultCurrency,
      listener: (_, _) => _reload(),
      child: Scaffold(
        backgroundColor: palette.canvas,
        appBar: AppBar(
          title: Text(S.of(context).statsLoansTitle),
          backgroundColor: palette.canvas,
        ),
        body: SafeArea(
          child: FutureBuilder<_LoansStatsData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return FxStateView.loading();
              }
              if (snapshot.hasError) {
                return FxStateView.error(
                  message: statsLoadErrorMessage(context, snapshot.error),
                  onRetry: _reload,
                  retryLabel: S.of(context).commonRetry,
                );
              }
              final data = snapshot.data ?? const _LoansStatsData();
              if (data.isStale) return FxStateView.loading();
              if (!data.hasBook) {
                return FxStateView.empty(
                  message: S.of(context).statsSelectBookFirst,
                );
              }
              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  children: [
                    _SummaryCard(
                      summary: data.summary!,
                      currencyCode: data.currencyCode,
                      hideAmounts: hideAmounts,
                    ),
                    const SizedBox(height: FxSpacing.md),
                    _ArchivedProfitCard(
                      profit: data.profit,
                      currencyCode: data.currencyCode,
                      hideAmounts: hideAmounts,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoansStatsData {
  final bool hasBook;
  final bool isStale;
  final int? bookId;
  final String? currencyCode;
  final FinanceOrderSummary? summary;
  final FinanceProfit? profit;

  const _LoansStatsData({
    this.hasBook = true,
    this.isStale = false,
    this.bookId,
    this.currencyCode,
    this.summary,
    this.profit,
  });
}

class _SummaryCard extends StatelessWidget {
  final FinanceOrderSummary summary;
  final String? currencyCode;
  final bool hideAmounts;

  const _SummaryCard({
    required this.summary,
    required this.currencyCode,
    required this.hideAmounts,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).statsLoanOverview, style: FxTypography.title),
          const SizedBox(height: FxSpacing.md),
          _metric(
            context,
            S.of(context).ordersPendingReceivable,
            summary.receivableAmount,
          ),
          _metric(
            context,
            S.of(context).ordersPendingPayable,
            summary.payableAmount,
          ),
          _metric(
            context,
            S.of(context).ordersPendingReimbursement,
            summary.reimbursementAmount,
          ),
          const Divider(height: FxSpacing.lg),
          _metric(
            context,
            S.of(context).ordersOverdueReceivable,
            summary.overdueReceivableAmount,
          ),
          _metric(
            context,
            S.of(context).ordersOverduePayable,
            summary.overduePayableAmount,
          ),
          _metric(
            context,
            S.of(context).ordersOverdueReimbursement,
            summary.overdueReimbursementAmount,
          ),
          const SizedBox(height: FxSpacing.sm),
          Text(
            S.of(context).statsLoanPendingCount(summary.pendingEntryCount),
            style: FxTypography.caption.copyWith(color: palette.textSecondary),
          ),
          if (summary.reviewRequiredCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: FxSpacing.xs),
              child: Text(
                S
                    .of(context)
                    .ordersReviewRequiredCount(summary.reviewRequiredCount),
                style: FxTypography.caption.copyWith(color: palette.warning),
              ),
            ),
          if (summary.orphanLegacyBillCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: FxSpacing.xs),
              child: Text(
                S
                    .of(context)
                    .ordersOrphanLegacyCount(summary.orphanLegacyBillCount),
                style: FxTypography.caption.copyWith(color: palette.warning),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, OrderMoney? amount) {
    final cents = amount?.cents;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            cents == null ? S.of(context).ordersAmountUnknown : _format(cents),
          ),
        ],
      ),
    );
  }

  String _format(int cents) =>
      hideAmounts ? '****' : (cents / 100).toStringAsFixed(2);
}

class _ArchivedProfitCard extends StatelessWidget {
  final FinanceProfit? profit;
  final String? currencyCode;
  final bool hideAmounts;

  const _ArchivedProfitCard({
    required this.profit,
    required this.currencyCode,
    required this.hideAmounts,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).statsArchivedLoanIncomeExpense,
            style: FxTypography.title,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).statsArchivedLoanNote,
            style: FxTypography.caption,
          ),
          const SizedBox(height: FxSpacing.md),
          Text(
            hideAmounts ? '****' : (profit?.netProfit ?? 0).toStringAsFixed(2),
            style: FxTypography.money,
          ),
        ],
      ),
    );
  }
}
