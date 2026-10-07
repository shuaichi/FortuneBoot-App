import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot_ohos_security/fortuneboot_ohos_security.dart';

abstract interface class ScreenCaptureProtection {
  Future<bool> setScreenCaptureAllowed(bool allowed);
}

class PlatformScreenCaptureProtection implements ScreenCaptureProtection {
  PlatformScreenCaptureProtection({
    FortunebootOhosSecurity? ohosSecurity,
    String? operatingSystem,
  }) : _ohosSecurity = ohosSecurity ?? FortunebootOhosSecurity(),
       _operatingSystem = operatingSystem;

  final FortunebootOhosSecurity _ohosSecurity;
  final String? _operatingSystem;
  Future<void> _operationQueue = Future<void>.value();

  @override
  Future<bool> setScreenCaptureAllowed(bool allowed) {
    final operation = _operationQueue.then(
      (_) => _applyScreenCaptureAllowed(allowed),
    );
    _operationQueue = operation.then<void>((_) {}, onError: (_) {});
    return operation;
  }

  Future<bool> _applyScreenCaptureAllowed(bool allowed) async {
    if (kIsWeb) return false;

    final operatingSystem = _operatingSystem ?? Platform.operatingSystem;
    if (operatingSystem != 'ohos') return false;

    try {
      await _ohosSecurity.setScreenCaptureAllowed(allowed);
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
