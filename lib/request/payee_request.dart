import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/base_request.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:retrofit/retrofit.dart';

part 'payee_request.g.dart'; // 代码生成文件

// 使用下面命令自动生成代码
// flutter pub run build_runner build

// 账单API账单相关的增删查改
@RestApi()
abstract class PayeeService extends BaseService {
  factory PayeeService({String? baseUrl}) {
    Dio dio = DioClient().dio;
    return _PayeeService(
      dio,
      // 勿写入绝对 baseUrl：否则会在构造时冻住地址，换服务器后仍打旧主机。
      baseUrl: baseUrl,
      errorLogger: AccountErrorReport(),
    );
  }

  /// fortune/payee/{bookId}/getEnableList
  /// 账单分页查询接口
  @GET('/fortune/payee/{bookId}/getEnableList')
  Future<HJResponse> getEnableList(
    @Path('bookId') int id, {
    @Query('billType') int? type,
  });
}
