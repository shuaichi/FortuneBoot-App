import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
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
  const StatsAssetsPage({super.key});

  @override
  State<StatsAssetsPage> createState() => _StatsAssetsPageState();
}

class _StatsAssetsPageState extends State<StatsAssetsPage> {
  final StatsService _service = StatsService();
  late Future<_AssetsStatsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AssetsStatsData> _load() async {
    final session = context.read<SessionCubit>().state;
    final groupId = session.currentGroupId;
    if (groupId == null) return const _AssetsStatsData(hasGroup: false);
    try {
      final results = await Future.wait<Object>([
        _service.getTotalAssets(groupId: groupId),
        _service.getTotalLiabilities(groupId: groupId),
        _service.getNetAssetsTrend(groupId: groupId),
        _service.getAssetsByAccountType(groupId: groupId),
        _service.getCreditCardOverview(groupId: groupId),
      ]);
      return _AssetsStatsData(
        assets: results[0] as List<PieSlice>,
        liabilities: results[1] as List<PieSlice>,
        trends: results[2] as List<NetAssetsTrendPoint>,
        accountTypes: results[3] as List<AssetsByAccountType>,
        creditCards: results[4] as List<CreditCardOverview>,
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
              message: snapshot.error.toString(),
              onRetry: _reload,
            );
          }
          final data = snapshot.data ?? const _AssetsStatsData();
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
                _NetWorthTrendCard(points: data.trends),
                const SizedBox(height: FxSpacing.md),
                _AccountTypeCard(items: data.accountTypes),
                const SizedBox(height: FxSpacing.md),
                _CreditCardsCard(items: data.creditCards),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssetsStatsData {
  final bool hasGroup;
  final List<PieSlice> assets;
  final List<PieSlice> liabilities;
  final List<NetAssetsTrendPoint> trends;
  final List<AssetsByAccountType> accountTypes;
  final List<CreditCardOverview> creditCards;

  const _AssetsStatsData({
    this.hasGroup = true,
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
    final session = context.watch<SessionCubit>().state;
    final assetTotal = data.assets.fold<double>(0, (sum, e) => sum + e.value);
    final liabilityTotal = data.liabilities.fold<double>(
      0,
      (sum, e) => sum + e.value,
    );
    return FxCard(
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
                  currencyCode: session.defaultCurrency,
                  color: FxFinanceColors.of(context).income,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: _TotalTile(
                  label: S.of(context).dashboardLiabilities,
                  amount: liabilityTotal,
                  currencyCode: session.defaultCurrency,
                  color: FxFinanceColors.of(context).expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          if (data.assets.isEmpty && data.liabilities.isEmpty)
            _EmptyInline(message: S.of(context).dashboardNoData)
          else
            FxDonutChart(
              slices: [
                for (final item in data.assets)
                  FxDonutSlice(
                    name: item.name,
                    value: item.value,
                    percent: item.percent,
                  ),
                for (final item in data.liabilities)
                  FxDonutSlice(
                    name: item.name,
                    value: item.value,
                    percent: item.percent,
                    color: FxFinanceColors.of(context).expense,
                  ),
              ],
              currencyCode: session.defaultCurrency,
              centerLabel: S.of(context).dashboardNetWorth,
              centerAmount: assetTotal - liabilityTotal,
            ),
        ],
      ),
    );
  }
}

class _NetWorthTrendCard extends StatelessWidget {
  final List<NetAssetsTrendPoint> points;

  const _NetWorthTrendCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsNetAssetsTrend),
          const SizedBox(height: FxSpacing.md),
          if (points.length < 2)
            _EmptyInline(message: S.of(context).dashboardInsufficientData)
          else
            FxLineChart(
              series: [
                FxLineSeries(
                  points: [
                    for (final item in points)
                      FxLinePoint(
                        name: item.name.isEmpty ? item.snapshotDate : item.name,
                        value: item.netAssets,
                      ),
                  ],
                  color: palette.primary,
                  label: S.of(context).dashboardNetWorth,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final List<AssetsByAccountType> items;

  const _AccountTypeCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsAssetsByAccountType),
          const SizedBox(height: FxSpacing.md),
          if (items.isEmpty)
            _EmptyInline(message: S.of(context).dashboardNoData)
          else
            FxBarChart(
              items: [
                for (final item in items)
                  FxBarItem(name: item.accountTypeName, value: item.assets),
              ],
              height: 180,
              unnamedLabel: S.of(context).statsUnnamed,
            ),
        ],
      ),
    );
  }
}

class _CreditCardsCard extends StatelessWidget {
  final List<CreditCardOverview> items;

  const _CreditCardsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final palette = FxPalette.of(context);
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
                    currencyCode: session.defaultCurrency,
                    fontSize: 14,
                    color: palette.textPrimary,
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
