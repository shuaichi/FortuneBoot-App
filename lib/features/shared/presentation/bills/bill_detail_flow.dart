import 'dart:math' as math;

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
import 'package:fortuneboot/fx/theme/fx_theme.dart';
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
    final detail = BillDetailSheet(bill: bill, service: _service);
    final footer = Builder(
      builder: (detailContext) => BillDetailActions(
        bill: bill,
        onCopy: () => _copy(detailContext, bill),
        onEdit: () => _edit(detailContext, bill),
        onDelete: () => _delete(detailContext, bookId: bookId, bill: bill),
        onConfirmToggle: (confirm) => _toggleConfirm(
          detailContext,
          bookId: bookId,
          bill: bill,
          confirm: confirm,
        ),
      ),
    );
    if (MediaQuery.widthOf(context) < 840) {
      FxSheet.show<void>(
        context,
        title: S.of(context).billsDetailTitle,
        scrollable: true,
        child: detail,
        footer: footer,
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final palette = FxPalette.of(dialogContext);
        final availableHeight = MediaQuery.heightOf(dialogContext) - 64;
        return Dialog(
          backgroundColor: palette.surface,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            key: const ValueKey('bill-detail-dialog'),
            width: 560,
            height: math.min(760.0, availableHeight),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24),
                    child: detail,
                  ),
                ),
                footer,
              ],
            ),
          ),
        );
      },
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
      if (context.mounted) {
        Navigator.of(context).pop();
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

  Future<void> _toggleConfirm(
    BuildContext context, {
    required int? bookId,
    required FortuneBillVo bill,
    required bool confirm,
  }) async {
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
      if (context.mounted) {
        Navigator.of(context).pop();
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
