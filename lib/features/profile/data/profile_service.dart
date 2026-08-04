import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';

/// 个人中心数据服务：用户资料 / 改密码 / 头像上传 / 汇率刷新 / 应用信息。
/// 全部走 [FxApi.instance]。
class ProfileService {
  final FxApi _api = FxApi.instance;

  /// 拉取当前用户资料：GET /system/user/profile。
  Future<UserProfile> getProfile() async {
    final data = await _api.get('/system/user/profile');
    if (data is Map) {
      return UserProfile.fromJson(Map<String, dynamic>.from(data));
    }
    return const UserProfile();
  }

  /// 更新资料：PUT /system/user/profile（UpdateProfileCommand）。
  Future<void> updateProfile({
    required int userId,
    int? sex,
    String? nickname,
    String? phoneNumber,
    String? email,
  }) async {
    await _api.put(
      '/system/user/profile',
      data: {
        'userId': userId,
        if (sex != null) 'sex': sex,
        if (nickname != null) 'nickname': nickname,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
      },
    );
  }

  /// 修改密码：PUT /system/user/profile/password。
  /// [oldPassword]/[newPassword] 必须是已 RSA 加密的密文。
  Future<void> updatePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.put(
      '/system/user/profile/password',
      data: {
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// 上传头像：POST /system/user/profile/avatar（multipart `avatarfile`）→ {imgUrl}。
  /// 返回新头像 URL。
  Future<String?> uploadAvatar(File file) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'avatarfile',
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    final res = await _api.dio.post<dynamic>(
      '/system/user/profile/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = FxApi.unwrapRaw(res);
    if (data is Map) {
      return data['imgUrl']?.toString();
    }
    return null;
  }

  /// 刷新汇率：POST /fortune/currency/refresh。
  Future<void> refreshCurrency() async {
    await _api.post('/fortune/currency/refresh');
  }

  /// 首页金额显示配置：GET /fortune/include/getDisplayConfig → String。
  Future<String?> getDisplayConfig() async {
    final data = await _api.get('/fortune/include/getDisplayConfig');
    return data?.toString();
  }

  /// API 版本：GET /getApiVersion → String。
  Future<String?> getApiVersion() async {
    final data = await _api.get('/getApiVersion');
    return data?.toString();
  }

  /// ICP 备案信息：GET /getIcp → String。
  Future<String?> getIcp() async {
    final data = await _api.get('/getIcp');
    return data?.toString();
  }
}
