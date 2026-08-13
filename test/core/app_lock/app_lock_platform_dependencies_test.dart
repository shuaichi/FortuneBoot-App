import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';

void main() {
  test('creates default dependencies without platform access', () {
    final dependencies = AppLockPlatformDependencies.create();

    expect(dependencies.secretStore, isA<SecureAppLockSecretStore>());
    expect(
      dependencies.biometricAuthenticator,
      isA<LocalBiometricAuthenticator>(),
    );
  });
}
