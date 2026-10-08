import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockSecretStore {
  AppLockSecretStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _passwordSaltKey =
      'fortune.preferences.security.appLockPasswordSalt';
  static const _passwordHashKey =
      'fortune.preferences.security.appLockPasswordHash';
  static const _gestureSaltKey =
      'fortune.preferences.security.appLockGestureSalt';
  static const _gestureHashKey =
      'fortune.preferences.security.appLockGestureHash';

  SharedPreferences? _preferences;
  final _sha256 = Sha256();

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> get hasPassword async {
    final prefs = await _prefs;
    return (prefs.getString(_passwordHashKey) ?? '').isNotEmpty;
  }

  Future<bool> get hasGesture async {
    final prefs = await _prefs;
    return (prefs.getString(_gestureHashKey) ?? '').isNotEmpty;
  }

  Future<void> setPassword(String password) async {
    await _writeSecret(
      saltKey: _passwordSaltKey,
      hashKey: _passwordHashKey,
      secret: password,
    );
  }

  Future<void> setGesture(List<int> cells) async {
    await _writeSecret(
      saltKey: _gestureSaltKey,
      hashKey: _gestureHashKey,
      secret: cells.join(','),
    );
  }

  Future<bool> verifyPassword(String password) async {
    return _verify(
      saltKey: _passwordSaltKey,
      hashKey: _passwordHashKey,
      secret: password,
    );
  }

  Future<bool> verifyGesture(List<int> cells) async {
    return _verify(
      saltKey: _gestureSaltKey,
      hashKey: _gestureHashKey,
      secret: cells.join(','),
    );
  }

  Future<void> _writeSecret({
    required String saltKey,
    required String hashKey,
    required String secret,
  }) async {
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final digest = await _sha256.hash([...salt, ...utf8.encode(secret)]);
    final prefs = await _prefs;
    await prefs.setString(saltKey, base64Encode(salt));
    await prefs.setString(hashKey, base64Encode(digest.bytes));
  }

  Future<bool> _verify({
    required String saltKey,
    required String hashKey,
    required String secret,
  }) async {
    final prefs = await _prefs;
    final saltRaw = prefs.getString(saltKey);
    final hashRaw = prefs.getString(hashKey);
    if (saltRaw == null || hashRaw == null || saltRaw.isEmpty || hashRaw.isEmpty) {
      return false;
    }
    final digest = await _sha256.hash([
      ...base64Decode(saltRaw),
      ...utf8.encode(secret),
    ]);
    return base64Encode(digest.bytes) == hashRaw;
  }
}
