part of 'profile_bloc.dart';

/// 个人中心事件。
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// 首次加载：用户资料 + 应用信息。
class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

/// 仅重拉用户资料（编辑资料/头像成功后调用）。
class ProfileUserRefreshed extends ProfileEvent {
  const ProfileUserRefreshed();
}
