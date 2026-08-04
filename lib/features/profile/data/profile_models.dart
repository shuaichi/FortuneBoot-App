import 'package:fortuneboot/core/network/fx_api.dart';

/// 当前登录用户资料。
///
/// 对应 `GET /system/user/profile` → `UserProfileDTO{user:{...}, roleName}`。
/// 注意：用户字段嵌套在 `user` 对象内，`roleName` 与 `user` 平级。
class UserProfile {
  final int? userId;
  final String? nickname;
  final String? username;
  final String? avatar;
  final int? sex; // 0 女 / 1 男（沿用注册约定）
  final String? phoneNumber;
  final String? email;
  final String? roleName;

  const UserProfile({
    this.userId,
    this.nickname,
    this.username,
    this.avatar,
    this.sex,
    this.phoneNumber,
    this.email,
    this.roleName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // 兼容两种形态：{user:{...}, roleName} 或直接平铺。
    final rawUser = json['user'];
    final user = rawUser is Map ? Map<String, dynamic>.from(rawUser) : json;
    final sexValue = user['sex'];
    return UserProfile(
      userId: FxApi.asId(user['userId']),
      nickname: user['nickname']?.toString(),
      username: user['username']?.toString(),
      avatar: (user['avatar']?.toString().isEmpty ?? true)
          ? null
          : user['avatar']?.toString(),
      sex: sexValue == null ? null : FxApi.asId(sexValue),
      phoneNumber: user['phoneNumber']?.toString(),
      email: user['email']?.toString(),
      roleName: json['roleName']?.toString() ?? user['roleName']?.toString(),
    );
  }

  UserProfile copyWith({
    String? nickname,
    String? avatar,
    int? sex,
    String? phoneNumber,
    String? email,
  }) {
    return UserProfile(
      userId: userId,
      nickname: nickname ?? this.nickname,
      username: username,
      avatar: avatar ?? this.avatar,
      sex: sex ?? this.sex,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      roleName: roleName,
    );
  }

  /// 性别展示文案。
  String get sexLabel => switch (sex) {
    1 => '男',
    0 => '女',
    _ => '未设置',
  };
}

/// 应用信息聚合（关于页）。
class AppAbout {
  final String appVersion; // package_info_plus
  final String? apiVersion; // GET /getApiVersion
  final String? icp; // GET /getIcp

  const AppAbout({this.appVersion = '', this.apiVersion, this.icp});
}
