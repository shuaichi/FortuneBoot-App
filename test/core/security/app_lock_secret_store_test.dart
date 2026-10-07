import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/security/app_lock_secret_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('password hash verifies the enrolled secret only', () async {
    final store = AppLockSecretStore();
    expect(await store.hasPassword, isFalse);

    await store.setPassword('lock-ok');
    expect(await store.hasPassword, isTrue);
    expect(await store.verifyPassword('lock-ok'), isTrue);
    expect(await store.verifyPassword('wrong'), isFalse);
  });

  test('gesture hash uses the cell sequence', () async {
    final store = AppLockSecretStore();
    await store.setGesture(const [0, 1, 2, 5]);
    expect(await store.hasGesture, isTrue);
    expect(await store.verifyGesture(const [0, 1, 2, 5]), isTrue);
    expect(await store.verifyGesture(const [0, 1, 2, 4]), isFalse);
  });
}
