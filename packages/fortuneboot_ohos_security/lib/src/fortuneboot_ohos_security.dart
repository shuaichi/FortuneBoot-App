import 'package:flutter/services.dart';

class FortunebootOhosSecurity {
  static void registerWith() {}

  FortunebootOhosSecurity({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'fortuneboot/ohos_security';
  final MethodChannel _channel;

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

  Future<void> setPrivacyVisible(bool visible) async {
    await _channel.invokeMethod<void>('setPrivacyVisible', {
      'visible': visible,
    });
  }
}
