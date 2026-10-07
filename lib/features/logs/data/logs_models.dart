import 'package:intl/intl.dart';

/// 操作日志一行。字段对应后端 OperationLogDTO。
class OperationLog {
  const OperationLog({
    this.operationId,
    this.requestModule,
    this.businessTypeStr,
    this.requestMethod,
    this.requestUrl,
    this.username,
    this.operatorIp,
    this.operatorLocation,
    this.operationParam,
    this.operationResult,
    this.status,
    this.statusStr,
    this.errorStack,
    this.timeLabel,
  });

  final int? operationId;
  final String? requestModule;
  final String? businessTypeStr;
  final String? requestMethod;
  final String? requestUrl;
  final String? username;
  final String? operatorIp;
  final String? operatorLocation;
  final String? operationParam;
  final String? operationResult;
  final int? status;
  final String? statusStr;
  final String? errorStack;
  final String? timeLabel;

  factory OperationLog.fromJson(Map<String, dynamic> json) {
    return OperationLog(
      operationId: _asInt(json['operationId']),
      requestModule: _str(json['requestModule']),
      businessTypeStr: _str(json['businessTypeStr']),
      requestMethod: _str(json['requestMethod']),
      requestUrl: _str(json['requestUrl']),
      username: _str(json['username']),
      operatorIp: _str(json['operatorIp']),
      operatorLocation: _str(json['operatorLocation']),
      operationParam: _str(json['operationParam']),
      operationResult: _str(json['operationResult']),
      status: _asInt(json['status']),
      statusStr: _str(json['statusStr']),
      errorStack: _str(json['errorStack']),
      timeLabel: formatLogTime(json['operationTime']),
    );
  }

  String get title {
    final module = requestModule?.trim();
    final type = businessTypeStr?.trim();
    if (module != null &&
        module.isNotEmpty &&
        type != null &&
        type.isNotEmpty) {
      return '$module · $type';
    }
    if (module != null && module.isNotEmpty) return module;
    if (type != null && type.isNotEmpty) return type;
    return username?.trim().isNotEmpty == true ? username!.trim() : '—';
  }
}

/// 登录日志一行。字段对应后端 LoginLogDTO。
class LoginLog {
  const LoginLog({
    this.logId,
    this.username,
    this.ipAddress,
    this.loginLocation,
    this.operationSystem,
    this.browser,
    this.status,
    this.statusStr,
    this.msg,
    this.timeLabel,
  });

  final String? logId;
  final String? username;
  final String? ipAddress;
  final String? loginLocation;
  final String? operationSystem;
  final String? browser;
  final int? status;
  final String? statusStr;
  final String? msg;
  final String? timeLabel;

  factory LoginLog.fromJson(Map<String, dynamic> json) {
    return LoginLog(
      logId: _str(json['logId']),
      username: _str(json['username']),
      ipAddress: _str(json['ipAddress']),
      loginLocation: _str(json['loginLocation']),
      operationSystem: _str(json['operationSystem']),
      browser: _str(json['browser']),
      status: _asInt(json['status']),
      statusStr: _str(json['statusStr']),
      msg: _str(json['msg']),
      timeLabel: formatLogTime(json['loginTime']),
    );
  }

  String get title {
    final name = username?.trim();
    if (name != null && name.isNotEmpty) return name;
    return logId?.trim().isNotEmpty == true ? logId!.trim() : '—';
  }
}

class LogPage<T> {
  const LogPage({this.rows = const [], this.total = 0});

  final List<T> rows;
  final int total;
}

/// 后端日期可能是 `yyyy-MM-dd HH:mm:ss`，也可能是时间戳。
String? formatLogTime(dynamic value) {
  if (value == null) return null;
  DateTime? parsed;
  if (value is num) {
    final raw = value.toInt();
    parsed = DateTime.fromMillisecondsSinceEpoch(
      raw > 1000000000000 ? raw : raw * 1000,
    );
  } else {
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    parsed = DateTime.tryParse(text.replaceFirst(' ', 'T'));
    if (parsed == null) return text;
  }
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed.toLocal());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _str(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}
