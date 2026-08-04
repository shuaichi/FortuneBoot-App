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

/// 写操作（邀请/移除）成功后重拉。
class GroupUsersMutated extends GroupUsersEvent {
  const GroupUsersMutated();
}
