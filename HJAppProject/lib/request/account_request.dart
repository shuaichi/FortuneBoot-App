import 'package:dio/dio.dart';
import 'package:hjproject/Home/account_manage/models/fortune_account.dart';
import 'package:hjproject/login/model/login_model.dart';
import 'package:hjproject/request/base_request.dart';
import 'package:hjproject/util/dio_client.dart';
import 'package:retrofit/retrofit.dart';
import 'package:intl/intl.dart';

part 'account_request.g.dart'; // 代码生成文件

// 使用下面命令自动生成代码
// flutter pub run build_runner build

// 账户API
@RestApi()
abstract class AccountService extends BaseService {
  factory AccountService({
    String? baseUrl,
  }) {
    Dio dio = DioClient().dio;
    return _AccountService(dio,
        baseUrl: baseUrl ?? dio.options.baseUrl,
        errorLogger: AccountErrorReport());
  }

  /// 查询启动的账户列表
  @GET('/fortune/account/{groupId}/getEnableList')
  Future<HJResponse> getEnableList(@Path('groupId') int id, {int? type});
}

// 封装账户分页查询（避免依赖 Retrofit 代码生成），与现有 PayeeService 风格一致
// - GET /fortune/account/getPage
// - 固定 recycleBin=false
// - 入参：groupId, accountType（1-4），可选 pageNum/pageSize
class AccountQueryService {
  final Dio _dio = DioClient().dio;

  Future<FortuneAccountPageData> getPage({
    required int groupId,
    required int accountType,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '/fortune/account/getPage',
      queryParameters: {
        'groupId': groupId,
        'recycleBin': false,
        'accountType': accountType,
        'pageNum': pageNum,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final d = data['data'] as Map<String, dynamic>? ?? {};
        return FortuneAccountPageData.fromJson(d);
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  /// 将账户移入回收站
  /// - POST /fortune/account/{groupId}/{accountId}/moveToRecycleBin
  /// - 返回值：{"code":0,"msg":"操作成功","data":null}
  /// - code == 0 视为成功，否则抛出异常（沿用本文件分页查询的错误处理风格）
  Future<bool> moveToRecycleBin({
    required int groupId,
    required int accountId,
  }) async {
    final response = await _dio.patch(
      '/fortune/account/$groupId/$accountId/moveToRecycleBin',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return true;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _buildModifyBody(FortuneAccount a) {
    String? _fmtDate(DateTime? d) =>
        d == null ? null : DateFormat('yyyy-MM-dd').format(d);
    final Map<String, dynamic> body = {
      // 共同参数
      'groupId': a.groupId,
      'accountId': a.accountId,
      'accountName': a.accountName,
      'accountType': a.accountType,
      'currencyCode': a.currencyCode,
      'cardNo': a.cardNo,
      'sort': a.sort,
      'balance': a.balance,
      'initialBalance': a.initialBalance,
      'include': a.include,
      'canExpense': a.canExpense,
      'canIncome': a.canIncome,
      'enable': a.enable,
      'canTransferOut': a.canTransferOut,
      'canTransferIn': a.canTransferIn,
      'remark': a.remark,
      'icon': a.icon,
    };

    // 类型差异字段
    final t = a.accountType ?? 0;
    if (t == 2) {
      // 信用账户：额度/账单日/还款日
      body['creditLimit'] = a.creditLimit;
      body['billDay'] = _fmtDate(a.billDay);
      body['repayDay'] = _fmtDate(a.repayDay);
    } else if (t == 4) {
      // 贷款账户：额度/利率/还款日
      body['creditLimit'] = a.creditLimit;
      body['apr'] = a.apr;
      body['repayDay'] = _fmtDate(a.repayDay);
    }
    // 去除 null 值，避免后端覆盖为 null
    body.removeWhere((k, v) => v == null);
    return body;
  }

  /// 修改账户
  /// - PUT /fortune/account/modify
  /// - 请求体：共同参数 + 类型特有参数（见 _buildModifyBody）
  /// - 成功：HTTP 200 且返回体 code==0
  Future<bool> modifyAccount(FortuneAccount a) async {
    final response = await _dio.put(
      '/fortune/account/modify',
      data: _buildModifyBody(a),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return true;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  /// 余额调整
  /// - PATCH /fortune/account/balanceAdjust
  /// - 请求体：accountId, balance, tradeTime(yyyy-MM-dd HH:mm:ss), bookId, [title], [remark]
  /// - 成功：HTTP 200 且返回体 code==0
  Future<bool> balanceAdjust({
    required int accountId,
    required double balance,
    required DateTime tradeTime,
    required int bookId,
    String? title,
    String? remark,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    final Map<String, dynamic> body = {
      'accountId': accountId,
      'balance': balance,
      'tradeTime': fmt.format(tradeTime),
      'bookId': bookId,
    };

    // 剔除空值字段，避免后端误覆盖
    if (title != null && title.trim().isNotEmpty) {
      body['title'] = title.trim();
    }
    if (remark != null && remark.trim().isNotEmpty) {
      body['remark'] = remark.trim();
    }

    final response = await _dio.patch(
      '/fortune/account/balanceAdjust',
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return true;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
}

/// Currency template option model for selection
class CurrencyOption {
  final int? value;
  final String label;

  CurrencyOption({this.value, required this.label});

  factory CurrencyOption.fromJson(Map<String, dynamic> json) {
    return CurrencyOption(
      value: (json['value'] as num?)?.toInt(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

extension AccountQueryServiceExtensions on AccountQueryService {
  /// 获取币种模板
  /// - GET /fortune/group/getCurrencyTemplate
  /// - 成功返回 List<CurrencyOption>
  Future<List<CurrencyOption>> getCurrencyTemplate() async {
    final response = await _dio.get('/fortune/group/getCurrencyTemplate');

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final list = (data['data'] as List? ?? [])
            .map((e) => CurrencyOption.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
        return list;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  /// 新增账户
  /// - POST /fortune/account/add
  /// - 必填：groupId、accountName、accountType、currencyCode、canExpense、canIncome、canTransferOut、canTransferIn、include、enable
  /// - 可选：cardNo、sort、balance、remark
  /// - 成功：HTTP 200 且返回体 code==0
  Future<bool> addAccount({
    required int groupId,
    required String accountName,
    required int accountType,
    required String currencyCode,
    String? cardNo,
    int? sort,
    double? balance,
    String? remark,
    required bool canExpense,
    required bool canIncome,
    required bool canTransferOut,
    required bool canTransferIn,
    required bool include,
    required bool enable,
    DateTime? repayDay,
    DateTime? billDay,
    double? creditLimit,
    double? apr,
    String? icon,
  }) async {
    final Map<String, dynamic> body = {
      'groupId': groupId,
      'accountName': accountName.trim(),
      'accountType': accountType,
      'currencyCode': currencyCode.trim(),
      'canExpense': canExpense,
      'canIncome': canIncome,
      'canTransferOut': canTransferOut,
      'canTransferIn': canTransferIn,
      'include': include,
      'enable': enable,
    };

    // 剔除空值字段，避免后端误覆盖
    if (cardNo != null && cardNo.trim().isNotEmpty) {
      body['cardNo'] = cardNo.trim();
    }
    if (sort != null) {
      body['sort'] = sort;
    }
    if (balance != null) {
      body['balance'] = balance;
    }
    if (remark != null && remark.trim().isNotEmpty) {
      body['remark'] = remark.trim();
    }
    if (icon != null && icon.trim().isNotEmpty) {
      body['icon'] = icon.trim();
    }

    final response = await _dio.post(
      '/fortune/account/add',
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return true;
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
}
