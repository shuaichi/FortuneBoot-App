import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/base_request.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:retrofit/retrofit.dart';

part 'category_request.g.dart'; // 代码生成文件

// 使用下面命令自动生成代码
// flutter pub run build_runner build

// 账户API
@RestApi()
abstract class CategoryService extends BaseService {
  factory CategoryService({String? baseUrl}) {
    Dio dio = DioClient().dio;
    return _CategoryService(
      dio,
      // 勿写入绝对 baseUrl：否则会在构造时冻住地址，换服务器后仍打旧主机。
      baseUrl: baseUrl,
      errorLogger: AccountErrorReport(),
    );
  }

  @GET('/fortune/category/{bookId}/getEnableList')
  Future<HJResponse> getEnableList(
    @Path('bookId') int bookId, {
    @Query('billType') int? type,
  });
}
