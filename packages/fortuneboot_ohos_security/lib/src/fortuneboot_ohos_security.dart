import 'package:flutter/services.dart';

class FortunebootOhosSecurity {
  static void registerWith() {}

  FortunebootOhosSecurity({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'fortuneboot/ohos_security';
  final MethodChannel _channel;

  Future<void> setScreenCaptureAllowed(bool allowed) async {
    await _channel.invokeMethod<void>('setScreenCaptureAllowed', {
      'allowed': allowed,
    });
  }

  // Secure app-lock storage bridge. The current bundled OHOS native plugin
  // focuses on screen capture and save APIs; native handlers for these
  // methods are preserved in Git history (bc6fe92) for the secure app lock.
  Future<String?> readSecret(String key) =>
      _channel.invokeMethod<String>('readSecret', {'key': key});

  Future<void> writeSecret({required String key, required String value}) async {
    await _channel.invokeMethod<void>('writeSecret', {
      'key': key,
      'value': value,
    });
  }

  Future<void> deleteSecret(String key) async {
    await _channel.invokeMethod<void>('deleteSecret', {'key': key});
  }

  Future<bool> isBiometricAvailable() async {
    return await _channel.invokeMethod<bool>('isBiometricAvailable') ?? false;
  }

  Future<String> authenticateBiometrics({
    required String localizedReason,
  }) async {
    return await _channel.invokeMethod<String>('authenticateBiometrics', {
          'localizedReason': localizedReason,
        }) ??
        'failed';
  }

  /// Saves image bytes to the system gallery via HarmonyOS photoAccessHelper.
  ///
  /// Shows the system confirmation dialog. Returns `true` when the user
  /// confirms and the write succeeds; `false` when cancelled or failed.
  Future<bool> saveImageToGallery({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return await _channel.invokeMethod<bool>('saveImageToGallery', {
          'bytes': bytes,
          'fileName': fileName,
        }) ??
        false;
  }

  /// Saves a document via HarmonyOS DocumentViewPicker.
  ///
  /// Returns `saved`, `cancelled`, or throws [PlatformException] on failure.
  Future<String> saveDocument({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return await _channel.invokeMethod<String>('saveDocument', {
          'bytes': bytes,
          'fileName': fileName,
        }) ??
        'cancelled';
  }
}
