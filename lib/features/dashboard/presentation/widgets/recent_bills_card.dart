import 'package:flutter/material.dart';
import 'package:fortuneboot/core/icon/fx_icon_badge.dart';
import 'package:fortuneboot/core/icon/smart_category_engine.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_shell.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

/// ⑦ 最近账单卡（跨满）：最近 3 条 + "全部 >"。
class RecentBillsCard extends StatelessWidget {
  final DashboardSection<List<FortuneBillVo>> section;
  final String? currencyCode;
  final VoidCallback onRetry;

  const RecentBillsCard({
    super.key,
    required this.section,
    required this.currencyCode,
    required this.onRetry,
  });

  static final DateFormat _md = DateFormat('MM-dd');

  @override
  Widget build(BuildContext context) {
    return DashboardCardShell<List<FortuneBillVo>>(
      section: section,
      onRetry: onRetry,
      builder: (bills) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxCardLabel(
              '最近账单',
              trailing: GestureDetector(
                onTap: () => AppRouter.push<void>(context, Routes.bills),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '全部',
                      style: FxTypography.caption.copyWith(
                        color: FxColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: FxColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FxSpacing.sm),
            if (bills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: FxSpacing.lg),
                child: Center(
                  child: Text('还没有账单', style: FxTypography.caption),
                ),
              )
            else
              ...bills.map((b) => _row(context, b)),
          ],
        );
      },
    );
  }

  Widget _row(BuildContext context, FortuneBillVo bill) {
    final title = (bill.title?.isNotEmpty ?? false)
        ? bill.title!
        : (bill.primaryCategoryName.isNotEmpty
              ? bill.primaryCategoryName
              : (bill.payeeName ?? '账单'));
    final dateText = bill.tradeTime == null ? '' : _md.format(bill.tradeTime!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.xs),
      child: Row(
        children: [
          FxIconBadge.forBill(
            BillIconInput(
              billType: bill.billType,
              title: bill.title,
              payeeName: bill.payeeName,
              accountName: bill.accountName,
              categoryNames: bill.categoryNamesByAmount,
              toAccountId: bill.toAccountId,
            ),
            size: 36,
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FxTypography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (bill.accountName?.isNotEmpty ?? false)
                  Text(
                    bill.accountName!,
                    style: FxTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FxMoneyText(
                amount: bill.displayAmount,
                currencyCode: bill.currencyCode ?? currencyCode,
                billType: bill.billType,
                fontSize: 15,
              ),
              Text(dateText, style: FxTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}
