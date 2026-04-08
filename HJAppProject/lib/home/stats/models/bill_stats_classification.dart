import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'bill_stats_classification.g.dart';

@immutable
@JsonSerializable()
class BillStatsClassification {
  String? name;
  double? value;
  double? percent;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Color? color;

  BillStatsClassification({
    required this.name,
    required this.value,
    required this.percent,
  });

  factory BillStatsClassification.fromJson(Map<String, dynamic> json) =>
      _$BillStatsClassificationFromJson(json);
  Map<String, dynamic> toJson() => _$BillStatsClassificationToJson(this);

  @override
  String toString() {
    return 'BillStatsClassification: name:$name, v:$value, percent: $percent';
  }
}
