import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';

void main() {
  test('keeps only reimbursement orders for bill associations', () {
    final orders = EditorOptionsService.reimbursementOrders([
      const OrderOption(orderId: 1, type: 1, title: '报销单'),
      const OrderOption(orderId: 2, type: 2, title: '借出单'),
      const OrderOption(orderId: 3, type: 3, title: '借入单'),
      const OrderOption(orderId: 4, title: '未知单据'),
    ]);

    expect(orders.map((order) => order.orderId), [1]);
  });

  test('closed or draft options are returned as disabled instead of replaced', () {
    final option = OrderOption.fromDetail(
      const FinanceOrderDetail(orderId: 1, status: 1000),
    );

    expect(option.orderId, 1);
    expect(option.enabled, isFalse);
  });
}
