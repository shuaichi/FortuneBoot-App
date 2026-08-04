import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

// 使用下面命令自动生成代码
// flutter pub run build_runner build
@JsonSerializable()
class ResisterLogin {
  final String username;
  final String nickname;
  final String email;
  final String phoneNumber;
  final int sex;
  final String avatar;
  final String password;
  final int status;
  final int roleId;
  final String remark;
  final int source;

  ResisterLogin(
      this.username,
      this.nickname,
      this.email,
      this.phoneNumber,
      this.sex,
      this.avatar,
      this.password,
      this.status,
      this.roleId,
      this.remark,
      this.source);

  factory ResisterLogin.fromJson(Map<String, dynamic> json) =>
      _$ResisterLoginFromJson(json);
  Map<String, dynamic> toJson() => _$ResisterLoginToJson(this);
  @override
  String toString() {
    return 'ResisterLogin{userName: $username, nickName: $nickname, email: $email, phoneNumber: $phoneNumber, sex: $sex, avatar: $avatar, password: $password, status: $status, roleId: $roleId, remark: $remark, source: $source}';
  }
}

/**
 * {
  "username": "string",
  "password": "string",
  "captchaCode": "string",
  "captchaCodeKey": "string"
}
 */
@JsonSerializable()
class Login {
  final String username;
  final String password;
  final String captchaCode;
  final String captchaCodeKey;

  Login(this.username, this.password, this.captchaCode, this.captchaCodeKey);

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
  Map<String, dynamic> toJson() => _$LoginToJson(this);
  @override
  String toString() {
    return 'login{username: $username, password: $password, captchaCode: $captchaCode, captchaCodeKey: $captchaCodeKey}';
  }
}

@JsonSerializable()
class HJResponse {
  final int code;
  final String msg;
  final dynamic data;
  HJResponse(this.code, this.msg, this.data);
  factory HJResponse.fromJson(Map<String, dynamic> json) =>
      _$HJResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HJResponseToJson(this);
  @override
  String toString() {
    return 'LoginResponse{code: $code, msg: $msg, data: $data}';
  }
}

