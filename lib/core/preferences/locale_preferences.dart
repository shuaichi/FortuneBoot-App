import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// 语言偏好：system 跟随系统，其余为具体语言码。
class LocalePreferences extends Equatable {
  /// `system` / `zh` / `en`
  final String code;

  const LocalePreferences({this.code = systemCode});

  static const String systemCode = 'system';

  factory LocalePreferences.defaults() => const LocalePreferences();

  bool get followsSystem => code == systemCode;

  /// 解析为 MaterialApp locale；system 返回 null。
  Locale? get locale {
    switch (code) {
      case 'zh':
        return const Locale('zh', 'CN');
      case 'en':
        return const Locale('en');
      default:
        return null;
    }
  }

  LocalePreferences copyWith({String? code}) {
    return LocalePreferences(code: normalize(code ?? this.code));
  }

  static String normalize(String value) {
    switch (value) {
      case 'zh':
      case 'en':
      case systemCode:
        return value;
      default:
        return systemCode;
    }
  }

  @override
  List<Object?> get props => [code];
}
