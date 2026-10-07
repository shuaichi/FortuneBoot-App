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
