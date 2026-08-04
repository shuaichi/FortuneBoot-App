import 'package:dio/dio.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/util/dio_client.dart';

/// 业务异常：HJResponse.code != 0 或网络失败时抛出，由 FxStateView 兜底展示。
class FxApiException implements Exception {
  final int code;
  final String message;

  FxApiException(this.code, this.message);

  @override
  String toString() => 'FxApiException($code): $message';
}

/// 对 DioClient 的薄封装：统一解包 HJResponse、抛 FxApiException、id 兼容解析。
///
/// 各 feature 的 service 通过 [FxApi.instance] 调用 Dio，或直接用 Retrofit Service
/// 拿到 HJResponse 后交给 [unwrap] 解包。
class FxApi {
  FxApi._();
  static final FxApi instance = FxApi._();

  Dio get dio => DioClient().dio;

  /// 解包 Retrofit 返回的 HJResponse。code==0 返回 data，否则抛 FxApiException。
  static dynamic unwrap(HJResponse res) {
    if (res.code == 0) return res.data;
    throw FxApiException(res.code, res.msg.isEmpty ? '操作失败' : res.msg);
  }

  /// 解包裸 dio Response（data 为 {code,msg,data} Map）。
  static dynamic unwrapRaw(Response<dynamic> res) {
    final data = res.data;
    if (data is Map) {
      final code = _asInt(data['code']) ?? -1;
      if (code == 0) return data['data'];
      final msg = data['msg']?.toString() ?? '操作失败';
      throw FxApiException(code, msg);
    }
    throw FxApiException(-1, '响应格式异常');
  }

  // ---- 便捷请求方法（解包后直接返回 data）----

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await dio.get<dynamic>(path, queryParameters: query);
    return unwrapRaw(res);
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    final res = await dio.post<dynamic>(
      path,
      data: data,
      queryParameters: query,
    );
    return unwrapRaw(res);
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    final res = await dio.put<dynamic>(path, data: data);
    return unwrapRaw(res);
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    final res = await dio.patch<dynamic>(path, data: data);
    return unwrapRaw(res);
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    final res = await dio.delete<dynamic>(path, data: data);
    return unwrapRaw(res);
  }

  // ---- 解析工具（雪花 id / 金额 / 布尔 的宽松解析）----

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// 大整数 id：JSON 里可能是 num 或 String，统一兼容为 int。
  static int? asId(dynamic v) => _asInt(v);

  /// 金额：BigDecimal 在 JSON 里可能是 num 或 String。
  static double? asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static bool asBool(dynamic v, {bool orElse = false}) {
    if (v == null) return orElse;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return orElse;
  }
}
