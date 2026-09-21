import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 主题偏好：跟随系统 / 亮色 / 暗色。
class ThemePreferences extends Equatable {
  final ThemeMode mode;

  const ThemePreferences({this.mode = ThemeMode.system});

  factory ThemePreferences.defaults() => const ThemePreferences();

  ThemePreferences copyWith({ThemeMode? mode}) {
    return ThemePreferences(mode: mode ?? this.mode);
  }

  static ThemeMode modeFromStorage(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String modeToStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  @override
  List<Object?> get props => [mode];
}
