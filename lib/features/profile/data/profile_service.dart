import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/login/model/users.dart';

/// 个人中心数据服务：用户资料 / 改密码 / 头像上传 / 汇率刷新 / 应用信息。
/// 全部走 [FxApi.instance]。
class ProfileService {
  final FxApi _api = FxApi.instance;

  /// 拉取当前用户资料：GET /system/user/profile。
  Future<UserProfile> getProfile() async {
    final data = await _api.get('/system/user/profile');
    if (data is! Map) return const UserProfile();

    final profile = UserProfile.fromJson(Map<String, dynamic>.from(data));
    try {
      final cachedUser = await UserDataSingleton().getMap(
        UserDataSingleton.userInfo,
      );
      return profile.withAuditFallback(cachedUser);
    } on Object {
      return profile;
    }
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

  /// 注销账号：DELETE /system/user/profile。
  ///
  /// App Store 要求支持账号自助注销。[password] 必须是已 RSA 加密的密文。
  Future<void> deleteAccount({required String password}) async {
    await _api.delete(
      '/system/user/profile',
      data: {'password': password},
    );
  }

  /// 上传头像：POST /system/user/profile/avatar（multipart `avatarfile`）。
  /// 兼容 `data.imgUrl` / 根级 `imgUrl` / `data` 为字符串等多种返回形态。
  Future<String> uploadAvatar(File file) async {
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
    final body = res.data;
    if (body is! Map) {
      throw FxApiException(-1, '头像上传响应异常');
    }
    final code = FxApi.asId(body['code']) ?? -1;
    // 业务码 0（本项目）与 200（若依风格）都视为成功。
    if (code != 0 && code != 200) {
      final msg = body['msg']?.toString() ?? '头像上传失败';
      throw FxApiException(code, msg);
    }

    final rawUrl = _extractAvatarUrl(body);
    if (rawUrl == null || rawUrl.isEmpty) {
      throw FxApiException(-1, '未返回头像地址');
    }
    return rawUrl;
  }

  static String? _extractAvatarUrl(Map<dynamic, dynamic> body) {
    final data = body['data'];
    if (data is Map) {
      final nested =
          data['imgUrl'] ?? data['url'] ?? data['avatar'] ?? data['imageUrl'];
      final text = nested?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    } else if (data is String) {
      final text = data.trim();
      if (text.isNotEmpty) return text;
    }

    for (final key in ['imgUrl', 'url', 'avatar', 'imageUrl']) {
      final text = body[key]?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
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
