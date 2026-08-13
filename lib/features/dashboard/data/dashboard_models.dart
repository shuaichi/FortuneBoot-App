import 'package:fortuneboot/core/network/fx_api.dart';

/// 净资产总览：总资产 / 总负债 / 净资产。BigDecimal 可能是 num 或 String。
class AssetsLiabilities {
  final double totalAssets;
  final double totalLiabilities;
  final double netAssets;

  const AssetsLiabilities({
    this.totalAssets = 0,
    this.totalLiabilities = 0,
    this.netAssets = 0,
  });

  factory AssetsLiabilities.fromJson(Map<String, dynamic> json) {
    final assets = FxApi.asDouble(json['totalAssets']) ?? 0;
    final liabilities = FxApi.asDouble(json['totalLiabilities']) ?? 0;
    return AssetsLiabilities(
      totalAssets: assets,
      totalLiabilities: liabilities,
      netAssets: FxApi.asDouble(json['netAssets']) ?? (assets - liabilities),
    );
  }
}

/// 收支趋势点（FortuneLineVo：name 为日期/标签，value 为金额）。
class TrendPoint {
  final String name;
  final double value;

  const TrendPoint({this.name = '', this.value = 0});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
  );
}

/// 分类支出切片（FortunePieVo：name 分类名，value 金额，percent 占比 0-100）。
class CategorySlice {
  final String name;
  final double value;
  final double percent;

  const CategorySlice({this.name = '', this.value = 0, this.percent = 0});

  factory CategorySlice.fromJson(Map<String, dynamic> json) => CategorySlice(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
    percent: FxApi.asDouble(json['percent']) ?? 0,
  );

  factory CategorySlice.fromExpenseEnvelope(Map<String, dynamic> json) =>
      CategorySlice(
        name: json['categoryName']?.toString() ?? '',
        value: FxApi.asDouble(json['total']) ?? 0,
        percent: FxApi.asDouble(json['percentage']) ?? 0,
      );
}
