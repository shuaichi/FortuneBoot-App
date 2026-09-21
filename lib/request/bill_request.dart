import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/base_request.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bill_request.g.dart'; // 代码生成文件

// 使用下面命令自动生成代码
// flutter pub run build_runner build

// 账单API账单相关的增删查改
@RestApi()
abstract class BillService {
  factory BillService({String? baseUrl}) {
    Dio dio = DioClient().dio;
    return _BillService(
      dio,
      // 勿写入绝对 baseUrl：否则会在构造时冻住地址，换服务器后仍打旧主机。
      baseUrl: baseUrl,
      errorLogger: AccountErrorReport(),
    );
  }

  /// /fortune/bill/getPage
  /// 账单分页查询接口
  @GET('/fortune/bill/getPage')
  Future<HJResponse> getPage({
    // 基础分页参数
    @Query('pageNum') int pageNum = 1,
    @Query('pageSize') int pageSize = 20,

    // 时间范围参数（ISO 8601格式）
    @Query('beginTime') String? beginTime,
    @Query('endTime') String? endTime,

    // 金额范围过滤
    @Query('amountMin') int? amountMin,
    @Query('amountMax') int? amountMax,

    // 业务ID参数（大整数用String处理）
    @Query('bookId') String? bookId,
    @Query('accountId') String? accountId,
    @Query('payeeId') String? payeeId,

    // 分类/标签过滤（数组参数特殊处理） Uri.encodeComponent(jsonEncode(categoryIds))
    @Query('categoryIds') List<int>? categoryIds,
    @Query('tagIds') List<int>? tagIds,

    // 布尔型参数
    @Query('confirm') bool? confirm,
    @Query('include') bool? include,
    @Query('fileInclude') bool? fileInclude,

    // 字符串类型参数
    @Query('orderDirection') String? orderDirection,
    @Query('title') String? title,
    @Query('remark') String? remark,

    // 交易时间范围（自定义格式）
    @Query('tradeTimeStartTime') String? tradeTimeStartTime,
    @Query('tradeTimeEndTime') String? tradeTimeEndTime,

    // 账单类型过滤
    @Query('billType') String? billType,
  });

  // /fortune/bill/add
  @POST('/fortune/bill/add')
  @MultiPart()
  Future<HJResponse> addBill(
    @Part(name: 'data') String jsonData, // JSON 数据字段
    // @Part(name: 'data') MultipartFile? jsonData, // 文件字段
  );

  @DELETE('/fortune/bill/{bookId}/{billId}/remove')
  Future<HJResponse> removeBill(
    @Path('bookId') int bookId,
    @Path('billId') int billId,
  );

  @GET('/fortune/bill/file/{billId}/getByBillId')
  Future<HJResponse> getByBillFileId(@Path('billId') int billId);
}

class FromBillAddRequest {
  Future<Response?>? submitBill(
    Map<String, dynamic> data, {
    bool modify = false,
    List<dynamic>? attachmentFiles,
  }) async {
    try {
      // 2. 构建 FormData
      final formData = FormData();

      // 添加 JSON 数据 (模拟 Blob)
      formData.files.add(
        MapEntry(
          'data',
          MultipartFile.fromString(
            jsonEncode(data), // 使用清理后的 JSON
            contentType: DioMediaType('application', 'json'),
          ),
        ),
      );

      // 3. 处理文件列表
      if (attachmentFiles != null && attachmentFiles.isNotEmpty) {
        for (final file in attachmentFiles) {
          if (file is File) {
            // 移动端文件处理
            formData.files.add(
              MapEntry(
                'files', // 字段名需与后端一致
                await MultipartFile.fromFile(
                  file.path,
                  filename:
                      'upload_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}',
                ),
              ),
            );
          } else if (file is Map &&
              file.containsKey('bytes') &&
              file.containsKey('name')) {
            // Web端文件处理
            formData.files.add(
              MapEntry(
                'files',
                MultipartFile.fromBytes(
                  file['bytes'] as List<int>,
                  filename: file['name'] as String,
                ),
              ),
            );
          }
        }
      }
      // https://fortuneboot.com/prod-api/fortune/bill/add
      // 4. 发送请求
      if (!modify) {
        final response = await DioClient().dio.post(
          '/fortune/bill/add',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(seconds: 15),
          ),
          onSendProgress: (sent, total) {
            // 进度更新 (可选)
            // _updateProgress(sent / total);
          },
        );
        return response;
      } else {
        final response = await DioClient().dio.put(
          '/fortune/bill/modify',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(seconds: 15),
          ),
          onSendProgress: (sent, total) {
            // 进度更新 (可选)
            // _updateProgress(sent / total);
          },
        );
        return response;
      }
    } on DioException catch (e) {
      // 错误处理
      print('Error: ${e.message}');
      return null;
    } finally {}
  }
}
