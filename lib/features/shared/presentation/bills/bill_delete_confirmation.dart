import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

Future<bool> showBillDeleteConfirmation(
  BuildContext context,
  FortuneBillVo bill,
) async {
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
                    .billsDeleteConfirm(bill.title ?? bill.primaryCategoryName),
                style: FxTypography.body,
              ),
              const SizedBox(height: FxSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: FxButton.text(
                      label: S.of(context).commonCancel,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: FxSpacing.md),
                  Expanded(
                    child: FxButton.critical(
                      label: S.of(context).billsDelete,
                      onPressed: () => Navigator.of(context).pop(true),
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
