import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_chart_table_toggle.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_load_error.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/fx/components/fx_bar_chart.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
    if (!mounted) return;
    _reload();
  }

  Future<_LoansStatsData> _load(int version) async {
    final session = context.read<SessionCubit>().state;
    final bookId = session.currentBookId;
    final currencyCode = session.defaultCurrency;
    if (bookId == null) {
      return _LoansStatsData(hasBook: false, currencyCode: currencyCode);
    }
    try {
      final results = await Future.wait<Object>([
        _service.getLoanOverview(bookId: bookId),
        _service.getFinanceProfit(bookId: bookId),
      ]);
      if (version != _loadVersion) {
        return _LoansStatsData(
          bookId: bookId,
          currencyCode: currencyCode,
          isStale: true,
        );
      }
      return _LoansStatsData(
        bookId: bookId,
        currencyCode: currencyCode,
        loan: results[0] as LoanOverview,
        profit: results[1] as FinanceProfit,
      );
    } on Object catch (error) {
      throw StatsLoadError.from(error);
    }
  }

  Future<void> _reload() {
    final next = _load(++_loadVersion);
    setState(() {
      _future = next;
    });
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hideAmounts = context.select(
      (PreferencesCubit cubit) => cubit.state.dashboard.hideAmounts,
    );
    return StatsPrivacy(
      hideAmounts: hideAmounts,
      child: BlocListener<SessionCubit, SessionState>(
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
          body: FutureBuilder<_LoansStatsData>(
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
                  padding: const EdgeInsets.fromLTRB(
                    FxSpacing.lg,
                    FxSpacing.lg,
                    FxSpacing.lg,
                    FxSpacing.xxxl,
                  ),
                  children: [
                    _LoanOverviewCard(
                      loan: data.loan,
                      currencyCode: data.currencyCode,
                    ),
                    const SizedBox(height: FxSpacing.md),
                    _FinanceProfitCard(
                      profit: data.profit,
                      currencyCode: data.currencyCode,
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
  final LoanOverview loan;
  final FinanceProfit profit;

  const _LoansStatsData({
    this.hasBook = true,
    this.isStale = false,
    this.bookId,
    this.currencyCode,
    this.loan = const LoanOverview(),
    this.profit = const FinanceProfit(),
  });
}

class _LoanOverviewCard extends StatelessWidget {
  final LoanOverview loan;
  final String? currencyCode;

  const _LoanOverviewCard({required this.loan, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    final stockItems = [
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
    ];
    final hasStock = stockItems.any((item) => item.value > 0);
    final summary =
        '${S.of(context).statsLoanOverview}: '
        '${S.of(context).statsLoanReceivable} '
        '${formats.money(loan.totalLoanReceivable)}, '
        '${S.of(context).statsLoanPayable} '
        '${formats.money(loan.totalLoanPayable)}';
    return FxCard(
      child: Semantics(
        label: summary,
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
                    currencyCode: currencyCode,
                    color: finance.income,
                  ),
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: _AmountMetric(
                    label: S.of(context).statsLoanPayable,
                    amount: loan.totalLoanPayable,
                    count: loan.payableBillCount,
                    currencyCode: currencyCode,
                    color: finance.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FxSpacing.lg),
            if (!hasStock)
              _InlineEmpty(message: S.of(context).statsNoRecordsThisPeriod)
            else
              SizedBox(
                height: 240,
                child: StatsChartTableToggle(
                  rows: [
                    for (final item in stockItems)
                      StatsChartTableRow(
                        label: item.name,
                        value: formats.money(item.value),
                        color: item.color,
                        icon: Icons.bar_chart_rounded,
                      ),
                  ],
                  chart: FxBarChart(
                    height: 180,
                    topN: 2,
                    items: stockItems,
                    locale: formats.locale,
                    visibility: formats.visibility,
                    valueFormatter: formats.chartValue,
                    accessibilityLabels: [
                      for (final item in stockItems)
                        '${item.name}: ${formats.money(item.value)}',
                    ],
                  ),
                ),
              ),
            const SizedBox(height: FxSpacing.md),
            _OverdueRiskRow(loan: loan, currencyCode: currencyCode),
            const SizedBox(height: FxSpacing.md),
            _CaptionMetric(
              label: S.of(context).statsPendingConfirm,
              value: loan.pendingConfirmCount.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceProfitCard extends StatelessWidget {
  final FinanceProfit profit;
  final String? currencyCode;

  const _FinanceProfitCard({required this.profit, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
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
                  currencyCode: currencyCode,
                  color: finance.income,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: _AmountMetric(
                  label: S.of(context).statsLoss,
                  amount: profit.totalLoss,
                  count: profit.lossBillCount,
                  currencyCode: currencyCode,
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
              currencyCode: currencyCode,
              fontSize: 18,
              color: profit.netProfit >= 0 ? finance.income : finance.expense,
              masked: formats.masked,
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
                    currencyCode: currencyCode,
                    fontSize: 14,
                    colorBySign: true,
                    masked: formats.masked,
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

class _OverdueRiskRow extends StatelessWidget {
  const _OverdueRiskRow({required this.loan, required this.currencyCode});

  final LoanOverview loan;
  final String? currencyCode;

  @override
  Widget build(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    return Row(
      children: [
        Expanded(
          child: _RiskMetric(
            label: S.of(context).statsOverdueReceivable,
            amount: loan.overdueReceivable,
            currencyCode: currencyCode,
            color: finance.adjust,
          ),
        ),
        const SizedBox(width: FxSpacing.md),
        Expanded(
          child: _RiskMetric(
            label: S.of(context).statsOverduePayable,
            amount: loan.overduePayable,
            currencyCode: currencyCode,
            color: finance.transfer,
          ),
        ),
      ],
    );
  }
}

class _RiskMetric extends StatelessWidget {
  const _RiskMetric({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.color,
  });

  final String label;
  final double amount;
  final String? currencyCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    return Container(
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: color),
          const SizedBox(width: FxSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          FxMoneyText(
            amount: amount,
            currencyCode: currencyCode,
            fontSize: 13,
            color: color,
            masked: formats.masked,
          ),
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
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
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
            masked: formats.masked,
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

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: FxSpacing.xl),
    child: Center(
      child: Text(
        message,
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      ),
    ),
  );
}
