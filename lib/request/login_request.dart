import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:retrofit/retrofit.dart';
import '../login/model/login_model.dart'; // 导入数据模型

part 'login_request.g.dart'; // 代码生成文件

// 使用下面命令自动生成代码
// flutter pub run build_runner build
@RestApi()
abstract class LoginService {
  factory LoginService({String? baseUrl}) {
    final Dio dio = DioClient().dio;
    return _LoginService(
      dio,
      baseUrl: baseUrl ?? dio.options.baseUrl,
      errorLogger: LoginErrorReport(),
    );
  }

  @POST('/{userName}/checkRepeat')
  Future<HJResponse> checkRepeat(@Path('userName') String userName);

  // RSA key
  @GET('/getRsaPublicKey')
  Future<HJResponse> getRsaPublicKey();

  // 登录
  @POST('/login')
  Future<HJResponse> login(@Body() Login post);

  // 获取验证码
  @GET('/captchaImage')
  Future<HJResponse> captchaImage();

  // 获取允许注册的角色
  @GET('/getAllowRegisterRoles')
  Future<HJResponse> getAllowRegisterRoles();

  // API版本号
  @GET('/getApiVersion')
  Future<HJResponse> apiVersion();

  // 注册
  @POST('/register')
  Future<HJResponse> loginRegister(@Body() ResisterLogin post);
}

class LoginErrorReport extends ParseErrorLogger {
  @override
  void logError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options, {
    Response? response,
  }) {
    debugPrint('LoginErrorReport: $error $stackTrace $options');
  }
}
