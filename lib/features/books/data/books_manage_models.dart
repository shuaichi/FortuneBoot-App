import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/generated/l10n.dart';

class PagedRows<T> {
  const PagedRows({required this.rows, this.total});

  final List<T> rows;
  final int? total;

  bool get hasMore => total != null && total! > rows.length;
}

class ManagedGroup {
  const ManagedGroup({required this.group, this.roleType});

  final FortuneGroupVo group;
  final int? roleType;

  int? get groupId => group.groupId;
  String get name => group.groupName?.trim().isNotEmpty == true
      ? group.groupName!.trim()
      : S.current.booksUnnamedGroup;
  String? get defaultCurrency => group.defaultCurrency;
  String? get roleTypeDesc => group.roleTypeDesc;
  bool get enable => group.enable;
  int? get defaultBookId => group.defaultBookId;
  String? get defaultBookName => group.defaultBookName;
  String? get remark => group.remark;

  factory ManagedGroup.fromJson(Map<String, dynamic> json) {
    return ManagedGroup(
      group: FortuneGroupVo.fromJson(json),
      roleType: FxApi.asId(json['roleType'] ?? json['role_type']),
    );
  }
}

class RoleTypeOption {
  const RoleTypeOption({required this.value, required this.label});

  final int value;
  final String label;

  factory RoleTypeOption.fromEntry(Object? key, Object? value) {
    return RoleTypeOption(
      value: FxApi.asId(key) ?? FxApi.asId(value) ?? 3,
      label: value?.toString() ?? key?.toString() ?? S.current.booksRoleVisitor,
    );
  }

  factory RoleTypeOption.fromJson(Map<String, dynamic> json) {
    return RoleTypeOption(
      value: FxApi.asId(json['value'] ?? json['roleType']) ?? 3,
      label:
          (json['label'] ??
                  json['desc'] ??
                  json['roleName'] ??
                  S.current.booksRoleVisitor)
              .toString(),
    );
  }
}

class GroupMemberVo {
  const GroupMemberVo({
    this.relationId,
    this.userId,
    this.username,
    this.nickname,
    this.roleType,
    this.roleTypeDesc,
  });

  final int? relationId;
  final int? userId;
  final String? username;
  final String? nickname;
  final int? roleType;
  final String? roleTypeDesc;

  String get displayName {
    final nick = nickname?.trim();
    if (nick != null && nick.isNotEmpty) return nick;
    final user = username?.trim();
    if (user != null && user.isNotEmpty) return user;
    return S.current.booksUnnamedMember;
  }

  bool matchesAccount(String? account) {
    final normalized = account?.trim();
    if (normalized == null || normalized.isEmpty) return false;
    return username == normalized || nickname == normalized;
  }

  factory GroupMemberVo.fromJson(Map<String, dynamic> json) {
    return GroupMemberVo(
      relationId: FxApi.asId(
        json['userGroupRelationId'] ??
            json['relationId'] ??
            json['id'] ??
            json['groupUserId'],
      ),
      userId: FxApi.asId(json['userId']),
      username:
          (json['username'] ??
                  json['userName'] ??
                  json['account'] ??
                  json['loginName'])
              ?.toString(),
      nickname: (json['nickname'] ?? json['nickName'] ?? json['name'])
          ?.toString(),
      roleType: FxApi.asId(json['roleType']),
      roleTypeDesc:
          (json['roleTypeDesc'] ?? json['roleName'] ?? json['roleDesc'])
              ?.toString(),
    );
  }
}

class AccountOptionVo {
  const AccountOptionVo({
    this.accountId,
    this.accountName,
    this.currency,
    this.canExpense = true,
    this.canIncome = true,
    this.canTransferOut = true,
    this.canTransferIn = true,
  });

  final int? accountId;
  final String? accountName;
  final String? currency;
  final bool canExpense;
  final bool canIncome;
  final bool canTransferOut;
  final bool canTransferIn;

  String get name => accountName?.trim().isNotEmpty == true
      ? accountName!.trim()
      : S.current.booksUnnamedAccount;

  bool canUseFor(DefaultAccountKind kind) {
    return switch (kind) {
      DefaultAccountKind.expense => canExpense,
      DefaultAccountKind.income => canIncome,
      DefaultAccountKind.transferOut => canTransferOut,
      DefaultAccountKind.transferIn => canTransferIn,
    };
  }

  factory AccountOptionVo.fromJson(Map<String, dynamic> json) {
    return AccountOptionVo(
      accountId: FxApi.asId(json['accountId'] ?? json['id']),
      accountName: (json['accountName'] ?? json['name'])?.toString(),
      currency: (json['currency'] ?? json['defaultCurrency'])?.toString(),
      canExpense: FxApi.asBool(json['canExpense'], orElse: true),
      canIncome: FxApi.asBool(json['canIncome'], orElse: true),
      canTransferOut: FxApi.asBool(json['canTransferOut'], orElse: true),
      canTransferIn: FxApi.asBool(json['canTransferIn'], orElse: true),
    );
  }
}

enum DefaultAccountKind { expense, income, transferOut, transferIn }

extension DefaultAccountKindX on DefaultAccountKind {
  String get label => switch (this) {
    DefaultAccountKind.expense => S.current.booksDefaultExpenseAccount,
    DefaultAccountKind.income => S.current.booksDefaultIncomeAccount,
    DefaultAccountKind.transferOut => S.current.booksDefaultTransferOutAccount,
    DefaultAccountKind.transferIn => S.current.booksDefaultTransferInAccount,
  };

  String get fieldId => switch (this) {
    DefaultAccountKind.expense => 'defaultExpenseAccountId',
    DefaultAccountKind.income => 'defaultIncomeAccountId',
    DefaultAccountKind.transferOut => 'defaultTransferOutAccountId',
    DefaultAccountKind.transferIn => 'defaultTransferInAccountId',
  };
}

class LoginUserInfo {
  const LoginUserInfo({this.username, this.userId});

  final String? username;
  final int? userId;

  factory LoginUserInfo.fromJson(Map<String, dynamic> json) {
    return LoginUserInfo(
      username:
          (json['username'] ??
                  json['userName'] ??
                  json['account'] ??
                  json['loginName'])
              ?.toString(),
      userId: FxApi.asId(json['userId'] ?? json['id']),
    );
  }
}
