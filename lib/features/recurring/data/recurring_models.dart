import 'dart:convert';

import 'package:fortuneboot/core/network/fx_api.dart';

/// 周期记账规则 VO（出参）。
///
/// 注意 [billRequest] 出参是 JSON 字符串（入参却是对象），此处保留解析后的 Map
/// 供模板预填。
class RecurringRuleVo {
  final int? bookId;
  final int? ruleId;
  final String? ruleName;
  final String? cronExpression;
  final bool enable;
  final Map<String, dynamic>? billRequest; // 已从 JSON 字符串解析
  final String? startDate;
  final String? endDate;
  final int? maxExecutions;
  final int? executedCount;
  final String? lastExecutedTime;
  final String? nextExecutionTime;
  final String? recoveryStrategy;
  final String? remark;

  const RecurringRuleVo({
    this.bookId,
    this.ruleId,
    this.ruleName,
    this.cronExpression,
    this.enable = true,
    this.billRequest,
    this.startDate,
    this.endDate,
    this.maxExecutions,
    this.executedCount,
    this.lastExecutedTime,
    this.nextExecutionTime,
    this.recoveryStrategy,
    this.remark,
  });

  factory RecurringRuleVo.fromJson(Map<String, dynamic> json) {
    return RecurringRuleVo(
      bookId: FxApi.asId(json['bookId']),
      ruleId: FxApi.asId(json['ruleId']),
      ruleName: json['ruleName']?.toString(),
      cronExpression: json['cronExpression']?.toString(),
      enable: FxApi.asBool(json['enable'], orElse: true),
      billRequest: _parseBillRequest(json['billRequest']),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      maxExecutions: FxApi.asId(json['maxExecutions']),
      executedCount: FxApi.asId(json['executedCount']),
      lastExecutedTime: json['lastExecutedTime']?.toString(),
      nextExecutionTime: json['nextExecutionTime']?.toString(),
      recoveryStrategy: json['recoveryStrategy']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  /// billRequest 出参可能是 JSON 字符串或已是 Map，兼容解析。
  static Map<String, dynamic>? _parseBillRequest(dynamic v) {
    if (v == null) return null;
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is String && v.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } on FormatException {
        return null;
      }
    }
    return null;
  }
}

/// 执行日志 VO。
class RecurringLogVo {
  final int? logId;
  final String? executionTime;
  final String? status;
  final int? billId;
  final String? errorMsg;
  final int? executionDuration;

  const RecurringLogVo({
    this.logId,
    this.executionTime,
    this.status,
    this.billId,
    this.errorMsg,
    this.executionDuration,
  });

  factory RecurringLogVo.fromJson(Map<String, dynamic> json) => RecurringLogVo(
        logId: FxApi.asId(json['logId']),
        executionTime: json['executionTime']?.toString(),
        status: json['status']?.toString(),
        billId: FxApi.asId(json['billId']),
        errorMsg: json['errorMsg']?.toString(),
        executionDuration: FxApi.asId(json['executionDuration']),
      );
}

/// 补偿策略选项 {value,label}。
class RecoveryStrategyOption {
  final String value;
  final String label;

  const RecoveryStrategyOption({required this.value, required this.label});

  factory RecoveryStrategyOption.fromJson(Map<String, dynamic> json) =>
      RecoveryStrategyOption(
        value: (json['value'] ?? '').toString(),
        label: (json['label'] ?? json['value'] ?? '').toString(),
      );
}
