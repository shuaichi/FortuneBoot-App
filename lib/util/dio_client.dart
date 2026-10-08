import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/widgets.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:logger/logger.dart';

class DioClient {
  // 私有静态实例
  static final DioClient _instance = DioClient._internal();

  // Dio实例
  late final Dio dio;

  // 日志记录器
  final Logger _logger = Logger();

  Map<String, dynamic> _authHeaders = {};
  bool _isHandlingAuthExpired = false;

  VoidCallback? onAuthExpired;

  // 全局访问点
  factory DioClient() => _instance;

  // 私有构造函数
  DioClient._internal() {
    // 初始化Dio基础配置
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    );

    // demo 等自建站证书过期时仍允许连接（仅放宽 TLS 校验，不改变业务逻辑）。
    // 正式环境请续签证书后移除此回调。
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    // 添加拦截器
    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authHeaders.isNotEmpty && _shouldAttachAuth(options)) {
            options.headers.addAll(_authHeaders);
          }
          if (options.contentType == null) {
            options.contentType = Headers.jsonContentType;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // 检查响应是否为 HTML（服务端错误页面或重定向）
          final data = response.data;
          if (_isHtmlResponse(data)) {
            _logger.e('服务端返回了 HTML 而非 JSON，可能是 baseUrl 未配置或请求地址错误');
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: '服务端返回了 HTML 而非 JSON 数据，请检查 baseUrl 是否正确配置',
              ),
            );
          }
          if (data is Map &&
              _isAuthExpiredCode(data['code']) &&
              !_isApiVersionRequest(response.requestOptions)) {
            await _handleAuthExpired();
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: data['msg']?.toString() ?? '登录状态已过期，请重新登录',
              ),
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (_isAuthExpiredStatus(error.response?.statusCode) &&
              !_isApiVersionRequest(error.requestOptions)) {
            await _handleAuthExpired();
          }
          return handler.next(error);
        },
      ),
      // 日志拦截器
      LogInterceptor(
        request: true,
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        error: false,
        logPrint: (object) => debugPrint('$object'),
      ),
    ]);
  }

  // 动态更新配置
  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }

  void setAuthHeader(Map<String, dynamic> header) {
    _authHeaders = Map<String, dynamic>.from(header);
    if (_authHeaders.isNotEmpty) {
      _isHandlingAuthExpired = false;
    }
  }

  /// 当前鉴权请求头（只读副本），供头像等非 Dio 请求复用。
  Map<String, dynamic> get authHeaders => Map<String, dynamic>.from(_authHeaders);

  void clearAuthHeader() {
    _authHeaders = {};
  }

  // 保留历史命名，实际语义是更新当前认证请求头。
  void refreshToken(Map<String, dynamic> header) {
    if (header.isEmpty) {
      clearAuthHeader();
    } else {
      setAuthHeader(header);
    }
  }

  bool _isApiVersionRequest(RequestOptions options) =>
      options.path.endsWith('/getApiVersion');

  bool _shouldAttachAuth(RequestOptions options) {
    final path = options.path;
    return !_isApiVersionRequest(options) &&
        !path.endsWith('/getIcp') &&
        !path.endsWith('/refreshToken') &&
        !path.endsWith('/login') &&
        !path.endsWith('/captchaImage') &&
        !path.endsWith('/getConfig') &&
        !path.endsWith('/getAllowRegisterRoles') &&
        !path.endsWith('/register') &&
        !path.endsWith('/getRsaPublicKey') &&
        !RegExp(r'^/[^/]+/checkRepeat$').hasMatch(path);
  }

  bool _isHtmlResponse(dynamic data) {
    if (data is! String) return false;
    final trimmed = data.trim();
    return trimmed.startsWith('<!DOCTYPE') || trimmed.startsWith('<html');
  }

  bool _isAuthExpiredCode(dynamic code) {
    final normalizedCode = int.tryParse(code?.toString() ?? '');
    return normalizedCode == 106 ||
        normalizedCode == 107 ||
        normalizedCode == 108;
  }

  bool _isAuthExpiredStatus(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  Future<void> _handleAuthExpired() async {
    if (_isHandlingAuthExpired) return;
    _isHandlingAuthExpired = true;
    clearAuthHeader();
    await UserDataSingleton().clearAuth();
    onAuthExpired?.call();
  }
}
