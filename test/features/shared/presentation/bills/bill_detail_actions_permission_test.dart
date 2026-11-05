import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_permissions.dart';

void main() {
  test('order actions are inherited instead of reopened by shared detail', () {
    final permissions = BillDetailPermissions.of(
      const FortuneBillVo(billType: 1, allowedActions: ['EDIT', 'UNCONFIRM']),
    );

    expect(permissions.canEdit, isTrue);
    expect(permissions.canUnconfirm, isTrue);
    expect(permissions.canConfirm, isFalse);
    expect(permissions.canCopy, isFalse);
    expect(permissions.canDelete, isFalse);
    expect(permissions.isReadOnly, isFalse);
  });

  test(
    'ordinary bill keeps existing actions when no source constraints exist',
    () {
      final permissions = BillDetailPermissions.of(
        const FortuneBillVo(billType: 1),
      );

      expect(permissions.canEdit, isTrue);
      expect(permissions.canCopy, isTrue);
      expect(permissions.canDelete, isTrue);
      expect(permissions.canUnconfirm, isTrue);
    },
  );

  test('source read-only reason wins over an allowed action list', () {
    final permissions = BillDetailPermissions.of(
      const FortuneBillVo(
        billType: 1,
        readOnlyReason: 'locked',
        allowedActions: ['EDIT', 'DELETE'],
      ),
    );

    expect(permissions.canEdit, isFalse);
    expect(permissions.canDelete, isFalse);
    expect(permissions.isReadOnly, isTrue);
  });
}
