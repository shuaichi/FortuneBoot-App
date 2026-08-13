import 'package:equatable/equatable.dart';

enum AppLockMethod { pin, pattern }

enum AppLockStatus { loading, disabled, locked, unlocked, setupRequired }

enum BiometricResult { authenticated, cancelled, unavailable, failed }

class AppLockSettings extends Equatable {
  const AppLockSettings({required this.method, this.biometricEnabled = false});

  final AppLockMethod method;
  final bool biometricEnabled;

  @override
  List<Object> get props => [method, biometricEnabled];
}

class AppLockState extends Equatable {
  const AppLockState({
    this.status = AppLockStatus.loading,
    this.settings,
    this.errorMessage,
    this.isAuthenticating = false,
  });

  final AppLockStatus status;
  final AppLockSettings? settings;
  final String? errorMessage;
  final bool isAuthenticating;

  bool get isLocked =>
      status == AppLockStatus.locked || status == AppLockStatus.setupRequired;

  bool get isEnabled => settings != null;

  AppLockState copyWith({
    AppLockStatus? status,
    AppLockSettings? settings,
    String? errorMessage,
    bool clearError = false,
    bool? isAuthenticating,
  }) {
    return AppLockState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage, isAuthenticating];
}
