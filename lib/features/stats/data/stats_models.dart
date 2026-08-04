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

  const PieSlice({this.name = '', this.value = 0, this.percent = 0});

  factory PieSlice.fromJson(Map<String, dynamic> json) => PieSlice(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
    percent: FxApi.asDouble(json['percent']) ?? 0,
  );
}

/// 柱图项（FortuneBarVo：name 名称，value 金额）。
class BarItem {
  final String name;
  final double value;

  const BarItem({this.name = '', this.value = 0});

  factory BarItem.fromJson(Map<String, dynamic> json) => BarItem(
    name: json['name']?.toString() ?? '',
    value: FxApi.asDouble(json['value']) ?? 0,
  );
}
