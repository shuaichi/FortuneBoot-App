import 'package:equatable/equatable.dart';

/// 回退凭证：密码或手势（始终需要设置其一）。
enum AppLockMethod { pin, pattern }

/// 默认解锁方式；面容/指纹不可用时回退到 [AppLockMethod]。
enum AppLockPreferredUnlock { face, fingerprint, pin, pattern }

enum AppLockStatus { loading, disabled, locked, unlocked, setupRequired }

enum BiometricResult { authenticated, cancelled, unavailable, failed }

enum AppLockFailure {
  invalidCredential,
  biometricFailed,
  biometricUnavailable,
  configurationSaveFailed,
  disableFailed,
}

class AppLockSettings extends Equatable {
  const AppLockSettings({
    required this.method,
    this.preferredUnlock = AppLockPreferredUnlock.pin,
  });

  /// 回退凭证类型（密码 / 手势）。
  final AppLockMethod method;

  /// 锁屏时优先使用的解锁方式。
  final AppLockPreferredUnlock preferredUnlock;

  bool get biometricPreferred =>
      preferredUnlock == AppLockPreferredUnlock.face ||
      preferredUnlock == AppLockPreferredUnlock.fingerprint;

  /// 兼容旧逻辑：默认方式为生物识别时视为开启生物识别。
  bool get biometricEnabled => biometricPreferred;

  AppLockSettings copyWith({
    AppLockMethod? method,
    AppLockPreferredUnlock? preferredUnlock,
  }) {
    return AppLockSettings(
      method: method ?? this.method,
      preferredUnlock: preferredUnlock ?? this.preferredUnlock,
    );
  }

  @override
  List<Object> get props => [method, preferredUnlock];
}

class AppLockState extends Equatable {
  const AppLockState({
    this.status = AppLockStatus.loading,
    this.settings,
    this.failure,
    this.isAuthenticating = false,
  });

  final AppLockStatus status;
  final AppLockSettings? settings;
  final AppLockFailure? failure;
  final bool isAuthenticating;

  bool get isLocked =>
      status == AppLockStatus.locked || status == AppLockStatus.setupRequired;

  bool get isEnabled => settings != null;

  AppLockState copyWith({
    AppLockStatus? status,
    AppLockSettings? settings,
    AppLockFailure? failure,
    bool clearFailure = false,
    bool? isAuthenticating,
  }) {
    return AppLockState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      failure: clearFailure ? null : failure ?? this.failure,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  @override
  List<Object?> get props => [status, settings, failure, isAuthenticating];
}
