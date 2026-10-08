import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/core/preferences/app_lock_preferences.dart';
import 'package:fortuneboot/core/security/app_lock_secret_store.dart';
import 'package:local_auth/local_auth.dart';

class AppLockAvailability {
  const AppLockAvailability({
    this.face = false,
    this.fingerprint = false,
    this.password = true,
    this.gesture = true,
  });

  final bool face;
  final bool fingerprint;
  final bool password;
  final bool gesture;

  bool get any => face || fingerprint || password || gesture;

  bool supports(AppLockMethod method) => switch (method) {
    AppLockMethod.face => face,
    AppLockMethod.fingerprint => fingerprint,
    AppLockMethod.password => password,
    AppLockMethod.gesture => gesture,
  };

  List<AppLockMethod> get methods => [
    if (face) AppLockMethod.face,
    if (fingerprint) AppLockMethod.fingerprint,
    if (password) AppLockMethod.password,
    if (gesture) AppLockMethod.gesture,
  ];
}

abstract interface class AppLockAuthenticator {
  Future<AppLockAvailability> availability({required bool unlocking});

  Future<void> enrollPassword(String password);

  Future<void> enrollGesture(List<int> cells);

  Future<void> cancel();

  Future<bool> authenticate({
    required String reason,
    required AppLockMethod method,
    String? password,
    List<int>? gesture,
  });
}

/// 国产机常不声明 FEATURE_FACE；只要系统已录入生物识别，就同时给出面容和指纹入口。
@visibleForTesting
({bool face, bool fingerprint}) resolveAndroidBiometricAvailability({
  required bool featureFace,
  required bool featureFingerprint,
  required List<BiometricType> types,
  required bool biometricsEnrolled,
}) {
  final namedFace =
      types.contains(BiometricType.face) || types.contains(BiometricType.iris);
  final namedFinger = types.contains(BiometricType.fingerprint);
  final weak = types.contains(BiometricType.weak);
  final strong = types.contains(BiometricType.strong);
  return (
    face: featureFace || namedFace || weak || biometricsEnrolled,
    fingerprint:
        featureFingerprint || namedFinger || strong || biometricsEnrolled,
  );
}

class LocalAuthAppLockAuthenticator implements AppLockAuthenticator {
  LocalAuthAppLockAuthenticator({
    LocalAuthentication? localAuth,
    MethodChannel? channel,
    AppLockSecretStore? secrets,
    String? operatingSystem,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _channel = channel ?? const MethodChannel('fortuneboot/app_lock'),
       _secrets = secrets ?? AppLockSecretStore(),
       _operatingSystem = operatingSystem;

  final LocalAuthentication _localAuth;
  final MethodChannel _channel;
  final AppLockSecretStore _secrets;
  final String? _operatingSystem;

  bool get _isAndroid {
    if (kIsWeb) return false;
    return (_operatingSystem ?? Platform.operatingSystem) == 'android';
  }

  @override
  Future<AppLockAvailability> availability({required bool unlocking}) async {
    var face = false;
    var fingerprint = false;
    if (_isAndroid) {
      var featureFace = false;
      var featureFingerprint = false;
      try {
        final raw = await _channel.invokeMapMethod<String, dynamic>(
          'availability',
        );
        featureFace = raw?['face'] == true;
        featureFingerprint = raw?['fingerprint'] == true;
      } on MissingPluginException {
        // Fall back to local_auth types.
      } on PlatformException {
        // Fall back to local_auth types.
      }
      var types = const <BiometricType>[];
      var enrolled = false;
      try {
        types = await _localAuth.getAvailableBiometrics();
        enrolled = await _localAuth.canCheckBiometrics;
      } on MissingPluginException {
        // Keep plugin types empty.
      } on PlatformException {
        // Keep plugin types empty.
      }
      final resolved = resolveAndroidBiometricAvailability(
        featureFace: featureFace,
        featureFingerprint: featureFingerprint,
        types: types,
        biometricsEnrolled: enrolled,
      );
      face = resolved.face;
      fingerprint = resolved.fingerprint;
    }
    if (!unlocking) {
      return AppLockAvailability(face: face, fingerprint: fingerprint);
    }
    return AppLockAvailability(
      face: face,
      fingerprint: fingerprint,
      password: await _secrets.hasPassword,
      gesture: await _secrets.hasGesture,
    );
  }

  @override
  Future<void> enrollPassword(String password) => _secrets.setPassword(password);

  @override
  Future<void> enrollGesture(List<int> cells) => _secrets.setGesture(cells);

  @override
  Future<void> cancel() async {
    try {
      await _channel.invokeMethod<void>('cancel');
    } on MissingPluginException {
      // No native prompt to cancel.
    } on PlatformException {
      // Ignore.
    }
  }

  @override
  Future<bool> authenticate({
    required String reason,
    required AppLockMethod method,
    String? password,
    List<int>? gesture,
  }) async {
    try {
      switch (method) {
        case AppLockMethod.password:
          final value = password?.trim() ?? '';
          if (value.length < 4) return false;
          return _secrets.verifyPassword(value);
        case AppLockMethod.gesture:
          final cells = gesture ?? const <int>[];
          if (cells.length < 4) return false;
          return _secrets.verifyGesture(cells);
        case AppLockMethod.face:
        case AppLockMethod.fingerprint:
          if (!_isAndroid) return false;
          try {
            final ok = await _channel.invokeMethod<bool>(
              'authenticate',
              {'method': method.name, 'reason': reason},
            );
            return ok == true;
          } on MissingPluginException {
            if (method == AppLockMethod.fingerprint) return false;
          }
          if (method == AppLockMethod.fingerprint) return false;
          return _localAuth.authenticate(
            localizedReason: reason,
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
              useErrorDialogs: true,
              sensitiveTransaction: true,
            ),
          );
      }
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
