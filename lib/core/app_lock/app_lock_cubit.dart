import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';

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
  bool _biometricLifecycleInterrupted = false;
  bool _biometricResumeObservedWhileAuthenticating = false;
  bool _skipNextResumedAfterBiometricSuccess = false;

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
    if (state.isAuthenticating) {
      _biometricResumeObservedWhileAuthenticating = true;
      return;
    }
    if (_skipNextResumedAfterBiometricSuccess) {
      _skipNextResumedAfterBiometricSuccess = false;
      return;
    }
    if (!_hasAuthenticatedSession) return;
    final settings = state.settings;
    if (settings == null) return;
    await _lockIfCredentialExists(settings);
  }

  Future<void> onAppBecameInactive() async {
    if (state.isAuthenticating) {
      _biometricLifecycleInterrupted = true;
      return;
    }
    _skipNextResumedAfterBiometricSuccess = false;
    await lockNow();
  }

  void onSignedOut() {
    _operationVersion++;
    _hasAuthenticatedSession = false;
    _resetBiometricLifecycleTracking();
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

  Future<bool> unlockWithPattern(PatternPathResolution pattern) =>
      _unlockWithPatternCandidates(pattern);

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
    _resetBiometricLifecycleTracking();
    final operationVersion = ++_operationVersion;
    emit(state.copyWith(isAuthenticating: true, clearFailure: true));
    final result = await _biometricAuthenticator.authenticate(
      localizedReason: localizedReason,
    );
    if (isClosed ||
        operationVersion != _operationVersion ||
        !state.isAuthenticating) {
      if (!state.isAuthenticating) {
        _resetBiometricLifecycleTracking();
      }
      return result;
    }
    if (result == BiometricResult.authenticated) {
      final shouldSkipNextResume =
          _biometricLifecycleInterrupted &&
          !_biometricResumeObservedWhileAuthenticating;
      _resetBiometricLifecycleTracking();
      _skipNextResumedAfterBiometricSuccess = shouldSkipNextResume;
      emit(
        state.copyWith(
          status: AppLockStatus.unlocked,
          isAuthenticating: false,
          clearFailure: true,
        ),
      );
    } else {
      _resetBiometricLifecycleTracking();
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
      _resetBiometricLifecycleTracking();
      emit(AppLockState(status: AppLockStatus.unlocked, settings: settings));
      return true;
    } on Object {
      emit(state.copyWith(failure: AppLockFailure.configurationSaveFailed));
      return false;
    }
  }

  Future<bool> disableWithPattern(PatternPathResolution pattern) async {
    final settings = state.settings;
    if (settings == null ||
        settings.method != AppLockMethod.pattern ||
        !await _verifyPatternCandidates(settings, pattern)) {
      emit(state.copyWith(failure: AppLockFailure.invalidCredential));
      return false;
    }
    return _disableVerified();
  }

  Future<bool> disable(String value) async {
    final settings = state.settings;
    if (settings == null || !await _verifyCredential(settings, value)) {
      emit(state.copyWith(failure: AppLockFailure.invalidCredential));
      return false;
    }
    return _disableVerified();
  }

  Future<bool> _unlockWithPatternCandidates(
    PatternPathResolution pattern,
  ) async {
    final settings = state.settings;
    if (settings == null ||
        settings.method != AppLockMethod.pattern ||
        !state.isLocked ||
        state.isAuthenticating) {
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
    final isVerified = await _verifyPatternCandidatesWithVerifier(
      pattern,
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

  Future<bool> _disableVerified() async {
    try {
      await _settingsStore.clear();
      await _secretStore.clear();
      _resetBiometricLifecycleTracking();
      emit(const AppLockState(status: AppLockStatus.disabled));
      return true;
    } on Object {
      emit(state.copyWith(failure: AppLockFailure.disableFailed));
      return false;
    }
  }

  Future<bool> _verifyPatternCandidates(
    AppLockSettings settings,
    PatternPathResolution pattern,
  ) async {
    final verifier = await _secretStore.readVerifier();
    if (verifier == null) return false;
    return _verifyPatternCandidatesWithVerifier(pattern, verifier);
  }

  Future<bool> _verifyPatternCandidatesWithVerifier(
    PatternPathResolution pattern,
    String verifier,
  ) async {
    if (!_isValidPatternValue(pattern.traditionalCanonicalCsv)) return false;
    final matchesCanonical = await AppLockVerifier.verify(
      AppLockMethod.pattern,
      pattern.traditionalCanonicalCsv,
      verifier,
    );
    if (matchesCanonical ||
        pattern.directCsv == pattern.traditionalCanonicalCsv ||
        !_isValidPatternValue(pattern.directCsv)) {
      return matchesCanonical;
    }
    return AppLockVerifier.verify(
      AppLockMethod.pattern,
      pattern.directCsv,
      verifier,
    );
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

  void _resetBiometricLifecycleTracking() {
    _biometricLifecycleInterrupted = false;
    _biometricResumeObservedWhileAuthenticating = false;
    _skipNextResumedAfterBiometricSuccess = false;
  }

  bool _isValidPatternValue(String value) {
    final values = value.split(',').map(int.tryParse).toList();
    return values.every((item) => item != null) &&
        AppLockVerifier.isValidPattern(values.cast<int>());
  }
}
