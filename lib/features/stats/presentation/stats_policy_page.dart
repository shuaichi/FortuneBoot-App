import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/data/stats_service.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class StatsPolicyPage extends StatefulWidget {
  const StatsPolicyPage({super.key});

  @override
  State<StatsPolicyPage> createState() => _StatsPolicyPageState();
}

class _StatsPolicyPageState extends State<StatsPolicyPage> {
  final StatsService _service = StatsService();
  late Future<_PolicyData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PolicyData> _load() async {
    final bookId = context.read<SessionCubit>().state.currentBookId;
    if (bookId == null) return const _PolicyData(hasBook: false);
    try {
      final policy = await _service.getStatisticsPolicy(bookId: bookId);
      return _PolicyData(policy: policy);
    } on Object catch (_) {
      // Policy endpoint is not present in older backends; show the documented
      // fallback so the page remains useful and compile-safe.
      return const _PolicyData(usedFallback: true);
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
        title: Text(S.of(context).statsPolicyTitle),
        backgroundColor: palette.canvas,
      ),
      body: FutureBuilder<_PolicyData>(
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
          final data = snapshot.data ?? const _PolicyData();
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
                _PolicySummaryCard(data: data),
                const SizedBox(height: FxSpacing.md),
                _BillTypesCard(policy: data.policy),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PolicyData {
  final bool hasBook;
  final StatisticsPolicy policy;
  final bool usedFallback;

  const _PolicyData({
    this.hasBook = true,
    this.policy = const StatisticsPolicy(),
    this.usedFallback = false,
  });
}

class _PolicySummaryCard extends StatelessWidget {
  final _PolicyData data;

  const _PolicySummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final policy = data.policy;
    final desc = policy.policyDesc.isEmpty
        ? S.of(context).statsPolicyDefaultDesc
        : policy.policyDesc;
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsPolicyScope),
          const SizedBox(height: FxSpacing.md),
          Text(
            policy.defaultInclude
                ? S.of(context).statsPolicyDefaultInclude
                : S.of(context).statsPolicyDefaultExclude,
            style: FxTypography.titleLarge.copyWith(color: palette.textPrimary),
          ),
          const SizedBox(height: FxSpacing.sm),
          Text(
            desc,
            style: FxTypography.body.copyWith(color: palette.textSecondary),
          ),
          if (data.usedFallback) ...[
            const SizedBox(height: FxSpacing.md),
            Text(
              S.of(context).statsPolicyEndpointFallback,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _BillTypesCard extends StatelessWidget {
  final StatisticsPolicy policy;

  const _BillTypesCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    const types = FxBillType.values;
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxCardLabel(S.of(context).statsPolicyBillTypes),
          const SizedBox(height: FxSpacing.md),
          for (final type in types) ...[
            _BillTypeRow(type: type, policy: policy),
            if (type != types.last) const Divider(height: FxSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _BillTypeRow extends StatelessWidget {
  final FxBillType type;
  final StatisticsPolicy policy;

  const _BillTypeRow({required this.type, required this.policy});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final included =
        policy.includeTypes.contains(type.value) ||
        (policy.defaultInclude && !policy.excludeTypes.contains(type.value));
    final color = included ? finance.income : finance.expense;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: FxSpacing.sm),
        Expanded(
          child: Text(
            type.localizedLabel(context),
            style: FxTypography.bodyStrong.copyWith(color: palette.textPrimary),
          ),
        ),
        Text(
          included
              ? S.of(context).statsPolicyIncluded
              : S.of(context).statsPolicyExcluded,
          style: FxTypography.caption.copyWith(color: color),
        ),
      ],
    );
  }
}
