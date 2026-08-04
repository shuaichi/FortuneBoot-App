part of 'group_users_bloc.dart';

enum GroupUsersStatus { initial, loading, loaded, error, empty }

class GroupUsersState extends Equatable {
  final GroupUsersStatus status;
  final List<GroupUserVo> users;
  final List<RoleTypeOption> roleTypes;
  final String? errorMessage;

  const GroupUsersState({
    this.status = GroupUsersStatus.initial,
    this.users = const [],
    this.roleTypes = const [],
    this.errorMessage,
  });

  /// owner 角色：约定 RoleTypeEnum 中 value 最小者为所有者（后端枚举 owner 排首位）。
  /// 无枚举数据时返回 null，调用方据此回退到不显示 owner 专属操作。
  int? get ownerRoleType => roleTypes.isEmpty ? null : roleTypes.first.value;

  /// owner 角色的描述文案（用于与 FortuneGroupVo.roleTypeDesc 精确比较）。
  String? get ownerRoleDesc => roleTypes.isEmpty ? null : roleTypes.first.label;

  GroupUsersState copyWith({
    GroupUsersStatus? status,
    List<GroupUserVo>? users,
    List<RoleTypeOption>? roleTypes,
    String? errorMessage,
  }) {
    return GroupUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      roleTypes: roleTypes ?? this.roleTypes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, roleTypes, errorMessage];
}
