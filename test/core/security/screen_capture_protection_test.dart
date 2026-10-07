import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/security/screen_capture_protection.dart';
import 'package:fortuneboot_ohos_security/fortuneboot_ohos_security.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns false on unsupported platforms', () async {
    final protection = PlatformScreenCaptureProtection(
      operatingSystem: 'linux',
    );

    expect(await protection.setScreenCaptureAllowed(false), isFalse);
  });

  test('maps HarmonyOS calls to its security bridge', () async {
    const ohosChannel = MethodChannel('fortuneboot/ohos_security');
    MethodCall? call;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ohosChannel, (methodCall) async {
          call = methodCall;
        });
    final protection = PlatformScreenCaptureProtection(
      ohosSecurity: FortunebootOhosSecurity(channel: ohosChannel),
      operatingSystem: 'ohos',
    );

    final applied = await protection.setScreenCaptureAllowed(false);

    expect(applied, isTrue);
    expect(call?.method, 'setScreenCaptureAllowed');
    expect(call?.arguments, {'allowed': false});
  });

  test('returns false when HarmonyOS protection reports an error', () async {
    const ohosChannel = MethodChannel('fortuneboot/ohos_security');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ohosChannel, (methodCall) async {
          throw PlatformException(code: 'screen_capture_protection_failed');
        });
    final protection = PlatformScreenCaptureProtection(
      ohosSecurity: FortunebootOhosSecurity(channel: ohosChannel),
      operatingSystem: 'ohos',
    );

    expect(await protection.setScreenCaptureAllowed(false), isFalse);
  });
}
