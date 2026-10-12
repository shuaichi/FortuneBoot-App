import 'package:dio/dio.dart';
import 'package:hjproject/util/dio_client.dart';
import '../model/payee.dart';
import '../view/widgets/enhanced_payee_type_selector.dart';

/// 交易对象数据服务：调用后端分页接口并解析数据
class PayeeService {
  final Dio _dio = DioClient().dio;

  /// 拉取交易对象分页数据
  /// - 必传：bookId（从 BillsRepository 获取）
  /// - 可选：pageNum（当前迭代仅首屏第一页，保留以便后续扩展）
  /// - 可选：pageSize（默认20，后端忽略也不影响）
  /// - 可选：filterType（筛选类型）
  Future<PayeePageData> fetch({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    PayeeFilterType? filterType,
  }) async {
    final queryParameters = <String, dynamic>{
      'bookId': bookId,
      'recycleBin': false,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };

    // 根据筛选类型添加相应的查询参数
    if (filterType != null && filterType != PayeeFilterType.all) {
      switch (filterType) {
        case PayeeFilterType.incomeEnabled:
          queryParameters['canIncome'] = true;
          break;
        case PayeeFilterType.expenseEnabled:
          queryParameters['canExpense'] = true;
          break;
        case PayeeFilterType.enabled:
          queryParameters['enable'] = true;
          break;
        case PayeeFilterType.disabled:
          queryParameters['enable'] = false;
          break;
        case PayeeFilterType.all:
          // 不添加额外筛选参数
          break;
      }
    }

    final response = await _dio.get(
      '/fortune/payee/getPage',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final d = data['data'] as Map<String, dynamic>? ?? {};
        return PayeePageData.fromJson(d);
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
/// 移入回收站
  /// - 路径参数：bookId, payeeId
  /// - 成功返回 code==0；否则抛出后端 msg 异常
  Future<void> moveToRecycleBin({
    required int bookId,
    required int payeeId,
  }) async {
    final response = await _dio.patch(
      '/fortune/payee/$bookId/$payeeId/moveToRecycleBin',
      data: const {},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
/// 修改交易对象
  /// - 接口：PUT /fortune/payee/modify
  /// - 请求体：payeeId, bookId, payeeName, sort, canExpense, canIncome, enable, remark
  /// - 成功：返回 code==0；否则抛出后端 msg
  Future<void> modify({
    required int payeeId,
    required int bookId,
    required String payeeName,
    int? sort,
    required bool canExpense,
    required bool canIncome,
    required bool enable,
    String? remark,
    String? icon,
  }) async {
    final body = <String, dynamic>{
      'payeeId': payeeId,
      'bookId': bookId,
      'payeeName': payeeName,
      if (sort != null) 'sort': sort,
      'canExpense': canExpense,
      'canIncome': canIncome,
      'enable': enable,
      if (remark != null) 'remark': remark,
      if (icon != null) 'icon': icon,
    };

    final response = await _dio.put(
      '/fortune/payee/modify',
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
/// 新增交易对象
  /// - 接口：POST /fortune/payee/add
  /// - 请求体：bookId, payeeName, sort, canExpense, canIncome, enable, remark
  /// - 成功：返回 code==0；否则抛出后端 msg
  Future<void> add({
    required int bookId,
    required String payeeName,
    int? sort,
    required bool canExpense,
    required bool canIncome,
    required bool enable,
    String? remark,
    String? icon,
  }) async {
    final body = <String, dynamic>{
      'bookId': bookId,
      'payeeName': payeeName,
      if (sort != null) 'sort': sort,
      'canExpense': canExpense,
      'canIncome': canIncome,
      'enable': enable,
      if (remark != null) 'remark': remark,
      if (icon != null) 'icon': icon,
    };

    final response = await _dio.post(
      '/fortune/payee/add',
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
}