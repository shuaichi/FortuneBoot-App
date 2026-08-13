import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
import 'package:fortuneboot/fx/components/fx_bar_chart.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class StatsLoansPage extends StatefulWidget {
  const StatsLoansPage({super.key});

  @override
  State<StatsLoansPage> createState() => _StatsLoansPageState();
}

class _StatsLoansPageState extends State<StatsLoansPage> {
  final StatsService _service = StatsService();
  late Future<_LoansStatsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_LoansStatsData> _load() async {
    final bookId = context.read<SessionCubit>().state.currentBookId;
    if (bookId == null) return const _LoansStatsData(hasBook: false);
    try {
      final results = await Future.wait<Object>([
        _service.getLoanOverview(bookId: bookId),
        _service.getFinanceProfit(bookId: bookId),
      ]);
      return _LoansStatsData(
        loan: results[0] as LoanOverview,
        profit: results[1] as FinanceProfit,
      );
    } on FxApiException catch (e) {
      throw e.message;
    }
  }

  Future<void> _reload() {
    final next = _load();
    setState(() {
      _future = next;
    });
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        title: Text(S.of(context).statsLoansTitle),
        backgroundColor: palette.canvas,
      ),
      body: FutureBuilder<_LoansStatsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return FxStateView.loading();
          }
          if (snapshot.hasError) {
            return FxStateView.error(
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final data = snapshot.data ?? const _LoansStatsData();
          if (!data.hasBook) {
            return FxStateView.empty(
              message: S.of(context).statsSelectBookFirst,
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.lg,
                FxSpacing.lg,
                FxSpacing.xxxl,
              ),
              children: [
                _LoanOverviewCard(loan: data.loan),
                const SizedBox(height: FxSpacing.md),
                _FinanceProfitCard(profit: data.profit),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoansStatsData {
  final bool hasBook;
  final LoanOverview loan;
  final FinanceProfit profit;

  const _LoansStatsData({
    this.hasBook = true,
    this.loan = const LoanOverview(),
    this.profit = const FinanceProfit(),
  });
}

class _LoanOverviewCard extends StatelessWidget {
  final LoanOverview loan;

  const _LoanOverviewCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SessionCubit>().state.defaultCurrency;
    final finance = FxFinanceColors.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsLoanOverview),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: _AmountMetric(
                  label: S.of(context).statsLoanReceivable,
                  amount: loan.totalLoanReceivable,
                  count: loan.receivableBillCount,
                  currencyCode: currency,
                  color: finance.income,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: _AmountMetric(
                  label: S.of(context).statsLoanPayable,
                  amount: loan.totalLoanPayable,
                  count: loan.payableBillCount,
                  currencyCode: currency,
                  color: finance.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          FxBarChart(
            height: 180,
            topN: 4,
            items: [
              FxBarItem(
                name: S.of(context).statsLoanReceivable,
                value: loan.totalLoanReceivable,
                color: finance.income,
              ),
              FxBarItem(
                name: S.of(context).statsLoanPayable,
                value: loan.totalLoanPayable,
                color: finance.expense,
              ),
              FxBarItem(
                name: S.of(context).statsOverdueReceivable,
                value: loan.overdueReceivable,
                color: finance.adjust,
              ),
              FxBarItem(
                name: S.of(context).statsOverduePayable,
                value: loan.overduePayable,
                color: finance.transfer,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          _CaptionMetric(
            label: S.of(context).statsPendingConfirm,
            value: loan.pendingConfirmCount.toString(),
          ),
        ],
      ),
    );
  }
}

class _FinanceProfitCard extends StatelessWidget {
  final FinanceProfit profit;

  const _FinanceProfitCard({required this.profit});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SessionCubit>().state.defaultCurrency;
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsFinanceProfit),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: _AmountMetric(
                  label: S.of(context).statsProfit,
                  amount: profit.totalProfit,
                  count: profit.profitBillCount,
                  currencyCode: currency,
                  color: finance.income,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: _AmountMetric(
                  label: S.of(context).statsLoss,
                  amount: profit.totalLoss,
                  count: profit.lossBillCount,
                  currencyCode: currency,
                  color: finance.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          _CaptionMetric(
            label: S.of(context).statsNetProfit,
            valueWidget: FxMoneyText(
              amount: profit.netProfit,
              currencyCode: currency,
              fontSize: 18,
              color: profit.netProfit >= 0 ? finance.income : finance.expense,
            ),
          ),
          const SizedBox(height: FxSpacing.lg),
          if (profit.items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FxSpacing.xl),
                child: Text(
                  S.of(context).statsNoRecordsThisPeriod,
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
              ),
            )
          else
            for (final item in profit.items.take(5)) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title.isEmpty
                          ? S.of(context).dashboardBillFallback
                          : item.title,
                      style: FxTypography.bodyStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FxMoneyText(
                    amount: item.amount,
                    currencyCode: currency,
                    fontSize: 14,
                    colorBySign: true,
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _AmountMetric extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final String? currencyCode;
  final Color color;

  const _AmountMetric({
    required this.label,
    required this.amount,
    required this.count,
    required this.currencyCode,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FxTypography.caption.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(
            amount: amount,
            currencyCode: currencyCode,
            fontSize: 18,
            color: color,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).statsBillCount(count),
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _CaptionMetric extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _CaptionMetric({this.value, this.valueWidget, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Row(
      children: [
        Text(
          label,
          style: FxTypography.caption.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(width: FxSpacing.sm),
        valueWidget ??
            Text(
              value ?? '-',
              style: FxTypography.bodyStrong.copyWith(
                color: palette.textPrimary,
              ),
            ),
      ],
    );
  }
}
