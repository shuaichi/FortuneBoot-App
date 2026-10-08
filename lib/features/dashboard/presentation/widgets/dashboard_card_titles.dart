import 'package:flutter/widgets.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/generated/l10n.dart';

String dashboardCardTitle(BuildContext context, DashboardCardId id) {
  final s = S.of(context);
  return switch (id) {
    DashboardCardId.netWorth => s.dashboardNetWorth,
    DashboardCardId.monthExpense => s.dashboardPeriodExpense,
    DashboardCardId.monthIncome => s.dashboardPeriodIncome,
    DashboardCardId.trend => s.dashboardIncomeExpenseTrend,
    DashboardCardId.recentBills => s.dashboardRecentBills,
    DashboardCardId.categoryTop => s.dashboardTopCategories,
    DashboardCardId.quickAdd => s.dashboardQuickAdd,
  };
}
