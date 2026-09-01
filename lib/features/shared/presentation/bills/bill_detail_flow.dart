import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_delete_confirmation.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/generated/l10n.dart';

class BillDetailFlow {
  BillDetailFlow({BillService? service}) : _service = service ?? BillService();

  final BillService _service;
  final Set<int> _pendingBillIds = <int>{};

  void show(
    BuildContext context, {
    required int? bookId,
    required FortuneBillVo bill,
  }) {
    FxSheet.show<void>(
      context,
      scrollable: true,
      minHeightFactor: FxSheet.hintHeightFactor,
      maxHeightFactor: FxSheet.detailHeightFactor,
      child: BillDetailSheet(bill: bill, service: _service),
      footer: BillDetailActions(
        bill: bill,
        onCopy: () => _copy(context, bill),
        onEdit: () => _edit(context, bill),
        onDelete: () => _delete(context, bookId: bookId, bill: bill),
        onConfirmToggle: (confirm) => _toggleConfirm(
          context,
          bookId: bookId,
          bill: bill,
          confirm: confirm,
        ),
      ),
    );
  }

  void _copy(BuildContext context, FortuneBillVo bill) {
    if (bill.billType == FxBillType.adjust.value) return;
    Navigator.of(context).pop();
    AppRouter.push<void>(
      context,
      Routes.billEditor,
      args: {'mode': 'copy', 'bill': bill},
    );
  }

  void _edit(BuildContext context, FortuneBillVo bill) {
    if (bill.billType == FxBillType.adjust.value) return;
    Navigator.of(context).pop();
    AppRouter.push<void>(
      context,
      Routes.billEditor,
      args: {'mode': 'edit', 'billId': bill.billId, 'bill': bill},
    );
  }

  Future<void> _delete(
    BuildContext context, {
    required int? bookId,
    required FortuneBillVo bill,
  }) async {
    Navigator.of(context).pop();
    final billId = bill.billId;
    if (bookId == null || billId == null || _pendingBillIds.contains(billId)) {
      return;
    }

    final confirmed = await showBillDeleteConfirmation(context, bill);
    if (!confirmed || !context.mounted) {
      return;
    }

    _pendingBillIds.add(billId);
    try {
      await _service.remove(bookId: bookId, billId: billId);
      BillMutations.bump();
    } on FxApiException catch (error) {
      if (context.mounted) _showError(context, error.message);
    } on Exception {
      if (context.mounted) {
        _showError(context, S.of(context).dashboardLoadFailed);
      }
    } finally {
      _pendingBillIds.remove(billId);
    }
  }

  Future<void> _toggleConfirm(
    BuildContext context, {
    required int? bookId,
    required FortuneBillVo bill,
    required bool confirm,
  }) async {
    Navigator.of(context).pop();
    final billId = bill.billId;
    if (bookId == null || billId == null || _pendingBillIds.contains(billId)) {
      return;
    }

    _pendingBillIds.add(billId);
    try {
      if (confirm) {
        await _service.confirm(bookId: bookId, billId: billId);
      } else {
        await _service.unConfirm(bookId: bookId, billId: billId);
      }
      BillMutations.bump();
    } on FxApiException catch (error) {
      if (context.mounted) _showError(context, error.message);
    } on Exception {
      if (context.mounted) {
        _showError(context, S.of(context).dashboardLoadFailed);
      }
    } finally {
      _pendingBillIds.remove(billId);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
