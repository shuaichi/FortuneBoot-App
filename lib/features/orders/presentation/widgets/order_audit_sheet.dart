import 'package:flutter/material.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据操作审计弹层。审计数据独立分页，不嵌入详情一次性加载。
class OrderAuditSheet extends StatefulWidget {
  final OrdersService service;
  final int bookId;
  final int orderId;

  const OrderAuditSheet({
    super.key,
    required this.service,
    required this.bookId,
    required this.orderId,
  });

  @override
  State<OrderAuditSheet> createState() => _OrderAuditSheetState();

  static Future<void> show(
    BuildContext context, {
    required OrdersService service,
    required int bookId,
    required int orderId,
  }) {
    return FxSheet.show<void>(
      context,
      scrollable: false,
      maxHeightFactor: FxSheet.formHeightFactor,
      title: S.of(context).ordersAuditTitle,
      child: OrderAuditSheet(
        service: service,
        bookId: bookId,
        orderId: orderId,
      ),
    );
  }
}

class _OrderAuditSheetState extends State<OrderAuditSheet> {
  static const int _pageSize = 20;

  final List<FinanceOrderAudit> _rows = [];
  var _status = _AuditStatus.loading;
  var _page = 1;
  var _total = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await widget.service.getAudit(
        bookId: widget.bookId,
        orderId: widget.orderId,
        pageNum: _page,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _rows.addAll(page.rows);
        _total = page.total;
        _status = _AuditStatus.ready;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _status = _AuditStatus.error;
        _error = S.of(context).dashboardLoadFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: switch (_status) {
            _AuditStatus.loading => FxStateView.loading(),
            _AuditStatus.error => FxStateView.error(message: _error),
            _AuditStatus.ready => ListView.builder(
              itemCount: _rows.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _rows.length) {
                  return ListTile(
                    title: Text(S.of(context).commonRetry),
                    onTap: () {
                      setState(() {
                        _page++;
                        _status = _AuditStatus.loading;
                      });
                      _load();
                    },
                  );
                }
                final row = _rows[index];
                return ListTile(
                  title: Text(row.action),
                  subtitle: Text(row.createTime?.toString() ?? ''),
                );
              },
            ),
          },
        ),
      ],
    );
  }

  bool get _hasMore => _rows.length < _total;
}

enum _AuditStatus { loading, ready, error }
