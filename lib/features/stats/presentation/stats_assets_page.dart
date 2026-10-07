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
import 'package:fortuneboot/features/stats/presentation/widgets/stats_palette.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_privacy.dart';
import 'package:fortuneboot/fx/components/fx_bar_chart.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_donut_chart.dart';
import 'package:fortuneboot/fx/components/fx_line_chart.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class StatsAssetsPage extends StatefulWidget {
  const StatsAssetsPage({super.key, StatsService? statsService})
    : _statsService = statsService;

  final StatsService? _statsService;

  @override
  State<StatsAssetsPage> createState() => _StatsAssetsPageState();
}

class _StatsAssetsPageState extends State<StatsAssetsPage> {
  late final StatsService _service;
  late Future<_AssetsStatsData> _future;
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

  Future<_AssetsStatsData> _load(int version) async {
    final session = context.read<SessionCubit>().state;
    final groupId = session.currentGroupId;
    final currencyCode = session.defaultCurrency;
    if (groupId == null) {
      return _AssetsStatsData(hasGroup: false, currencyCode: currencyCode);
    }
    try {
      final results = await Future.wait<Object>([
        _service.getTotalAssets(groupId: groupId),
        _service.getTotalLiabilities(groupId: groupId),
        _service.getNetAssetsTrend(groupId: groupId),
        _service.getAssetsByAccountType(groupId: groupId),
        _service.getCreditCardOverview(groupId: groupId),
      ]);
      if (version != _loadVersion) {
        return _AssetsStatsData(
          groupId: groupId,
          currencyCode: currencyCode,
          isStale: true,
        );
      }
      return _AssetsStatsData(
        groupId: groupId,
        currencyCode: currencyCode,
        assets: results[0] as List<PieSlice>,
        liabilities: results[1] as List<PieSlice>,
        trends: results[2] as List<NetAssetsTrendPoint>,
        accountTypes: results[3] as List<AssetsByAccountType>,
        creditCards: results[4] as List<CreditCardOverview>,
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
            previous.currentGroupId != current.currentGroupId ||
            previous.defaultCurrency != current.defaultCurrency,
        listener: (_, _) => _reload(),
        child: Scaffold(
          backgroundColor: palette.canvas,
          appBar: AppBar(
            title: Text(S.of(context).statsAssetsTitle),
            backgroundColor: palette.canvas,
          ),
          body: FutureBuilder<_AssetsStatsData>(
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
              final data = snapshot.data ?? const _AssetsStatsData();
              if (data.isStale) return FxStateView.loading();
              if (!data.hasGroup) {
                return FxStateView.empty(
                  message: S.of(context).statsSelectGroupFirst,
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
                    _AssetCompositionCard(data: data),
                    const SizedBox(height: FxSpacing.md),
                    _NetWorthTrendCard(
                      points: data.trends,
                      currencyCode: data.currencyCode,
                    ),
                    const SizedBox(height: FxSpacing.md),
                    _AccountTypeCard(
                      items: data.accountTypes,
                      currencyCode: data.currencyCode,
                    ),
                    const SizedBox(height: FxSpacing.md),
                    _CreditCardsCard(
                      items: data.creditCards,
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

class _AssetsStatsData {
  final bool hasGroup;
  final bool isStale;
  final int? groupId;
  final String? currencyCode;
  final List<PieSlice> assets;
  final List<PieSlice> liabilities;
  final List<NetAssetsTrendPoint> trends;
  final List<AssetsByAccountType> accountTypes;
  final List<CreditCardOverview> creditCards;

  const _AssetsStatsData({
    this.hasGroup = true,
    this.isStale = false,
    this.groupId,
    this.currencyCode,
    this.assets = const [],
    this.liabilities = const [],
    this.trends = const [],
    this.accountTypes = const [],
    this.creditCards = const [],
  });
}

class _AssetCompositionCard extends StatelessWidget {
  final _AssetsStatsData data;

  const _AssetCompositionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final formats = StatsFormatters.of(
      context,
      currencyCode: data.currencyCode,
    );
    final assetTotal = data.assets.fold<double>(0, (sum, e) => sum + e.value);
    final liabilityTotal = data.liabilities.fold<double>(
      0,
      (sum, e) => sum + e.value,
    );
    final netWorth = assetTotal - liabilityTotal;
    final slices = [
      for (final item in data.assets)
        FxDonutSlice(
          name: item.name,
          value: item.value,
          percent: item.percent,
          color: StatsPalette.stableFor(item.name, id: item.id),
        ),
      for (final item in data.liabilities)
        FxDonutSlice(
          name: item.name,
          value: item.value,
          percent: item.percent,
          color: StatsPalette.liabilityVariant(context, item.name, id: item.id),
        ),
    ].where((slice) => slice.value > 0).toList();
    final summary =
        '${S.of(context).statsAssetsComposition}: '
        '${S.of(context).dashboardAssets} ${formats.money(assetTotal)}, '
        '${S.of(context).dashboardLiabilities} ${formats.money(liabilityTotal)}, '
        '${S.of(context).dashboardNetWorth} ${formats.money(netWorth)}';
    return FxCard(
      child: Semantics(
        label: summary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxCardLabel(S.of(context).statsAssetsComposition),
            const SizedBox(height: FxSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TotalTile(
                    label: S.of(context).dashboardAssets,
                    amount: assetTotal,
                    currencyCode: data.currencyCode,
                    color: FxFinanceColors.of(context).income,
                  ),
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: _TotalTile(
                    label: S.of(context).dashboardLiabilities,
                    amount: liabilityTotal,
                    currencyCode: data.currencyCode,
                    color: FxFinanceColors.of(context).expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FxSpacing.lg),
            if (slices.isEmpty)
              _EmptyInline(message: S.of(context).dashboardNoData)
            else
              SizedBox(
                height: formats.masked ? 220 : 260,
                child: StatsChartTableToggle(
                  rows: [
                    for (final slice in slices)
                      StatsChartTableRow(
                        label: slice.name.isEmpty
                            ? S.of(context).statsUnnamed
                            : slice.name,
                        value: formats.money(slice.value),
                        percent: formats.percent(slice.percent),
                        color: slice.color,
                        icon: Icons.donut_large_rounded,
                      ),
                  ],
                  chart: formats.masked
                      ? _MaskedSliceLegend(slices: slices, formats: formats)
                      : FxDonutChart(
                          slices: slices,
                          currencyCode: data.currencyCode,
                          centerLabel: S.of(context).dashboardNetWorth,
                          centerAmount: netWorth,
                          showList: true,
                          accessibilityLabels: [
                            for (final slice in slices)
                              '${slice.name.isEmpty ? S.of(context).statsUnnamed : slice.name}: '
                                  '${formats.money(slice.value)}, '
                                  '${formats.percent(slice.percent)}',
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthTrendCard extends StatelessWidget {
  final List<NetAssetsTrendPoint> points;
  final String? currencyCode;

  const _NetWorthTrendCard({required this.points, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    return FxCard(
      child: Semantics(
        label: S.of(context).statsNetAssetsTrend,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxCardLabel(S.of(context).statsNetAssetsTrend),
            const SizedBox(height: FxSpacing.md),
            if (points.length < 2)
              _EmptyInline(message: S.of(context).dashboardInsufficientData)
            else
              SizedBox(
                height: 240,
                child: StatsChartTableToggle(
                  rows: [
                    for (final item in points)
                      StatsChartTableRow(
                        label: item.name.isEmpty
                            ? item.snapshotDate
                            : item.name,
                        value: formats.money(item.netAssets),
                        color: palette.primary,
                        icon: Icons.show_chart_rounded,
                      ),
                  ],
                  chart: FxLineChart(
                    series: [
                      FxLineSeries(
                        points: [
                          for (final item in points)
                            FxLinePoint(
                              name: item.name.isEmpty
                                  ? item.snapshotDate
                                  : item.name,
                              value: item.netAssets,
                            ),
                        ],
                        color: palette.primary,
                        label: S.of(context).dashboardNetWorth,
                      ),
                    ],
                    locale: formats.locale,
                    visibility: formats.visibility,
                    valueFormatter: formats.chartValue,
                    accessibilityLabels: [
                      for (final item in points)
                        '${S.of(context).dashboardNetWorth} '
                            '${item.name.isEmpty ? item.snapshotDate : item.name}: '
                            '${formats.money(item.netAssets)}',
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final List<AssetsByAccountType> items;
  final String? currencyCode;

  const _AccountTypeCard({required this.items, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    return FxCard(
      child: Semantics(
        label: S.of(context).statsAssetsByAccountType,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxCardLabel(S.of(context).statsAssetsByAccountType),
            const SizedBox(height: FxSpacing.md),
            if (items.isEmpty)
              _EmptyInline(message: S.of(context).dashboardNoData)
            else
              SizedBox(
                height: 240,
                child: StatsChartTableToggle(
                  rows: [
                    for (final item in items)
                      StatsChartTableRow(
                        label: item.accountTypeName.isEmpty
                            ? S.of(context).statsUnnamed
                            : item.accountTypeName,
                        value: formats.money(item.assets),
                        color: StatsPalette.stableFor(
                          item.accountTypeName,
                          id: item.accountType,
                        ),
                        icon: Icons.bar_chart_rounded,
                      ),
                  ],
                  chart: FxBarChart(
                    items: [
                      for (final item in items)
                        FxBarItem(
                          name: item.accountTypeName,
                          value: item.assets,
                          color: StatsPalette.stableFor(
                            item.accountTypeName,
                            id: item.accountType,
                          ),
                        ),
                    ],
                    height: 180,
                    unnamedLabel: S.of(context).statsUnnamed,
                    locale: formats.locale,
                    visibility: formats.visibility,
                    valueFormatter: formats.chartValue,
                    accessibilityLabels: [
                      for (final item in items)
                        '${item.accountTypeName.isEmpty ? S.of(context).statsUnnamed : item.accountTypeName}: '
                            '${formats.money(item.assets)}',
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreditCardsCard extends StatelessWidget {
  final List<CreditCardOverview> items;
  final String? currencyCode;

  const _CreditCardsCard({required this.items, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final formats = StatsFormatters.of(context, currencyCode: currencyCode);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsCreditCardOverview),
          const SizedBox(height: FxSpacing.md),
          if (items.isEmpty)
            _EmptyInline(message: S.of(context).dashboardNoData)
          else
            for (final item in items) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.accountName.isEmpty
                          ? S.of(context).statsUnnamed
                          : item.accountName,
                      style: FxTypography.bodyStrong,
                    ),
                  ),
                  FxMoneyText(
                    amount: item.usedAmount,
                    currencyCode: currencyCode,
                    fontSize: 14,
                    color: palette.textPrimary,
                    masked: formats.masked,
                  ),
                ],
              ),
              const SizedBox(height: FxSpacing.xs),
              Text(
                S
                    .of(context)
                    .statsCreditCardDates(
                      item.billingDate.isEmpty ? '-' : item.billingDate,
                      item.repaymentDate.isEmpty ? '-' : item.repaymentDate,
                    ),
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              const SizedBox(height: FxSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _MaskedSliceLegend extends StatelessWidget {
  const _MaskedSliceLegend({required this.slices, required this.formats});

  final List<FxDonutSlice> slices;
  final StatsFormatters formats;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      children: [
        for (final slice in slices.take(5)) ...[
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: slice.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Text(
                  slice.name.isEmpty ? S.of(context).statsUnnamed : slice.name,
                  style: FxTypography.label.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${formats.money(slice.value)} · ${formats.percent(slice.percent)}',
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
        ],
      ],
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String label;
  final double amount;
  final String? currencyCode;
  final Color color;

  const _TotalTile({
    required this.label,
    required this.amount,
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
        ],
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String message;

  const _EmptyInline({required this.message});

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
