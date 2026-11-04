import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_pressable.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/currency_symbol.dart';
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
                _RecentBillRow(
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

class _RecentBillRow extends StatelessWidget {
  const _RecentBillRow({
    required this.bill,
    required this.currencyCode,
    required this.hidden,
    required this.onTap,
  });

  static const double _minimumTitleWidth = 112;
  static const double _amountFontSize = 16;

  final FortuneBillVo bill;
  final String? currencyCode;
  final bool hidden;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final strings = S.of(context);
    final locale = Localizations.localeOf(context).toString();
    final code = bill.currencyCode ?? currencyCode;
    final symbol = code == null || code.isEmpty ? '' : getCurrencySymbol(code);
    final amount = hidden
        ? FxMoneyFormatter.hiddenPlaceholder
        : FxMoneyFormatter.format(
            bill.hasExtrasAdjustment ? bill.settledAmount : bill.displayAmount,
            locale: locale,
            currencySymbol: symbol,
          );
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
    final amountStyle = FxTypography.money.copyWith(
      fontSize: _amountFontSize,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
    );
    final metadataStyle = FxTypography.caption.copyWith(
      fontSize: 13,
      height: 1.4,
      color: palette.textSecondary,
    );

    return Semantics(
      button: onTap != null,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          mouseCursor: onTap == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          borderRadius: FxRadius.tileBorder,
          hoverColor: palette.textPrimary.withValues(alpha: 0.035),
          focusColor: palette.primary.withValues(alpha: 0.10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final painter = TextPainter(
                    text: TextSpan(
                      text: amount,
                      style: DefaultTextStyle.of(
                        context,
                      ).style.merge(amountStyle),
                    ),
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                    locale: Localizations.localeOf(context),
                    maxLines: 1,
                  )..layout();
                  final amountWidth = painter.width;
                  painter.dispose();
                  final stacked =
                      constraints.maxWidth - amountWidth - FxSpacing.lg <
                          _minimumTitleWidth ||
                      MediaQuery.textScalerOf(context).scale(_amountFontSize) >
                          24;
                  final description = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FxTypography.bodyStrong.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: palette.textPrimary,
                        ),
                      ),
                      if (metadata.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          metadata,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: metadataStyle,
                        ),
                      ],
                    ],
                  );
                  final amountText = Semantics(
                    label: amount,
                    child: ExcludeSemantics(
                      child: Text(amount, style: amountStyle),
                    ),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (stacked) ...[
                        description,
                        const SizedBox(height: FxSpacing.sm),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: amountText,
                        ),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: description),
                            const SizedBox(width: FxSpacing.lg),
                            amountText,
                          ],
                        ),
                      if (!hidden && bill.hasExtrasAdjustment) ...[
                        const SizedBox(height: FxSpacing.sm),
                        Wrap(
                          spacing: FxSpacing.md,
                          runSpacing: FxSpacing.xs,
                          children: [
                            Text(
                              FxMoneyFormatter.format(
                                bill.displayAmount,
                                locale: locale,
                                currencySymbol: symbol,
                              ),
                              style: metadataStyle.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            if (bill.feeTotal > 0)
                              Text(
                                '${strings.billsFee} ${FxMoneyFormatter.format(bill.feeTotal, locale: locale, currencySymbol: symbol)}',
                                style: metadataStyle,
                              ),
                            if (bill.discountTotal > 0)
                              Text(
                                '${strings.billsDiscount} ${FxMoneyFormatter.format(bill.discountTotal, locale: locale, currencySymbol: symbol)}',
                                style: metadataStyle,
                              ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
