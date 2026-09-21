import 'package:fortuneboot/core/network/fx_api.dart';

/// 分组 VO（会话共享模型）。
class FortuneGroupVo {
  final int? groupId;
  final String? groupName;
  final String? defaultCurrency;
  /// 当前用户在该组的角色：1 管理员 / 2 协作者 / 3 访客。
  final int? roleType;
  final String? roleTypeDesc;
  final bool enable;
  final int? defaultBookId;
  final String? defaultBookName;
  final String? remark;

  const FortuneGroupVo({
    this.groupId,
    this.groupName,
    this.defaultCurrency,
    this.roleType,
    this.roleTypeDesc,
    this.enable = true,
    this.defaultBookId,
    this.defaultBookName,
    this.remark,
  });

  factory FortuneGroupVo.fromJson(Map<String, dynamic> json) {
    return FortuneGroupVo(
      groupId: FxApi.asId(json['groupId']),
      groupName: json['groupName']?.toString(),
      defaultCurrency: json['defaultCurrency']?.toString(),
      roleType: FxApi.asId(json['roleType']),
      roleTypeDesc: json['roleTypeDesc']?.toString(),
      enable: FxApi.asBool(json['enable'], orElse: true),
      defaultBookId: FxApi.asId(json['defaultBookId']),
      defaultBookName: json['defaultBookName']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  /// 详情接口可能不含角色；用启用列表中的同组角色补齐。
  FortuneGroupVo withRoleFrom(FortuneGroupVo? other) {
    if (other == null) return this;
    final desc = (roleTypeDesc != null && roleTypeDesc!.trim().isNotEmpty)
        ? roleTypeDesc
        : other.roleTypeDesc;
    return FortuneGroupVo(
      groupId: groupId ?? other.groupId,
      groupName: groupName ?? other.groupName,
      defaultCurrency: defaultCurrency ?? other.defaultCurrency,
      roleType: roleType ?? other.roleType,
      roleTypeDesc: desc,
      enable: enable,
      defaultBookId: defaultBookId ?? other.defaultBookId,
      defaultBookName: defaultBookName ?? other.defaultBookName,
      remark: remark ?? other.remark,
    );
  }

  FortuneGroupVo copyWith({String? defaultCurrency}) {
    return FortuneGroupVo(
      groupId: groupId,
      groupName: groupName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      roleType: roleType,
      roleTypeDesc: roleTypeDesc,
      enable: enable,
      defaultBookId: defaultBookId,
      defaultBookName: defaultBookName,
      remark: remark,
    );
  }
}

/// 账本 VO（会话共享模型）。
class FortuneBookVo {
  final int? bookId;
  final int? groupId;
  final String? bookName;
  final String? defaultCurrency;
  final int? defaultExpenseAccountId;
  final String? defaultExpenseAccountName;
  final int? defaultIncomeAccountId;
  final String? defaultIncomeAccountName;
  final int? defaultTransferOutAccountId;
  final String? defaultTransferOutAccountName;
  final int? defaultTransferInAccountId;
  final String? defaultTransferInAccountName;
  final int? sort;
  final String? remark;
  final bool enable;

  const FortuneBookVo({
    this.bookId,
    this.groupId,
    this.bookName,
    this.defaultCurrency,
    this.defaultExpenseAccountId,
    this.defaultExpenseAccountName,
    this.defaultIncomeAccountId,
    this.defaultIncomeAccountName,
    this.defaultTransferOutAccountId,
    this.defaultTransferOutAccountName,
    this.defaultTransferInAccountId,
    this.defaultTransferInAccountName,
    this.sort,
    this.remark,
    this.enable = true,
  });

  factory FortuneBookVo.fromJson(Map<String, dynamic> json) {
    return FortuneBookVo(
      bookId: FxApi.asId(json['bookId']),
      groupId: FxApi.asId(json['groupId']),
      bookName: json['bookName']?.toString(),
      defaultCurrency: json['defaultCurrency']?.toString(),
      defaultExpenseAccountId: FxApi.asId(json['defaultExpenseAccountId']),
      defaultExpenseAccountName: json['defaultExpenseAccountName']?.toString(),
      defaultIncomeAccountId: FxApi.asId(json['defaultIncomeAccountId']),
      defaultIncomeAccountName: json['defaultIncomeAccountName']?.toString(),
      defaultTransferOutAccountId: FxApi.asId(
        json['defaultTransferOutAccountId'],
      ),
      defaultTransferOutAccountName: json['defaultTransferOutAccountName']
          ?.toString(),
      defaultTransferInAccountId: FxApi.asId(
        json['defaultTransferInAccountId'],
      ),
      defaultTransferInAccountName: json['defaultTransferInAccountName']
          ?.toString(),
      sort: FxApi.asId(json['sort']),
      remark: json['remark']?.toString(),
      enable: FxApi.asBool(json['enable'], orElse: true),
    );
  }

  FortuneBookVo copyWith({String? defaultCurrency}) {
    return FortuneBookVo(
      bookId: bookId,
      groupId: groupId,
      bookName: bookName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultExpenseAccountId: defaultExpenseAccountId,
      defaultExpenseAccountName: defaultExpenseAccountName,
      defaultIncomeAccountId: defaultIncomeAccountId,
      defaultIncomeAccountName: defaultIncomeAccountName,
      defaultTransferOutAccountId: defaultTransferOutAccountId,
      defaultTransferOutAccountName: defaultTransferOutAccountName,
      defaultTransferInAccountId: defaultTransferInAccountId,
      defaultTransferInAccountName: defaultTransferInAccountName,
      sort: sort,
      remark: remark,
      enable: enable,
    );
  }
}
