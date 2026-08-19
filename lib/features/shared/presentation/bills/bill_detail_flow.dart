import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class BillDetailFlow {
  BillDetailFlow({BillService? service}) : _service = service ?? BillService();

  final BillService _service;

  void show(
    BuildContext context, {
    required int? bookId,
    required FortuneBillVo bill,
  }) {
    FxSheet.show<void>(
      context,
      scrollable: true,
      minHeightFactor: 0.4,
      maxHeightFactor: 0.72,
      child: BillDetailSheet(bill: bill, service: _service),
      footer: BillDetailActions(
        bill: bill,
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

  void _edit(BuildContext context, FortuneBillVo bill) {
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
    if (bookId == null || billId == null) {
      return;
    }

    final confirmed = await _confirmDelete(context, bill);
    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await _service.remove(bookId: bookId, billId: billId);
      BillMutations.bump();
    } on FxApiException catch (error) {
      if (context.mounted) _showError(context, error.message);
    } on Exception catch (_) {
      if (context.mounted) {
        _showError(context, S.of(context).dashboardLoadFailed);
      }
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
    if (bookId == null || billId == null) {
      return;
    }

    try {
      if (confirm) {
        await _service.confirm(bookId: bookId, billId: billId);
      } else {
        await _service.unConfirm(bookId: bookId, billId: billId);
      }
      BillMutations.bump();
    } on FxApiException catch (error) {
      if (context.mounted) _showError(context, error.message);
    } on Exception catch (_) {
      if (context.mounted) {
        _showError(context, S.of(context).dashboardLoadFailed);
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context, FortuneBillVo bill) async {
    final palette = FxPalette.of(context);
    return await FxSheet.show<bool>(
          context,
          title: S.of(context).billsDeleteTitle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              0,
              FxSpacing.lg,
              FxSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S
                      .of(context)
                      .billsDeleteConfirm(
                        bill.title ?? bill.primaryCategoryName,
                      ),
                  style: FxTypography.body,
                ),
                const SizedBox(height: FxSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _SheetButton(
                        label: S.of(context).commonCancel,
                        onTap: () => Navigator.of(context).pop(false),
                        color: palette.surfaceMuted,
                        foregroundColor: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: FxSpacing.md),
                    Expanded(
                      child: _SheetButton(
                        label: S.of(context).billsDelete,
                        onTap: () => Navigator.of(context).pop(true),
                        color: palette.danger,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.foregroundColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: FxTypography.bodyStrong.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
