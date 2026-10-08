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

  Future<bool> isFaceAvailable() => _biometricAuthenticator.isFaceAvailable();

  Future<bool> isFingerprintAvailable() =>
      _biometricAuthenticator.isFingerprintAvailable();

  Future<BiometricResult> unlockWithBiometrics({
    required String localizedReason,
  }) async {
    final settings = state.settings;
    if (settings == null || !settings.biometricPreferred || !state.isLocked) {
      return BiometricResult.unavailable;
    }
    if (state.isAuthenticating || !_hasAuthenticatedSession) {
      return BiometricResult.unavailable;
    }
    final preferredBiometric = settings.preferredUnlock;
    final operationVersion = ++_operationVersion;
    final typeAvailable = switch (preferredBiometric) {
      AppLockPreferredUnlock.face =>
        await _biometricAuthenticator.isFaceAvailable(),
      AppLockPreferredUnlock.fingerprint =>
        await _biometricAuthenticator.isFingerprintAvailable(),
      _ => await _biometricAuthenticator.isAvailable(),
    };
    if (!typeAvailable ||
        isClosed ||
        operationVersion != _operationVersion ||
        !_hasAuthenticatedSession ||
        !state.isLocked) {
      if (!isClosed &&
          operationVersion == _operationVersion &&
          state.isLocked) {
        emit(
          state.copyWith(failure: AppLockFailure.biometricUnavailable),
        );
      }
      return BiometricResult.unavailable;
    }
    _resetBiometricLifecycleTracking();
    emit(state.copyWith(isAuthenticating: true, clearFailure: true));
    final result = await _biometricAuthenticator.authenticate(
      localizedReason: localizedReason,
      preferredBiometric: preferredBiometric,
    );
    if (isClosed ||
        operationVersion != _operationVersion ||
        !_hasAuthenticatedSession) {
      if (!isClosed &&
          operationVersion == _operationVersion &&
          state.isAuthenticating) {
        _resetBiometricLifecycleTracking();
        emit(state.copyWith(isAuthenticating: false));
      }
      return result;
    }
    // 生物识别弹窗会触发前后台切换；成功时即使 isAuthenticating 被打乱也要解锁。
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
      return result;
    }
    _resetBiometricLifecycleTracking();
    final failure = switch (result) {
      BiometricResult.failed => AppLockFailure.biometricFailed,
      BiometricResult.unavailable => AppLockFailure.biometricUnavailable,
      BiometricResult.cancelled || BiometricResult.authenticated => null,
    };
    emit(
      state.copyWith(
        isAuthenticating: false,
        failure: failure,
        clearFailure: failure == null,
      ),
    );
    return result;
  }

  Future<bool> configure({
    required AppLockMethod method,
    required String value,
    AppLockPreferredUnlock preferredUnlock = AppLockPreferredUnlock.pin,
  }) async {
    final isValid = switch (method) {
      AppLockMethod.pin => AppLockVerifier.isValidPin(value),
      AppLockMethod.pattern => _isValidPatternValue(value),
    };
    if (!isValid) {
      emit(state.copyWith(failure: AppLockFailure.invalidCredential));
      return false;
    }
    final normalizedPreferred = _normalizePreferredUnlock(
      preferredUnlock,
      method,
    );
    if (normalizedPreferred == null) {
      emit(state.copyWith(failure: AppLockFailure.configurationSaveFailed));
      return false;
    }
    try {
      final verifier = await AppLockVerifier.create(method, value);
      await _secretStore.writeVerifier(verifier);
      final settings = AppLockSettings(
        method: method,
        preferredUnlock: normalizedPreferred,
      );
      try {
        await _settingsStore.write(settings);
      } on Object {
        await _secretStore.clear();
        rethrow;
      }
      // 在设置页开启应用锁时，用户已在主壳内，需同步会话标记，
      // 否则切后台不会触发上锁。
      _hasAuthenticatedSession = true;
      _resetBiometricLifecycleTracking();
      emit(AppLockState(status: AppLockStatus.unlocked, settings: settings));
      return true;
    } on Object {
      emit(state.copyWith(failure: AppLockFailure.configurationSaveFailed));
      return false;
    }
  }

  /// 已开启应用锁时切换默认解锁方式（密码/手势为回退凭证，面容/指纹为优先方式）。
  Future<bool> setPreferredUnlock(AppLockPreferredUnlock preferredUnlock) async {
    final settings = state.settings;
    if (settings == null || state.status == AppLockStatus.disabled) {
      return false;
    }
    final normalized = _normalizePreferredUnlock(
      preferredUnlock,
      settings.method,
    );
    if (normalized == null) {
      emit(state.copyWith(failure: AppLockFailure.configurationSaveFailed));
      return false;
    }
    try {
      final next = settings.copyWith(preferredUnlock: normalized);
      await _settingsStore.write(next);
      emit(state.copyWith(settings: next, clearFailure: true));
      return true;
    } on Object {
      emit(state.copyWith(failure: AppLockFailure.configurationSaveFailed));
      return false;
    }
  }

  AppLockPreferredUnlock? _normalizePreferredUnlock(
    AppLockPreferredUnlock preferred,
    AppLockMethod fallbackMethod,
  ) {
    switch (preferred) {
      case AppLockPreferredUnlock.pin:
        return fallbackMethod == AppLockMethod.pin
            ? AppLockPreferredUnlock.pin
            : null;
      case AppLockPreferredUnlock.pattern:
        return fallbackMethod == AppLockMethod.pattern
            ? AppLockPreferredUnlock.pattern
            : null;
      case AppLockPreferredUnlock.face:
      case AppLockPreferredUnlock.fingerprint:
        return preferred;
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
