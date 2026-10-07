import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/base_request.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:retrofit/retrofit.dart';

part 'group_request.g.dart'; // 代码生成文件

// 使用下面命令自动生成代码
// flutter pub run build_runner build

// 分组API 分组相关的增删查改
@RestApi()
abstract class GroupService {
  factory GroupService({String? baseUrl}) {
    Dio dio = DioClient().dio;
    // 勿写入绝对 baseUrl：否则会在构造时冻住地址，换服务器后仍打旧主机。
    return _GroupService(
      dio,
      baseUrl: baseUrl,
      errorLogger: AccountErrorReport(),
    );
  }

  @GET('/fortune/group/getDefaultGroupId')
  Future<HJResponse> getDefaultGroupId();

  /// 获取分组详情
  /// {"code":0,"msg":"操作成功","data":{"groupId":1,"groupName":"演示分组","defaultCurrency":"CNY","roleTypeDesc":null,"enable":true,"defaultBookId":1,"defaultBookName":null,"remark":null}}
  @GET('/fortune/group/{groupId}/getByGroupId')
  Future<HJResponse> getByGroupId(@Path('groupId') int groupId);

  // /fortune/group/getEnableList
  @GET('/fortune/group/getEnableList')
  Future<HJResponse> getEnableList();
}
