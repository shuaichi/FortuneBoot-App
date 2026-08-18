import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';

void main() {
  group('AppLockCubit', () {
    test('stays disabled by default', () async {
      final cubit = AppLockCubit(
        settingsStore: _FakeSettingsStore(),
        secretStore: _FakeSecretStore(),
        biometricAuthenticator: _FakeBiometricAuthenticator(),
      );
      addTearDown(cubit.close);

      await cubit.initialize();

      expect(cubit.state.status, AppLockStatus.disabled);
    });

    test('locks an authenticated session with a stored credential', () async {
      final cubit = AppLockCubit(
        settingsStore: _FakeSettingsStore(
          const AppLockSettings(method: AppLockMethod.pin),
        ),
        secretStore: _FakeSecretStore(secret: 'stored-secret'),
        biometricAuthenticator: _FakeBiometricAuthenticator(),
      );
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.onAuthenticated();

      expect(cubit.state.status, AppLockStatus.locked);
    });

    test('fails closed when enabled settings have no credential', () async {
      final cubit = AppLockCubit(
        settingsStore: _FakeSettingsStore(
          const AppLockSettings(method: AppLockMethod.pin),
        ),
        secretStore: _FakeSecretStore(),
        biometricAuthenticator: _FakeBiometricAuthenticator(),
      );
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.onAuthenticated();

      expect(cubit.state.status, AppLockStatus.setupRequired);
    });

    test('can disable an unlocked application lock', () async {
      final cubit = AppLockCubit(
        settingsStore: _FakeSettingsStore(
          const AppLockSettings(method: AppLockMethod.pin),
        ),
        secretStore: _FakeSecretStore(secret: 'pin:00:00'),
        biometricAuthenticator: _FakeBiometricAuthenticator(),
      );
      addTearDown(cubit.close);

      await cubit.initialize();
      await cubit.configure(method: AppLockMethod.pin, value: '123456');

      expect(await cubit.disable('123456'), isTrue);
      expect(cubit.state.status, AppLockStatus.disabled);
    });
  });
}

class _FakeSettingsStore implements AppLockSettingsStore {
  _FakeSettingsStore([this.settings]);

  AppLockSettings? settings;

  @override
  Future<void> clear() async => settings = null;

  @override
  Future<AppLockSettings?> read() async => settings;

  @override
  Future<void> write(AppLockSettings value) async => settings = value;
}

class _FakeSecretStore implements AppLockSecretStore {
  _FakeSecretStore({this.secret});

  String? secret;

  @override
  Future<void> clear() async => secret = null;

  @override
  Future<String?> readVerifier() async => secret;

  @override
  Future<void> writeVerifier(String value) async => secret = value;
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
  }) async => BiometricResult.cancelled;

  @override
  Future<bool> isAvailable() async => false;
}
