import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/shell/bills_navigation_controller.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

void main() {
  test('publishes distinct revisions for identical requests', () {
    final controller = BillsNavigationController();
    addTearDown(controller.dispose);
    final request = BillsEntryRequest(
      bookId: 7,
      groupId: 3,
      dateRange: BillDateRange(
        start: DateTime(2026, 8, 20),
        end: DateTime(2026, 8, 20),
      ),
    );

    controller.open(request);
    final first = controller.request!;
    controller.open(request);
    final second = controller.request!;

    expect(first.entryRequest, request);
    expect(second.entryRequest, request);
    expect(second.revision, first.revision + 1);
  });
}
