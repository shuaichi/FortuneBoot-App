import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/layout/fx_page_scaffold.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 历史核对报告页。只读，不做修复或回放现金。
class OrderReconciliationPage extends StatefulWidget {
  final OrdersService service;
  final int bookId;

  /// 从单据卡片进入时传入，便于空列表时跳回该单据详情。
  final int? focusOrderId;

  const OrderReconciliationPage({
    super.key,
    required this.service,
    required this.bookId,
    this.focusOrderId,
  });

  @override
  State<OrderReconciliationPage> createState() =>
      _OrderReconciliationPageState();
}

class _OrderReconciliationPageState extends State<OrderReconciliationPage> {
  final List<FinanceOrderReconciliation> _rows = [];
  var _page = 1;
  var _total = 0;
  var _loading = true;
  var _loadingMore = false;
  String? _error;
  String? _loadMoreError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool append = false}) async {
    final requestPage = append ? _page + 1 : _page;
    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
      _error = null;
      _loadMoreError = null;
    });
    try {
      final page = await widget.service.getReconciliation(
        bookId: widget.bookId,
        pageNum: requestPage,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _rows.addAll(page.rows);
          _page = requestPage;
        } else {
          _rows
            ..clear()
            ..addAll(page.rows);
          _page = 1;
        }
        _total = page.total;
        _loading = false;
        _loadingMore = false;
      });
    } on Object catch (error, stack) {
      debugPrint('OrderReconciliationPage load failed: $error\n$stack');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (append) {
          _loadMoreError = error is FxApiException
              ? error.message
              : S.of(context).ordersLoadMoreFailed;
        } else {
          _error = error is FxApiException
              ? error.message
              : S.of(context).dashboardLoadFailed;
        }
      });
    }
  }

  Future<void> _openOrder(FinanceOrderReconciliation row) async {
    final orderId = row.orderId;
    if (orderId == null) return;
    await AppRouter.push<void>(
      context,
      Routes.orderDetail,
      args: {
        'bookId': widget.bookId,
        'orderId': orderId,
        'service': widget.service,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FxPageScaffold(
      title: S.of(context).ordersReconciliationTitle,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return FxStateView.loading();
    if (_error != null) {
      return FxStateView.error(
        message: _error,
        onRetry: () => _load(),
        retryLabel: S.of(context).commonRetry,
      );
    }
    if (_rows.isEmpty) {
      final focusOrderId = widget.focusOrderId;
      return FxStateView.empty(
        message: S.of(context).ordersReconciliationEmpty,
        retryLabel: focusOrderId == null
            ? null
            : S.of(context).ordersOpenFocusedOrder,
        onRetry: focusOrderId == null
            ? null
            : () =>
                  _openOrder(FinanceOrderReconciliation(orderId: focusOrderId)),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        await _load();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(FxSpacing.lg),
        itemCount: _rows.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: FxSpacing.md),
        itemBuilder: (context, index) {
          if (index >= _rows.length) {
            if (_loadingMore) {
              return const Padding(
                padding: EdgeInsets.all(FxSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (_loadMoreError != null) {
              return ListTile(
                key: const ValueKey('reconciliation-load-more'),
                title: Text(S.of(context).ordersLoadMoreFailed),
                trailing: Text(S.of(context).commonRetry),
                onTap: () => _load(append: true),
              );
            }
            return ListTile(
              key: const ValueKey('reconciliation-load-more'),
              title: Text(S.of(context).ordersLoadMore),
              onTap: () => _load(append: true),
            );
          }
          return _ReconciliationCard(
            row: _rows[index],
            onTap: _rows[index].orderId == null
                ? null
                : () => _openOrder(_rows[index]),
          );
        },
      ),
    );
  }

  bool get _hasMore => _rows.length < _total;
}

class _ReconciliationCard extends StatelessWidget {
  const _ReconciliationCard({required this.row, this.onTap});

  final FinanceOrderReconciliation row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final issues = _uniqueIssueCodes(row.issueCodes);
    final note = row.note?.trim();
    final showNote =
        note != null &&
        note.isNotEmpty &&
        !issues.any((code) => code.toUpperCase() == note.toUpperCase()) &&
        !_issueLabels(context, issues).any((label) => label == note);
    final currency = row.currencyCodes.isEmpty ? null : row.currencyCodes.first;

    return FxCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title(context), style: FxTypography.title),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.sm),
            Wrap(
              spacing: FxSpacing.sm,
              runSpacing: FxSpacing.xs,
              children: [
                for (final code in issues)
                  FxChip(
                    label: _issueLabel(context, code),
                    selected: false,
                    isAction: true,
                    onTap: () {},
                  ),
              ],
            ),
          ],
          if (showNote) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              note,
              style: FxTypography.body.copyWith(color: palette.textSecondary),
            ),
          ],
          if (!row.cashEffectKnown) ...[
            const SizedBox(height: FxSpacing.xs),
            Text(
              s.ordersReconciliationCashUnknown,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          ],
          if (_hasAmountRow) ...[
            const SizedBox(height: FxSpacing.sm),
            Wrap(
              spacing: FxSpacing.md,
              runSpacing: FxSpacing.xs,
              children: [
                if (row.originalOutAmount != null)
                  _amountLine(
                    context,
                    s.ordersReconciliationOutAmount,
                    row.originalOutAmount!,
                    currency,
                  ),
                if (row.originalInAmount != null)
                  _amountLine(
                    context,
                    s.ordersReconciliationInAmount,
                    row.originalInAmount!,
                    currency,
                  ),
                if (row.candidatePendingAmount != null)
                  _amountLine(
                    context,
                    s.ordersReconciliationPendingAmount,
                    row.candidatePendingAmount!,
                    currency,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasAmountRow =>
      row.originalOutAmount != null ||
      row.originalInAmount != null ||
      row.candidatePendingAmount != null;

  String _title(BuildContext context) {
    final s = S.of(context);
    if (row.orderId != null) {
      return s.ordersReconciliationOrderTitle(row.orderId!);
    }
    if (row.billId != null) {
      return s.ordersReconciliationBillTitle(row.billId!);
    }
    return s.ordersReconciliationUnknownTitle;
  }

  Widget _amountLine(
    BuildContext context,
    String label,
    OrderMoney amount,
    String? currencyCode,
  ) {
    final palette = FxPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: FxTypography.caption.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(width: FxSpacing.xs),
        FxMoneyText(
          amount: amount.cents / 100,
          currencyCode: currencyCode,
          fontSize: 14,
          color: palette.textPrimary,
        ),
      ],
    );
  }
}

List<String> _uniqueIssueCodes(List<String> codes) {
  final seen = <String>{};
  final out = <String>[];
  for (final code in codes) {
    final key = code.trim().toUpperCase();
    if (key.isEmpty || !seen.add(key)) continue;
    out.add(code.trim());
  }
  return out;
}

List<String> _issueLabels(BuildContext context, List<String> codes) =>
    codes.map((code) => _issueLabel(context, code)).toList();

String _issueLabel(BuildContext context, String code) {
  final s = S.of(context);
  return switch (code.trim().toUpperCase()) {
    'CALCULATION_INVALID' => s.ordersIssueCalculationInvalid,
    'LEGACY_LOAN_ISOLATED' => s.ordersIssueLegacyLoanIsolated,
    _ => code,
  };
}
