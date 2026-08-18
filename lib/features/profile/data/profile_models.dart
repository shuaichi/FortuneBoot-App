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
  final String? loginIp;
  final String? loginDate;
  final String? remark;

  const UserProfile({
    this.userId,
    this.nickname,
    this.username,
    this.avatar,
    this.sex,
    this.phoneNumber,
    this.email,
    this.roleName,
    this.loginIp,
    this.loginDate,
    this.remark,
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
      loginIp: _firstValue(user['loginIp'], json['loginIp']),
      loginDate: _firstValue(user['loginDate'], json['loginDate']),
      remark: _firstValue(user['remark'], json['remark']),
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
      loginIp: loginIp,
      loginDate: loginDate,
      remark: remark,
    );
  }

  UserProfile withAuditFallback(Map<String, dynamic>? cachedUser) {
    if (cachedUser == null) return this;
    return UserProfile(
      userId: userId,
      nickname: nickname,
      username: username,
      avatar: avatar,
      sex: sex,
      phoneNumber: phoneNumber,
      email: email,
      roleName: roleName,
      loginIp: loginIp ?? _firstValue(cachedUser['loginIp']),
      loginDate: loginDate ?? _firstValue(cachedUser['loginDate']),
      remark: remark ?? _firstValue(cachedUser['remark']),
    );
  }

  static String? _firstValue(Object? first, [Object? second]) {
    final firstValue = first?.toString().trim();
    if (firstValue?.isNotEmpty == true) return firstValue;
    final secondValue = second?.toString().trim();
    return secondValue?.isNotEmpty == true ? secondValue : null;
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
