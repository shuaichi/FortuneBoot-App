import 'package:dio/dio.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/request/login_request.dart';

class LoginApiVersionSource implements ApiVersionSource {
  LoginApiVersionSource({LoginService? loginService})
    : _loginService = loginService ?? LoginService();

  final LoginService _loginService;

  @override
  Future<ApiVersionProbe> getApiVersion() async {
    try {
      final response = await _loginService.apiVersion();
      if (response.code != 0) {
        return const ApiVersionResponse(null);
      }
      final data = response.data;
      return ApiVersionResponse(data is String ? data : null);
    } on FormatException {
      return const ApiVersionEndpointUnavailable();
    } on DioException catch (error) {
      if (_isEndpointUnavailable(error)) {
        return const ApiVersionEndpointUnavailable();
      }
      return const ApiVersionConnectionFailed();
    }
  }

  bool _isEndpointUnavailable(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 404 || statusCode == 405) return true;

    final data = error.response?.data;
    if (data is! String) return false;
    final trimmed = data.trim().toLowerCase();
    return trimmed.startsWith('<!doctype') || trimmed.startsWith('<html');
  }
}
