import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/generated/l10n.dart';

Future<bool> showBillDeleteConfirmation(
  BuildContext context,
  FortuneBillVo bill,
) async {
  return DestructiveConfirmSheet.show(
    context,
    title: S.of(context).billsDeleteTitle,
    message: S
        .of(context)
        .billsDeleteConfirm(bill.title ?? bill.primaryCategoryName),
    subMessage: S.of(context).confirmDestructiveWarning,
    confirmLabel: S.of(context).billsDelete,
    cancelLabel: S.of(context).commonCancel,
  );
}
