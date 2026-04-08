import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'bill_stats_chart_EI.g.dart';

@immutable
@JsonSerializable()
class BillStatsChartEi {
  String? name;
  double? value;

  BillStatsChartEi({
    required this.name,
    required this.value,
  });

  factory BillStatsChartEi.fromJson(Map<String, dynamic> json) =>
      _$BillStatsChartEiFromJson(json);
  Map<String, dynamic> toJson() => _$BillStatsChartEiToJson(this);

  @override
  String toString() {
    return 'BillStatsChartEi: name:$name, value:$value';
  }
}
