import 'package:fortuneboot/core/network/fx_api.dart';

/// 标签 VO（FortuneTagVo）——树形，有 canExpense/canIncome/canTransfer。
class FortuneTagVo {
  final int? tagId;
  final int? parentId;
  final String? tagName;
  final int? sort;
  final String? remark;
  final bool canExpense;
  final bool canIncome;
  final bool canTransfer;
  final bool enable;
  final bool recycleBin;
  final List<FortuneTagVo> children;

  const FortuneTagVo({
    this.tagId,
    this.parentId,
    this.tagName,
    this.sort,
    this.remark,
    this.canExpense = false,
    this.canIncome = false,
    this.canTransfer = false,
    this.enable = true,
    this.recycleBin = false,
    this.children = const [],
  });

  factory FortuneTagVo.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = <FortuneTagVo>[];
    if (rawChildren is List) {
      for (final c in rawChildren) {
        if (c is Map) {
          children.add(FortuneTagVo.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }
    return FortuneTagVo(
      tagId: FxApi.asId(json['tagId']),
      parentId: FxApi.asId(json['parentId']),
      tagName: json['tagName']?.toString(),
      sort: FxApi.asId(json['sort']),
      remark: json['remark']?.toString(),
      canExpense: FxApi.asBool(json['canExpense']),
      canIncome: FxApi.asBool(json['canIncome']),
      canTransfer: FxApi.asBool(json['canTransfer']),
      enable: FxApi.asBool(json['enable'], orElse: true),
      recycleBin: FxApi.asBool(json['recycleBin']),
      children: children,
    );
  }

  FortuneTagVo copyWith({
    bool? canExpense,
    bool? canIncome,
    bool? canTransfer,
    bool? enable,
    List<FortuneTagVo>? children,
  }) {
    return FortuneTagVo(
      tagId: tagId,
      parentId: parentId,
      tagName: tagName,
      sort: sort,
      remark: remark,
      canExpense: canExpense ?? this.canExpense,
      canIncome: canIncome ?? this.canIncome,
      canTransfer: canTransfer ?? this.canTransfer,
      enable: enable ?? this.enable,
      recycleBin: recycleBin,
      children: children ?? this.children,
    );
  }
}

/// 标签开关字段 → 开/关 PATCH 动作名。
enum TagToggleField {
  canExpense('canExpense', 'cannotExpense', '可支出'),
  canIncome('canIncome', 'cannotIncome', '可收入'),
  canTransfer('canTransfer', 'cannotTransfer', '可转账'),
  enable('enable', 'disable', '启用');

  const TagToggleField(this.onAction, this.offAction, this.label);

  final String onAction;
  final String offAction;
  final String label;

  String action(bool on) => on ? onAction : offAction;
}
