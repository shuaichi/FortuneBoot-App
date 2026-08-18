import 'dart:io' show Platform;

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot_ohos_security/fortuneboot_ohos_security.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppLockSettingsStore {
  Future<AppLockSettings?> read();
  Future<void> write(AppLockSettings settings);
  Future<void> clear();
}

abstract interface class AppLockSecretStore {
  Future<String?> readVerifier();
  Future<void> writeVerifier(String value);
  Future<void> clear();
}

abstract interface class BiometricAuthenticator {
  Future<bool> isAvailable();
  Future<BiometricResult> authenticate({required String localizedReason});
}

class SharedPreferencesAppLockSettingsStore implements AppLockSettingsStore {
  SharedPreferencesAppLockSettingsStore({SharedPreferences? sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  static const _enabledKey = 'fortune.app_lock.enabled';
  static const _methodKey = 'fortune.app_lock.method';
  static const _biometricEnabledKey = 'fortune.app_lock.biometric_enabled';

  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> get _prefs async =>
      _sharedPreferences ??= await SharedPreferences.getInstance();

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_enabledKey),
      prefs.remove(_methodKey),
      prefs.remove(_biometricEnabledKey),
    ]);
  }

  @override
  Future<AppLockSettings?> read() async {
    final prefs = await _prefs;
    if (prefs.getBool(_enabledKey) != true) return null;
    final methodValue = prefs.getString(_methodKey);
    final method = AppLockMethod.values.where(
      (item) => item.name == methodValue,
    );
    if (method.isEmpty) return null;
    return AppLockSettings(
      method: method.first,
      biometricEnabled: prefs.getBool(_biometricEnabledKey) ?? false,
    );
  }

  @override
  Future<void> write(AppLockSettings settings) async {
    final prefs = await _prefs;
    final results = await Future.wait([
      prefs.setBool(_enabledKey, true),
      prefs.setString(_methodKey, settings.method.name),
      prefs.setBool(_biometricEnabledKey, settings.biometricEnabled),
    ]);
    if (results.any((saved) => !saved)) {
      throw StateError('App lock settings were not persisted');
    }
  }
}

class SecureAppLockSecretStore implements AppLockSecretStore {
  SecureAppLockSecretStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  static const _verifierKey = 'fortune.app_lock.verifier';
  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() => _storage.delete(key: _verifierKey);

  @override
  Future<String?> readVerifier() => _storage.read(key: _verifierKey);

  @override
  Future<void> writeVerifier(String value) =>
      _storage.write(key: _verifierKey, value: value);
}

class OhosAppLockSecretStore implements AppLockSecretStore {
  OhosAppLockSecretStore({FortunebootOhosSecurity? security})
    : _security = security ?? FortunebootOhosSecurity();

  static const _verifierKey = 'fortune.app_lock.verifier';
  final FortunebootOhosSecurity _security;

  @override
  Future<void> clear() => _security.deleteSecret(_verifierKey);

  @override
  Future<String?> readVerifier() => _security.readSecret(_verifierKey);

  @override
  Future<void> writeVerifier(String value) =>
      _security.writeSecret(key: _verifierKey, value: value);
}

class OhosBiometricAuthenticator implements BiometricAuthenticator {
  OhosBiometricAuthenticator({FortunebootOhosSecurity? security})
    : _security = security ?? FortunebootOhosSecurity();

  final FortunebootOhosSecurity _security;

  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      return switch (await _security.authenticateBiometrics(
        localizedReason: localizedReason,
      )) {
        'authenticated' => BiometricResult.authenticated,
        'cancelled' => BiometricResult.cancelled,
        'unavailable' => BiometricResult.unavailable,
        _ => BiometricResult.failed,
      };
    } on Object {
      return BiometricResult.failed;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _security.isBiometricAvailable();
    } on Object {
      return false;
    }
  }
}

class LocalBiometricAuthenticator implements BiometricAuthenticator {
  LocalBiometricAuthenticator({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      final authenticated = await _authentication.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated
          ? BiometricResult.authenticated
          : BiometricResult.cancelled;
    } on Object {
      return BiometricResult.failed;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _authentication.canCheckBiometrics) return false;
      return (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }
}

class AppLockPlatformDependencies {
  const AppLockPlatformDependencies({
    required this.secretStore,
    required this.biometricAuthenticator,
  });

  final AppLockSecretStore secretStore;
  final BiometricAuthenticator biometricAuthenticator;

  factory AppLockPlatformDependencies.create() {
    if (kIsWeb) {
      return AppLockPlatformDependencies(
        secretStore: SecureAppLockSecretStore(),
        biometricAuthenticator: LocalBiometricAuthenticator(),
      );
    }
    if (Platform.operatingSystem == 'ohos') {
      return AppLockPlatformDependencies(
        secretStore: OhosAppLockSecretStore(),
        biometricAuthenticator: OhosBiometricAuthenticator(),
      );
    }
    return AppLockPlatformDependencies(
      secretStore: SecureAppLockSecretStore(),
      biometricAuthenticator: LocalBiometricAuthenticator(),
    );
  }
}

class AppLockVerifier {
  static const _iterations = 120000;
  static const _saltLength = 16;
  static const _hashLength = 32;
  static final _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: _hashLength * 8,
  );

  static bool isValidPin(String value) => RegExp(r'^\d{6,12}$').hasMatch(value);

  static bool isValidPattern(List<int> pattern) {
    return pattern.length >= 4 &&
        pattern.length <= 9 &&
        pattern.every((point) => point >= 0 && point <= 8) &&
        pattern.toSet().length == pattern.length;
  }

  static Future<String> create(AppLockMethod method, String value) async {
    final salt = SecretKeyData.random(length: _saltLength).bytes;
    final hash = await _algorithm.deriveKey(
      secretKey: SecretKeyData(_encode(method, value).codeUnits),
      nonce: salt,
    );
    final hashBytes = await hash.extractBytes();
    return '${method.name}:${_encodeBytes(salt)}:${_encodeBytes(hashBytes)}';
  }

  static Future<bool> verify(
    AppLockMethod method,
    String value,
    String storedValue,
  ) async {
    final components = storedValue.split(':');
    if (components.length != 3 || components.first != method.name) return false;
    final salt = _decodeBytes(components[1]);
    final expected = _decodeBytes(components[2]);
    if (salt == null || expected == null) return false;
    final hash = await _algorithm.deriveKey(
      secretKey: SecretKeyData(_encode(method, value).codeUnits),
      nonce: salt,
    );
    return _constantTimeEquals(await hash.extractBytes(), expected);
  }

  static String _encode(AppLockMethod method, String value) => '$method:$value';

  static String _encodeBytes(List<int> bytes) =>
      bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();

  static bool _constantTimeEquals(List<int> first, List<int> second) {
    var difference = first.length ^ second.length;
    final length = first.length < second.length ? first.length : second.length;
    for (var index = 0; index < length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }

  static List<int>? _decodeBytes(String value) {
    if (value.length.isOdd || !RegExp(r'^[a-f0-9]+$').hasMatch(value)) {
      return null;
    }
    return [
      for (var index = 0; index < value.length; index += 2)
        int.parse(value.substring(index, index + 2), radix: 16),
    ];
  }
}
