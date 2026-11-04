import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_ledger_row.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_pressable.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 最近账单预览。内容决定高度，不使用整体缩放适配固定卡片。
class RecentBillsCard extends StatelessWidget {
  final DashboardSection<List<FortuneBillVo>> section;
  final String? currencyCode;
  final VoidCallback onRetry;
  final ValueChanged<FortuneBillVo>? onBillTap;

  const RecentBillsCard({
    super.key,
    required this.section,
    required this.currencyCode,
    required this.onRetry,
    this.onBillTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hideAmounts = context.select<PreferencesCubit, bool>(
      (cubit) => cubit.state.dashboard.hideAmounts,
    );
    return DashboardCardShell<List<FortuneBillVo>>(
      section: section,
      onRetry: onRetry,
      builder: (bills) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).dashboardRecentBills,
                    style: FxTypography.title.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                FxPressable(
                  semanticLabel: S.of(context).dashboardViewAll,
                  onPressed: () =>
                      MainShell.selectTab(context, MainShellTab.bills),
                  child: Text(
                    S.of(context).dashboardViewAll,
                    style: FxTypography.label.copyWith(color: palette.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FxSpacing.sm),
            if (bills.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: FxSpacing.xxl),
                child: Center(
                  child: Text(
                    S.of(context).dashboardNoBillsYet,
                    style: FxTypography.body.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              )
            else
              for (var index = 0; index < bills.length; index++) ...[
                if (index > 0) Divider(height: 1, color: palette.border),
                RecentBillPreviewRow(
                  bill: bills[index],
                  currencyCode: currencyCode,
                  hidden: hideAmounts,
                  onTap: onBillTap == null
                      ? null
                      : () => onBillTap!(bills[index]),
                ),
              ],
          ],
        );
      },
    );
  }
}

class RecentBillPreviewRow extends StatelessWidget {
  const RecentBillPreviewRow({
    required this.bill,
    required this.currencyCode,
    required this.hidden,
    required this.onTap,
  });

  final FortuneBillVo bill;
  final String? currencyCode;
  final bool hidden;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final locale = Localizations.localeOf(context).toString();
    final title = bill.title?.isNotEmpty == true
        ? bill.title!
        : bill.primaryCategoryName.isNotEmpty
        ? bill.primaryCategoryName
        : (bill.payeeName ?? strings.dashboardBillFallback);
    final metadata = <String>[
      if (FxBillType.fromValue(bill.billType) case final billType?)
        billType.localizedLabel(context),
      if (bill.accountName?.isNotEmpty == true) bill.accountName!,
      if (bill.tradeTime != null)
        DateFormat.MMMd(locale).format(bill.tradeTime!),
    ].join(' · ');
    final adjustments = <String>[
      if (!hidden && bill.feeTotal > 0)
        '${strings.billsFee} ${FxMoneyFormatter.format(bill.feeTotal, locale: locale)}',
      if (!hidden && bill.discountTotal > 0)
        '${strings.billsDiscount} ${FxMoneyFormatter.format(bill.discountTotal, locale: locale)}',
    ];
    return FxLedgerRow(
      title: title,
      subtitle: metadata,
      onTap: onTap,
      semanticLabel: title,
      amount: FxMoneyText(
        amount:
            FxBillType.fromValue(bill.billType)?.signedFlowAmount(
              bill.hasExtrasAdjustment
                  ? bill.settledAmount
                  : bill.displayAmount,
            ) ??
            bill.displayAmount,
        currencyCode: bill.currencyCode ?? currencyCode,
        billType: bill.billType,
        showSign:
            bill.billType != FxBillType.transfer.value &&
            bill.billType != FxBillType.adjust.value,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        masked: hidden,
        compactWhenNeeded: true,
      ),
      amountCaption: adjustments.isEmpty ? null : adjustments.join(' · '),
      titleAccessory: !hidden && bill.hasExtrasAdjustment
          ? Text(
              FxMoneyFormatter.format(bill.displayAmount, locale: locale),
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textTertiary,
                decoration: TextDecoration.lineThrough,
              ),
            )
          : null,
    );
  }
}
