import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/security/screen_capture_protection.dart';
import 'package:fortuneboot_ohos_security/fortuneboot_ohos_security.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('fortuneboot/screen_capture_protection');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends allowed state to Android native protection', () async {
    MethodCall? call;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          call = methodCall;
        });
    final protection = PlatformScreenCaptureProtection(
      channel: channel,
      operatingSystem: 'android',
    );

    final applied = await protection.setScreenCaptureAllowed(true);

    expect(applied, isTrue);
    expect(call?.method, 'setScreenCaptureAllowed');
    expect(call?.arguments, {'allowed': true});
  });

  test('returns false when native protection reports an error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          throw PlatformException(code: 'screen_capture_protection_failed');
        });
    final protection = PlatformScreenCaptureProtection(
      channel: channel,
      operatingSystem: 'ios',
    );

    expect(await protection.setScreenCaptureAllowed(false), isFalse);
  });

  test('returns false on unsupported platforms', () async {
    final protection = PlatformScreenCaptureProtection(
      channel: channel,
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
      channel: channel,
      ohosSecurity: FortunebootOhosSecurity(channel: ohosChannel),
      operatingSystem: 'ohos',
    );

    final applied = await protection.setScreenCaptureAllowed(false);

    expect(applied, isTrue);
    expect(call?.method, 'setScreenCaptureAllowed');
    expect(call?.arguments, {'allowed': false});
  });
}
