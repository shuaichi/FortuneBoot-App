// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResisterLogin _$ResisterLoginFromJson(Map<String, dynamic> json) =>
    ResisterLogin(
      json['username'] as String,
      json['nickname'] as String,
      json['email'] as String,
      json['phoneNumber'] as String,
      (json['sex'] as num).toInt(),
      json['avatar'] as String,
      json['password'] as String,
      (json['status'] as num).toInt(),
      (json['roleId'] as num).toInt(),
      json['remark'] as String,
      (json['source'] as num).toInt(),
    );

Map<String, dynamic> _$ResisterLoginToJson(ResisterLogin instance) =>
    <String, dynamic>{
      'username': instance.username,
      'nickname': instance.nickname,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'sex': instance.sex,
      'avatar': instance.avatar,
      'password': instance.password,
      'status': instance.status,
      'roleId': instance.roleId,
      'remark': instance.remark,
      'source': instance.source,
    };

Login _$LoginFromJson(Map<String, dynamic> json) => Login(
      json['username'] as String,
      json['password'] as String,
      json['captchaCode'] as String,
      json['captchaCodeKey'] as String,
    );

Map<String, dynamic> _$LoginToJson(Login instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'captchaCode': instance.captchaCode,
      'captchaCodeKey': instance.captchaCodeKey,
    };

HJResponse _$HJResponseFromJson(Map<String, dynamic> json) => HJResponse(
      (json['code'] as num).toInt(),
      json['msg'] as String,
      json['data'],
    );

Map<String, dynamic> _$HJResponseToJson(HJResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
