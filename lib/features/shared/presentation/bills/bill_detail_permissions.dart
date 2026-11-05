import 'package:fortuneboot/features/shared/data/bill_models.dart';

/// 共享详情对来源账单动作的只读映射，不重新推导服务端权限。
class BillDetailPermissions {
  const BillDetailPermissions._({
    required this.canEdit,
    required this.canCopy,
    required this.canDelete,
    required this.canConfirm,
    required this.canUnconfirm,
  });

  final bool canEdit;
  final bool canCopy;
  final bool canDelete;
  final bool canConfirm;
  final bool canUnconfirm;

  bool get isReadOnly =>
      !canEdit && !canCopy && !canDelete && !canConfirm && !canUnconfirm;

  factory BillDetailPermissions.of(FortuneBillVo bill) {
    final hasSourceConstraints =
        bill.orderId != null ||
        bill.allowedActions.isNotEmpty ||
        bill.readOnlyReason?.isNotEmpty == true;
    if (!hasSourceConstraints) {
      final editable = bill.billType != FxBillType.adjust.value;
      return BillDetailPermissions._(
        canEdit: editable,
        canCopy: editable,
        canDelete: true,
        canConfirm: !bill.confirm,
        canUnconfirm: bill.confirm,
      );
    }
    final actions = bill.allowedActions.toSet();
    final locked = bill.readOnlyReason?.isNotEmpty == true;
    bool allows(String action) => !locked && actions.contains(action);
    return BillDetailPermissions._(
      canEdit: allows('EDIT'),
      canCopy: allows('COPY'),
      canDelete: allows('DELETE') || allows('VOID'),
      canConfirm: allows('CONFIRM'),
      canUnconfirm: allows('UNCONFIRM'),
    );
  }
}
