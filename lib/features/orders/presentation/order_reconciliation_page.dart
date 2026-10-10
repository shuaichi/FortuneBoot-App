import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 历史核对报告页。只读，不做修复或回放现金。
class OrderReconciliationPage extends StatefulWidget {
  final OrdersService service;
  final int bookId;

  const OrderReconciliationPage({
    super.key,
    required this.service,
    required this.bookId,
  });

  @override
  State<OrderReconciliationPage> createState() =>
      _OrderReconciliationPageState();
}

class _OrderReconciliationPageState extends State<OrderReconciliationPage> {
  static const int _pageSize = 20;

  final List<FinanceOrderReconciliation> _rows = [];
  var _page = 1;
  var _total = 0;
  var _loading = true;
  var _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool append = false}) async {
    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
      _error = null;
    });
    try {
      final page = await widget.service.getReconciliation(
        bookId: widget.bookId,
        pageNum: _page,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _rows.addAll(page.rows);
        } else {
          _rows
            ..clear()
            ..addAll(page.rows);
        }
        _total = page.total;
        _loading = false;
        _loadingMore = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = S.of(context).dashboardLoadFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        title: Text(S.of(context).ordersReconciliationTitle),
        backgroundColor: palette.canvas,
      ),
      body: SafeArea(child: _buildBody(context)),
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
      return FxStateView.empty(
        message: S.of(context).ordersReconciliationEmpty,
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
            return ListTile(
              title: Text(S.of(context).commonRetry),
              onTap: () {
                _page++;
                _load(append: true);
              },
            );
          }
          final row = _rows[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(FxSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.orderId == null
                        ? 'bill #${row.billId}'
                        : 'order #${row.orderId}',
                    style: FxTypography.title,
                  ),
                  const SizedBox(height: FxSpacing.xs),
                  Text(row.issueCodes.join(', ')),
                  if (row.note?.isNotEmpty == true) Text(row.note!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool get _hasMore => _rows.length < _total;
}
