import 'dart:developer' as developer;

/// 平台诊断日志工具
/// 用于在鸿蒙平台上记录关键的初始化和导航日志
class PlatformLogger {
  static const String _tag = 'PlatformLogger';

  /// 记录信息日志
  static void info(String message) {
    developer.log(
      message,
      name: _tag,
      level: 800, // INFO level
    );
    print('[$_tag] INFO: $message');
  }

  /// 记录警告日志
  static void warning(String message) {
    developer.log(
      message,
      name: _tag,
      level: 900, // WARNING level
    );
    print('[$_tag] WARNING: $message');
  }

  /// 记录错误日志
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1000, // SEVERE level
      error: error,
      stackTrace: stackTrace,
    );
    print('[$_tag] ERROR: $message');
    if (error != null) {
      print('[$_tag] ERROR Detail: $error');
    }
    if (stackTrace != null) {
      print('[$_tag] StackTrace: $stackTrace');
    }
  }

  /// 记录调试日志
  static void debug(String message) {
    developer.log(
      message,
      name: _tag,
      level: 500, // FINE level
    );
    print('[$_tag] DEBUG: $message');
  }
}