import 'package:fortuneboot/core/network/fx_api.dart';

/// 趋势点（FortuneLineVo：name 为日期/月份标签，value 为金额）。
class TrendPoint {
  final String name;
  final double value;

  const TrendPoint({this.name = '', this.value = 0});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
  );
}

/// 饼图切片（FortunePieVo：name 名称，value 金额，percent 占比 0-100）。
class PieSlice {
  final String name;
  final double value;
  final double percent;
  final int? id;
  final int? billCount;

  const PieSlice({
    this.name = '',
    this.value = 0,
    this.percent = 0,
    this.id,
    this.billCount,
  });

  factory PieSlice.fromJson(Map<String, dynamic> json) => PieSlice(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
    percent: FxApi.asDouble(json['percent']) ?? 0,
    id: FxApi.asId(json['id'] ?? json['accountId']),
    billCount: FxApi.asId(json['billCount']),
  );

  factory PieSlice.fromCategoryExpense(Map<String, dynamic> json) => PieSlice(
    id: FxApi.asId(json['categoryId']),
    name: json['categoryName']?.toString() ?? '',
    value: FxApi.asDouble(json['total']) ?? 0,
    percent: FxApi.asDouble(json['percentage']) ?? 0,
    billCount: FxApi.asId(json['billCount']),
  );

  factory PieSlice.fromPayeeExpense(Map<String, dynamic> json) => PieSlice(
    id: FxApi.asId(json['payeeId']),
    name: json['payeeName']?.toString() ?? '',
    value: FxApi.asDouble(json['total']) ?? 0,
    percent: FxApi.asDouble(json['percentage']) ?? 0,
    billCount: FxApi.asId(json['billCount']),
  );
}

/// 柱图项（FortuneBarVo：name 名称，value 金额）。
class BarItem {
  final String name;
  final double value;
  final int? id;
  final double percent;
  final int? billCount;

  const BarItem({
    this.name = '',
    this.value = 0,
    this.id,
    this.percent = 0,
    this.billCount,
  });

  factory BarItem.fromJson(Map<String, dynamic> json) => BarItem(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
    id: FxApi.asId(json['id']),
    percent: FxApi.asDouble(json['percent']) ?? 0,
    billCount: FxApi.asId(json['billCount']),
  );

  factory BarItem.fromTagExpense(Map<String, dynamic> json) => BarItem(
    id: FxApi.asId(json['tagId']),
    name: json['tagName']?.toString() ?? '',
    value: FxApi.asDouble(json['total']) ?? 0,
    percent: FxApi.asDouble(json['percentage']) ?? 0,
    billCount: FxApi.asId(json['billCount']),
  );
}

class DimensionStat<T> {
  final double total;
  final List<T> items;

  const DimensionStat({this.total = 0, this.items = const []});
}

class BillComparePoint {
  final String name;
  final double income;
  final double expense;
  final int incomeCount;
  final int expenseCount;

  const BillComparePoint({
    this.name = '',
    this.income = 0,
    this.expense = 0,
    this.incomeCount = 0,
    this.expenseCount = 0,
  });

  factory BillComparePoint.fromJson(Map<String, dynamic> json) =>
      BillComparePoint(
        name: json['name']?.toString() ?? '',
        income: FxApi.asDouble(json['income']) ?? 0,
        expense: FxApi.asDouble(json['expense']) ?? 0,
        incomeCount: FxApi.asId(json['incomeCount']) ?? 0,
        expenseCount: FxApi.asId(json['expenseCount']) ?? 0,
      );
}

class BillRankItem {
  final int? billId;
  final String title;
  final double amount;
  final String billDate;
  final String categoryName;
  final int? billType;

  const BillRankItem({
    this.billId,
    this.title = '',
    this.amount = 0,
    this.billDate = '',
    this.categoryName = '',
    this.billType,
  });

  factory BillRankItem.fromJson(Map<String, dynamic> json) => BillRankItem(
    billId: FxApi.asId(json['billId']),
    title: json['title']?.toString() ?? '',
    amount: FxApi.asDouble(json['amount']) ?? 0,
    billDate: json['billDate']?.toString() ?? '',
    categoryName: json['categoryName']?.toString() ?? '',
    billType: FxApi.asId(json['billType']),
  );
}

class IncludeParticipantStat {
  final int? id;
  final String name;
  final double totalIncome;
  final double totalExpense;
  final int billCount;

  const IncludeParticipantStat({
    this.id,
    this.name = '',
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.billCount = 0,
  });

  factory IncludeParticipantStat.fromAccount(Map<String, dynamic> json) =>
      IncludeParticipantStat(
        id: FxApi.asId(json['accountId']),
        name: json['accountName']?.toString() ?? '',
        totalIncome: FxApi.asDouble(json['totalIncome']) ?? 0,
        totalExpense: FxApi.asDouble(json['totalExpense']) ?? 0,
        billCount: FxApi.asId(json['billCount']) ?? 0,
      );

  factory IncludeParticipantStat.fromMember(Map<String, dynamic> json) =>
      IncludeParticipantStat(
        id: FxApi.asId(json['memberId']),
        name: json['memberName']?.toString() ?? '',
        totalIncome: FxApi.asDouble(json['totalIncome']) ?? 0,
        totalExpense: FxApi.asDouble(json['totalExpense']) ?? 0,
        billCount: FxApi.asId(json['billCount']) ?? 0,
      );
}

class DateIncludePoint {
  final String name;
  final double income;
  final double expense;
  final int incomeCount;
  final int expenseCount;

  const DateIncludePoint({
    this.name = '',
    this.income = 0,
    this.expense = 0,
    this.incomeCount = 0,
    this.expenseCount = 0,
  });

  factory DateIncludePoint.fromJson(Map<String, dynamic> json) =>
      DateIncludePoint(
        name: json['name']?.toString() ?? '',
        income: FxApi.asDouble(json['income']) ?? 0,
        expense: FxApi.asDouble(json['expense']) ?? 0,
        incomeCount: FxApi.asId(json['incomeCount']) ?? 0,
        expenseCount: FxApi.asId(json['expenseCount']) ?? 0,
      );
}

class BillTypeDistributionItem {
  final int? billType;
  final String billTypeName;
  final double total;
  final double percentage;
  final int billCount;

  const BillTypeDistributionItem({
    this.billType,
    this.billTypeName = '',
    this.total = 0,
    this.percentage = 0,
    this.billCount = 0,
  });

  factory BillTypeDistributionItem.fromJson(Map<String, dynamic> json) =>
      BillTypeDistributionItem(
        billType: FxApi.asId(json['billType']),
        billTypeName: json['billTypeName']?.toString() ?? '',
        total: FxApi.asDouble(json['total']) ?? 0,
        percentage: FxApi.asDouble(json['percentage']) ?? 0,
        billCount: FxApi.asId(json['billCount']) ?? 0,
      );
}

class CalendarHeatmapPoint {
  final String date;
  final double amount;
  final int billCount;

  const CalendarHeatmapPoint({
    this.date = '',
    this.amount = 0,
    this.billCount = 0,
  });

  factory CalendarHeatmapPoint.fromJson(Map<String, dynamic> json) =>
      CalendarHeatmapPoint(
        date: (json['date'] ?? json['name'] ?? json['day'])?.toString() ?? '',
        amount: FxApi.asDouble(json['amount'] ?? json['value']) ?? 0,
        billCount: FxApi.asId(json['billCount'] ?? json['count']) ?? 0,
      );
}

class NetAssetsTrendPoint {
  final String name;
  final double totalAssets;
  final double totalLiabilities;
  final double netAssets;
  final String snapshotDate;

  const NetAssetsTrendPoint({
    this.name = '',
    this.totalAssets = 0,
    this.totalLiabilities = 0,
    this.netAssets = 0,
    this.snapshotDate = '',
  });

  factory NetAssetsTrendPoint.fromJson(Map<String, dynamic> json) {
    final assets = FxApi.asDouble(json['totalAssets']) ?? 0;
    final liabilities = FxApi.asDouble(json['totalLiabilities']) ?? 0;
    return NetAssetsTrendPoint(
      name: json['name']?.toString() ?? '',
      totalAssets: assets,
      totalLiabilities: liabilities,
      netAssets: FxApi.asDouble(json['netAssets']) ?? (assets - liabilities),
      snapshotDate: json['snapshotDate']?.toString() ?? '',
    );
  }
}

class AssetAccountItem {
  final int? accountId;
  final String accountName;
  final double balance;
  final double creditLimit;
  final double unsettledAmount;

  const AssetAccountItem({
    this.accountId,
    this.accountName = '',
    this.balance = 0,
    this.creditLimit = 0,
    this.unsettledAmount = 0,
  });

  factory AssetAccountItem.fromJson(Map<String, dynamic> json) =>
      AssetAccountItem(
        accountId: FxApi.asId(json['accountId'] ?? json['id']),
        accountName: (json['accountName'] ?? json['name'])?.toString() ?? '',
        balance: FxApi.asDouble(json['balance'] ?? json['value']) ?? 0,
        creditLimit: FxApi.asDouble(json['creditLimit']) ?? 0,
        unsettledAmount: FxApi.asDouble(json['unsettledAmount']) ?? 0,
      );
}

class AssetsByAccountType {
  final int? accountType;
  final String accountTypeName;
  final double assets;
  final int accountCount;
  final List<AssetAccountItem> accounts;

  const AssetsByAccountType({
    this.accountType,
    this.accountTypeName = '',
    this.assets = 0,
    this.accountCount = 0,
    this.accounts = const [],
  });

  factory AssetsByAccountType.fromJson(Map<String, dynamic> json) =>
      AssetsByAccountType(
        accountType: FxApi.asId(json['accountType']),
        accountTypeName: json['accountTypeName']?.toString() ?? '',
        assets: FxApi.asDouble(json['assets'] ?? json['value']) ?? 0,
        accountCount: FxApi.asId(json['accountCount']) ?? 0,
        accounts: _parseObjectList(json['accounts'], AssetAccountItem.fromJson),
      );
}

class CreditCardOverview {
  final int? accountId;
  final String accountName;
  final String billingDate;
  final String repaymentDate;
  final double usageRate;
  final double usedAmount;
  final double availableAmount;
  final double unsettledAmount;

  const CreditCardOverview({
    this.accountId,
    this.accountName = '',
    this.billingDate = '',
    this.repaymentDate = '',
    this.usageRate = 0,
    this.usedAmount = 0,
    this.availableAmount = 0,
    this.unsettledAmount = 0,
  });

  factory CreditCardOverview.fromJson(Map<String, dynamic> json) =>
      CreditCardOverview(
        accountId: FxApi.asId(json['accountId'] ?? json['id']),
        accountName: (json['accountName'] ?? json['name'])?.toString() ?? '',
        billingDate: json['billingDate']?.toString() ?? '',
        repaymentDate: json['repaymentDate']?.toString() ?? '',
        usageRate: FxApi.asDouble(json['usageRate']) ?? 0,
        usedAmount: FxApi.asDouble(json['usedAmount']) ?? 0,
        availableAmount: FxApi.asDouble(json['availableAmount']) ?? 0,
        unsettledAmount: FxApi.asDouble(json['unsettledAmount']) ?? 0,
      );
}

class AccountBalanceTrendPoint {
  final String name;
  final double balance;
  final String snapshotDate;

  const AccountBalanceTrendPoint({
    this.name = '',
    this.balance = 0,
    this.snapshotDate = '',
  });

  factory AccountBalanceTrendPoint.fromJson(Map<String, dynamic> json) =>
      AccountBalanceTrendPoint(
        name: json['name']?.toString() ?? '',
        balance: FxApi.asDouble(json['balance'] ?? json['value']) ?? 0,
        snapshotDate: json['snapshotDate']?.toString() ?? '',
      );
}

class LoanOverview {
  final double totalLoanReceivable;
  final int receivableBillCount;
  final double totalLoanPayable;
  final int payableBillCount;
  final int pendingConfirmCount;
  final double overdueReceivable;
  final double overduePayable;
  final double maxSingleReceivable;
  final double maxSinglePayable;

  const LoanOverview({
    this.totalLoanReceivable = 0,
    this.receivableBillCount = 0,
    this.totalLoanPayable = 0,
    this.payableBillCount = 0,
    this.pendingConfirmCount = 0,
    this.overdueReceivable = 0,
    this.overduePayable = 0,
    this.maxSingleReceivable = 0,
    this.maxSinglePayable = 0,
  });

  factory LoanOverview.fromJson(Map<String, dynamic> json) => LoanOverview(
    totalLoanReceivable: FxApi.asDouble(json['totalLoanReceivable']) ?? 0,
    receivableBillCount: FxApi.asId(json['receivableBillCount']) ?? 0,
    totalLoanPayable: FxApi.asDouble(json['totalLoanPayable']) ?? 0,
    payableBillCount: FxApi.asId(json['payableBillCount']) ?? 0,
    pendingConfirmCount: FxApi.asId(json['pendingConfirmCount']) ?? 0,
    overdueReceivable: FxApi.asDouble(json['overdueReceivable']) ?? 0,
    overduePayable: FxApi.asDouble(json['overduePayable']) ?? 0,
    maxSingleReceivable: FxApi.asDouble(json['maxSingleReceivable']) ?? 0,
    maxSinglePayable: FxApi.asDouble(json['maxSinglePayable']) ?? 0,
  );
}

class FinanceProfitItem {
  final int? billId;
  final String title;
  final double amount;
  final String billDate;
  final int? billType;

  const FinanceProfitItem({
    this.billId,
    this.title = '',
    this.amount = 0,
    this.billDate = '',
    this.billType,
  });

  factory FinanceProfitItem.fromJson(Map<String, dynamic> json) =>
      FinanceProfitItem(
        billId: FxApi.asId(json['billId']),
        title: json['title']?.toString() ?? '',
        amount: FxApi.asDouble(json['amount']) ?? 0,
        billDate: json['billDate']?.toString() ?? '',
        billType: FxApi.asId(json['billType']),
      );
}

class FinanceProfit {
  final double totalProfit;
  final double totalLoss;
  final double netProfit;
  final int profitBillCount;
  final int lossBillCount;
  final double maxSingleProfit;
  final double maxSingleLoss;
  final List<FinanceProfitItem> items;

  const FinanceProfit({
    this.totalProfit = 0,
    this.totalLoss = 0,
    this.netProfit = 0,
    this.profitBillCount = 0,
    this.lossBillCount = 0,
    this.maxSingleProfit = 0,
    this.maxSingleLoss = 0,
    this.items = const [],
  });

  factory FinanceProfit.fromJson(Map<String, dynamic> json) => FinanceProfit(
    totalProfit: FxApi.asDouble(json['totalProfit']) ?? 0,
    totalLoss: FxApi.asDouble(json['totalLoss']) ?? 0,
    netProfit: FxApi.asDouble(json['netProfit']) ?? 0,
    profitBillCount: FxApi.asId(json['profitBillCount']) ?? 0,
    lossBillCount: FxApi.asId(json['lossBillCount']) ?? 0,
    maxSingleProfit: FxApi.asDouble(json['maxSingleProfit']) ?? 0,
    maxSingleLoss: FxApi.asDouble(json['maxSingleLoss']) ?? 0,
    items: _parseObjectList(
      json['financeProfitList'] ?? json['items'],
      FinanceProfitItem.fromJson,
    ),
  );
}

class StatisticsPolicy {
  final bool defaultInclude;
  final List<int> includeTypes;
  final List<int> excludeTypes;
  final String policyDesc;

  const StatisticsPolicy({
    this.defaultInclude = true,
    this.includeTypes = const [],
    this.excludeTypes = const [],
    this.policyDesc = '',
  });

  factory StatisticsPolicy.fromJson(Map<String, dynamic> json) =>
      StatisticsPolicy(
        defaultInclude: FxApi.asBool(json['defaultInclude'], orElse: true),
        includeTypes: _parseIntList(json['includeTypes']),
        excludeTypes: _parseIntList(json['excludeTypes']),
        policyDesc: json['policyDesc']?.toString() ?? '',
      );
}

List<T> _parseObjectList<T>(
  dynamic data,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (data is List) {
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <T>[];
}

List<int> _parseIntList(dynamic data) {
  if (data is List) {
    return data.map(FxApi.asId).whereType<int>().toList();
  }
  return const [];
}
