part of 'group_users_bloc.dart';

sealed class GroupUsersEvent extends Equatable {
  const GroupUsersEvent();

  @override
  List<Object?> get props => [];
}

/// 加载 / 刷新成员列表。
class GroupUsersLoaded extends GroupUsersEvent {
  const GroupUsersLoaded();
}

class GroupUsersGroupChanged extends GroupUsersEvent {
  final int? groupId;

  const GroupUsersGroupChanged(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// 写操作（邀请/移除）成功后重拉。
class GroupUsersMutated extends GroupUsersEvent {
  const GroupUsersMutated();
}
