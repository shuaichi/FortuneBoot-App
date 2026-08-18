import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required AppLockSettingsStore settingsStore,
    required AppLockSecretStore secretStore,
    required BiometricAuthenticator biometricAuthenticator,
  }) : _settingsStore = settingsStore,
       _secretStore = secretStore,
       _biometricAuthenticator = biometricAuthenticator,
       super(const AppLockState());

  final AppLockSettingsStore _settingsStore;
  final AppLockSecretStore _secretStore;
  final BiometricAuthenticator _biometricAuthenticator;
  bool _hasAuthenticatedSession = false;
  bool _isInitialized = false;
  int _operationVersion = 0;

  Future<void> initialize() async {
    try {
      final settings = await _settingsStore.read();
      _isInitialized = true;
      if (settings != null && _hasAuthenticatedSession) {
        await _lockIfCredentialExists(settings);
        return;
      }
      emit(
        AppLockState(
          status: settings == null
              ? AppLockStatus.disabled
              : AppLockStatus.unlocked,
          settings: settings,
        ),
      );
    } on Object {
      emit(const AppLockState(status: AppLockStatus.setupRequired));
    }
  }

  Future<void> onAuthenticated() async {
    _hasAuthenticatedSession = true;
    if (!_isInitialized) {
      await initialize();
      return;
    }
    final settings = state.settings;
    if (settings == null) return;
    await _lockIfCredentialExists(settings);
  }

  Future<void> onAppResumed() async {
    if (!_hasAuthenticatedSession || state.isAuthenticating) return;
    final settings = state.settings;
    if (settings == null) return;
    await _lockIfCredentialExists(settings);
  }

  void onSignedOut() {
    _operationVersion++;
    _hasAuthenticatedSession = false;
    emit(
      AppLockState(status: AppLockStatus.disabled, settings: state.settings),
    );
  }

  Future<void> lockNow() async {
    if (!_hasAuthenticatedSession || state.isAuthenticating) return;
    final settings = state.settings;
    if (settings == null) return;
    await _lockIfCredentialExists(settings);
  }

  Future<bool> unlockWithCredential(String value) async {
    final settings = state.settings;
    if (settings == null || !state.isLocked || state.isAuthenticating) {
      return false;
    }
    final isValid = switch (settings.method) {
      AppLockMethod.pin => AppLockVerifier.isValidPin(value),
      AppLockMethod.pattern => _isValidPatternValue(value),
    };
    if (!isValid) {
      emit(state.copyWith(failure: AppLockFailure.invalidCredential));
      return false;
    }
    final operationVersion = ++_operationVersion;
    final verifier = await _secretStore.readVerifier();
    if (operationVersion != _operationVersion || !_hasAuthenticatedSession) {
      return false;
    }
    if (verifier == null) {
      emit(
        AppLockState(status: AppLockStatus.setupRequired, settings: settings),
      );
      return false;
    }
    final isVerified = await AppLockVerifier.verify(
      settings.method,
      value,
      verifier,
    );
    if (operationVersion != _operationVersion || !_hasAuthenticatedSession) {
      return false;
    }
    if (!isVerified) {
      emit(state.copyWith(failure: AppLockFailure.invalidCredential));
      return false;
    }
    emit(state.copyWith(status: AppLockStatus.unlocked, clearFailure: true));
    return true;
  }

  Future<bool> isBiometricAvailable() => _biometricAuthenticator.isAvailable();

  Future<BiometricResult> unlockWithBiometrics({
    required String localizedReason,
  }) async {
    final settings = state.settings;
    if (settings == null || !settings.biometricEnabled || !state.isLocked) {
      return BiometricResult.unavailable;
    }
    if (state.isAuthenticating ||
        !await _biometricAuthenticator.isAvailable()) {
      return BiometricResult.unavailable;
    }
    final operationVersion = ++_operationVersion;
    emit(state.copyWith(isAuthenticating: true, clearFailure: true));
    final result = await _biometricAuthenticator.authenticate(
      localizedReason: localizedReason,
    );
    if (isClosed ||
        operationVersion != _operationVersion ||
        !state.isAuthenticating) {
      return result;
    }
    if (result == BiometricResult.authenticated) {
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          isAuthenticating: false,
          clearFailure: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isAuthenticating: false,
          failure: result == BiometricResult.failed
              ? AppLockFailure.invalidCredential
              : null,
          clearFailure: result != BiometricResult.failed,
        ),
      );
    }
    return result;
  }

  Future<bool> configure({
    required AppLockMethod method,
    required String value,
    bool biometricEnabled = false,
  }) async {
    final isValid = switch (method) {
      AppLockMethod.pin => AppLockVerifier.isValidPin(value),
      AppLockMethod.pattern => _isValidPatternValue(value),
    };
    if (!isValid) return false;
    try {
      final verifier = await AppLockVerifier.create(method, value);
      await _secretStore.writeVerifier(verifier);
      final settings = AppLockSettings(
        method: method,
        biometricEnabled: biometricEnabled,
      );
      try {
        await _settingsStore.write(settings);
      } on Object {
        await _secretStore.clear();
        rethrow;
      }
      emit(AppLockState(status: AppLockStatus.unlocked, settings: settings));
      return true;
    } on Object {
      emit(state.copyWith(failure: AppLockFailure.configurationSaveFailed));
      return false;
    }
  }

  Future<bool> disable(String value) async {
    final settings = state.settings;
    if (settings == null || !await _verifyCredential(settings, value)) {
      emit(state.copyWith(failure: AppLockFailure.invalidCredential));
      return false;
    }
    try {
      await _settingsStore.clear();
      await _secretStore.clear();
      emit(const AppLockState(status: AppLockStatus.disabled));
      return true;
    } on Object {
      emit(state.copyWith(failure: AppLockFailure.disableFailed));
      return false;
    }
  }

  Future<bool> _verifyCredential(AppLockSettings settings, String value) async {
    final isValid = switch (settings.method) {
      AppLockMethod.pin => AppLockVerifier.isValidPin(value),
      AppLockMethod.pattern => _isValidPatternValue(value),
    };
    if (!isValid) return false;
    final verifier = await _secretStore.readVerifier();
    if (verifier == null) return false;
    return AppLockVerifier.verify(settings.method, value, verifier);
  }

  Future<void> _lockIfCredentialExists(AppLockSettings settings) async {
    final operationVersion = ++_operationVersion;
    emit(AppLockState(status: AppLockStatus.locked, settings: settings));
    try {
      final verifier = await _secretStore.readVerifier();
      if (!_isCurrentLockOperation(operationVersion)) return;
      if (verifier == null) {
        emit(
          AppLockState(status: AppLockStatus.setupRequired, settings: settings),
        );
      }
    } on Object {
      if (!_isCurrentLockOperation(operationVersion)) return;
      emit(
        AppLockState(status: AppLockStatus.setupRequired, settings: settings),
      );
    }
  }

  bool _isCurrentLockOperation(int operationVersion) =>
      _hasAuthenticatedSession && operationVersion == _operationVersion;

  bool _isValidPatternValue(String value) {
    final values = value.split(',').map(int.tryParse).toList();
    return values.every((item) => item != null) &&
        AppLockVerifier.isValidPattern(values.cast<int>());
  }
}
