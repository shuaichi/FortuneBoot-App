import 'package:equatable/equatable.dart';

/// ==============================
/// 查询参数模型 (Query Models)
/// ==============================

class BillTrendsQuery {
  final String bookId;
  final int timeGranularity; // 粒度：例如 1-日 2-周 3-月
  final String timePoint;    // 时间点
  final int? billType;       // 账单类型：可选

  BillTrendsQuery({
    required this.bookId,
    required this.timeGranularity,
    required this.timePoint,
    this.billType,
  });

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'timeGranularity': timeGranularity,
    'timePoint': timePoint,
    if (billType != null) 'billType': billType,
  };
}

class IncludeQuery {
  final String bookId;
  final String startDate;
  final String endDate;
  final String? title;
  final String? categoryIds;
  final String? tagIds;
  final String? payeeIds;
  final String? accountIds;

  IncludeQuery({
    required this.bookId,
    required this.startDate,
    required this.endDate,
    this.title,
    this.categoryIds,
    this.tagIds,
    this.payeeIds,
    this.accountIds,
  });

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'startDate': startDate,
    'endDate': endDate,
    if (title != null) 'title': title,
    if (categoryIds != null) 'categoryIds': categoryIds,
    if (tagIds != null) 'tagIds': tagIds,
    if (payeeIds != null) 'payeeIds': payeeIds,
    if (accountIds != null) 'accountIds': accountIds,
  };
}

/// ==============================
/// 响应数据模型 (Response Vo)
/// ==============================

class BillStatisticsVo extends Equatable {
  final double income;
  final double expense;
  final double surplus;

  const BillStatisticsVo({this.income = 0.0, this.expense = 0.0, this.surplus = 0.0});

  factory BillStatisticsVo.fromJson(Map<String, dynamic> json) => BillStatisticsVo(
    income: (json['income'] as num?)?.toDouble() ?? 0.0,
    expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
    surplus: (json['surplus'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props =>[income, expense, surplus];
}

class FortunePieVo extends Equatable {
  final String name;
  final double value;
  final double percent;

  const FortunePieVo({this.name = '', this.value = 0.0, this.percent = 0.0});

  factory FortunePieVo.fromJson(Map<String, dynamic> json) => FortunePieVo(
    name: json['name'] as String? ?? '未知',
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
    percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props => [name, value, percent];
}

class FortuneLineVo extends Equatable {
  final String name;
  final double value;

  const FortuneLineVo({this.name = '', this.value = 0.0});

  factory FortuneLineVo.fromJson(Map<String, dynamic> json) => FortuneLineVo(
    name: json['name'] as String? ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props => [name, value];
}

class FortuneBarVo extends Equatable {
  final String name;
  final double value;

  const FortuneBarVo({this.name = '', this.value = 0.0});

  factory FortuneBarVo.fromJson(Map<String, dynamic> json) => FortuneBarVo(
    name: json['name'] as String? ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props => [name, value];
}

class FortuneAssetsLiabilitiesVo extends Equatable {
  final double totalAssets;
  final double totalLiabilities;
  final double netAssets;

  const FortuneAssetsLiabilitiesVo({
    this.totalAssets = 0.0,
    this.totalLiabilities = 0.0,
    this.netAssets = 0.0,
  });

  factory FortuneAssetsLiabilitiesVo.fromJson(Map<String, dynamic> json) =>
      FortuneAssetsLiabilitiesVo(
        totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
        totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0.0,
        netAssets: (json['netAssets'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [totalAssets, totalLiabilities, netAssets];
}