import 'package:fortuneboot/core/network/fx_api.dart';

/// 交易对象 VO（FortunePayeeVo）——扁平列表，有 canExpense/canIncome。
class FortunePayeeVo {
  final int? payeeId;
  final String? payeeName;
  final int? sort;
  final bool canExpense;
  final bool canIncome;
  final bool enable;
  final String? remark;

  const FortunePayeeVo({
    this.payeeId,
    this.payeeName,
    this.sort,
    this.canExpense = false,
    this.canIncome = false,
    this.enable = true,
    this.remark,
  });

  factory FortunePayeeVo.fromJson(Map<String, dynamic> json) {
    return FortunePayeeVo(
      payeeId: FxApi.asId(json['payeeId']),
      payeeName: json['payeeName']?.toString(),
      sort: FxApi.asId(json['sort']),
      canExpense: FxApi.asBool(json['canExpense']),
      canIncome: FxApi.asBool(json['canIncome']),
      enable: FxApi.asBool(json['enable'], orElse: true),
      remark: json['remark']?.toString(),
    );
  }

  FortunePayeeVo copyWith({
    bool? canExpense,
    bool? canIncome,
    bool? enable,
  }) {
    return FortunePayeeVo(
      payeeId: payeeId,
      payeeName: payeeName,
      sort: sort,
      canExpense: canExpense ?? this.canExpense,
      canIncome: canIncome ?? this.canIncome,
      enable: enable ?? this.enable,
      remark: remark,
    );
  }
}

/// 交易对象开关字段 → 开/关 PATCH 动作名。
enum PayeeToggleField {
  canExpense('canExpense', 'cannotExpense', '可支出'),
  canIncome('canIncome', 'cannotIncome', '可收入'),
  enable('enable', 'disable', '启用');

  const PayeeToggleField(this.onAction, this.offAction, this.label);

  final String onAction;
  final String offAction;
  final String label;

  String action(bool on) => on ? onAction : offAction;
}
