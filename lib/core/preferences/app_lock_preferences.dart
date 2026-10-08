import 'package:equatable/equatable.dart';

enum AppLockMethod {
  face,
  fingerprint,
  password,
  gesture;

  static AppLockMethod fromStorage(String? raw) {
    return switch (raw) {
      'face' => AppLockMethod.face,
      'fingerprint' => AppLockMethod.fingerprint,
      'gesture' => AppLockMethod.gesture,
      'password' => AppLockMethod.password,
      'device' => AppLockMethod.password,
      _ => AppLockMethod.password,
    };
  }

  String get storageId => name;
}

class AppLockPreferences extends Equatable {
  const AppLockPreferences({
    this.enabled = false,
    this.method = AppLockMethod.password,
  });

  final bool enabled;
  final AppLockMethod method;

  AppLockPreferences copyWith({bool? enabled, AppLockMethod? method}) {
    return AppLockPreferences(
      enabled: enabled ?? this.enabled,
      method: method ?? this.method,
    );
  }

  @override
  List<Object> get props => [enabled, method];
}
