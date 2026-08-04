part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, ready, error }

/// 个人中心状态：用户资料（含加载态）+ 应用信息。
class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final AppAbout about;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.about = const AppAbout(),
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    AppAbout? about,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      about: about ?? this.about,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile?.userId,
        profile?.nickname,
        profile?.avatar,
        profile?.sex,
        profile?.phoneNumber,
        profile?.email,
        profile?.roleName,
        about.appVersion,
        about.apiVersion,
        about.icp,
        errorMessage,
      ];
}
