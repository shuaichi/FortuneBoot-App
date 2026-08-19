import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';

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

    test(
      'unlocks a newly configured canonical pattern with its resolution',
      () async {
        final cubit = AppLockCubit(
          settingsStore: _FakeSettingsStore(),
          secretStore: _FakeSecretStore(),
          biometricAuthenticator: _FakeBiometricAuthenticator(),
        );
        addTearDown(cubit.close);
        final pattern = PatternPathResolver.resolve(
          selectedPath: const [0, 2, 5],
          endpoint: 7,
        );

        await cubit.initialize();
        expect(
          await cubit.configure(
            method: AppLockMethod.pattern,
            value: pattern.traditionalCanonicalCsv,
          ),
          isTrue,
        );
        await cubit.onAuthenticated();

        expect(cubit.state.status, AppLockStatus.locked);
        expect(await cubit.unlockWithPattern(pattern), isTrue);
        expect(cubit.state.status, AppLockStatus.unlocked);
      },
    );

    test(
      'unlocks a historical direct pattern hash with its canonical resolution',
      () async {
        final directPattern = '0,2,5,7';
        final cubit = AppLockCubit(
          settingsStore: _FakeSettingsStore(
            const AppLockSettings(method: AppLockMethod.pattern),
          ),
          secretStore: _FakeSecretStore(
            secret: await AppLockVerifier.create(
              AppLockMethod.pattern,
              directPattern,
            ),
          ),
          biometricAuthenticator: _FakeBiometricAuthenticator(),
        );
        addTearDown(cubit.close);
        final pattern = PatternPathResolver.resolve(
          selectedPath: const [0, 2, 5],
          endpoint: 7,
        );

        await cubit.initialize();
        await cubit.onAuthenticated();

        expect(pattern.directCsv, directPattern);
        expect(pattern.traditionalCanonicalCsv, '0,1,2,5,7');
        expect(await cubit.unlockWithPattern(pattern), isTrue);
        expect(cubit.state.status, AppLockStatus.unlocked);
      },
    );

    test('disables a historical direct pattern with its resolution', () async {
      final directPattern = '0,2,5,7';
      final settingsStore = _FakeSettingsStore(
        const AppLockSettings(method: AppLockMethod.pattern),
      );
      final secretStore = _FakeSecretStore(
        secret: await AppLockVerifier.create(
          AppLockMethod.pattern,
          directPattern,
        ),
      );
      final cubit = AppLockCubit(
        settingsStore: settingsStore,
        secretStore: secretStore,
        biometricAuthenticator: _FakeBiometricAuthenticator(),
      );
      addTearDown(cubit.close);
      final pattern = PatternPathResolver.resolve(
        selectedPath: const [0, 2, 5],
        endpoint: 7,
      );

      await cubit.initialize();

      expect(await cubit.disableWithPattern(pattern), isTrue);
      expect(cubit.state.status, AppLockStatus.disabled);
      expect(settingsStore.settings, isNull);
      expect(secretStore.secret, isNull);
    });

    test(
      'keeps the application locked when neither pattern path matches',
      () async {
        final cubit = AppLockCubit(
          settingsStore: _FakeSettingsStore(
            const AppLockSettings(method: AppLockMethod.pattern),
          ),
          secretStore: _FakeSecretStore(
            secret: await AppLockVerifier.create(
              AppLockMethod.pattern,
              '0,2,5,7',
            ),
          ),
          biometricAuthenticator: _FakeBiometricAuthenticator(),
        );
        addTearDown(cubit.close);
        final nonMatchingPattern = PatternPathResolver.resolve(
          selectedPath: const [0, 2, 5],
          endpoint: 8,
        );

        await cubit.initialize();
        await cubit.onAuthenticated();

        expect(await cubit.unlockWithPattern(nonMatchingPattern), isFalse);
        expect(cubit.state.status, AppLockStatus.locked);
      },
    );

    test(
      'does not relock when a delayed resume follows biometric authentication',
      () async {
        final biometrics = _CompleterBiometricAuthenticator();
        final cubit = await _biometricLockedCubit(biometrics);
        addTearDown(cubit.close);

        final authentication = cubit.unlockWithBiometrics(
          localizedReason: 'Unlock FortuneBoot',
        );
        await _flushMicrotasks();
        await cubit.onAppBecameInactive();
        biometrics.complete(BiometricResult.authenticated);

        expect(await authentication, BiometricResult.authenticated);
        await cubit.onAppResumed();

        expect(cubit.state.status, AppLockStatus.unlocked);
      },
    );

    test('locks on an ordinary app resume', () async {
      final biometrics = _CompleterBiometricAuthenticator();
      final cubit = await _biometricLockedCubit(biometrics);
      addTearDown(cubit.close);

      final authentication = cubit.unlockWithBiometrics(
        localizedReason: 'Unlock FortuneBoot',
      );
      await _flushMicrotasks();
      biometrics.complete(BiometricResult.authenticated);
      expect(await authentication, BiometricResult.authenticated);

      await cubit.onAppResumed();

      expect(cubit.state.status, AppLockStatus.locked);
    });

    test(
      'does not exempt a failed biometric authentication from locking',
      () async {
        final biometrics = _CompleterBiometricAuthenticator();
        final cubit = await _biometricLockedCubit(biometrics);
        addTearDown(cubit.close);

        final authentication = cubit.unlockWithBiometrics(
          localizedReason: 'Unlock FortuneBoot',
        );
        await _flushMicrotasks();
        await cubit.onAppBecameInactive();
        biometrics.complete(BiometricResult.failed);

        expect(await authentication, BiometricResult.failed);
        await cubit.onAppResumed();

        expect(cubit.state.status, AppLockStatus.locked);
      },
    );

    test(
      'does not exempt a cancelled biometric authentication from locking',
      () async {
        final biometrics = _CompleterBiometricAuthenticator();
        final cubit = await _biometricLockedCubit(biometrics);
        addTearDown(cubit.close);

        final authentication = cubit.unlockWithBiometrics(
          localizedReason: 'Unlock FortuneBoot',
        );
        await _flushMicrotasks();
        await cubit.onAppBecameInactive();
        biometrics.complete(BiometricResult.cancelled);

        expect(await authentication, BiometricResult.cancelled);
        await cubit.onAppResumed();

        expect(cubit.state.status, AppLockStatus.locked);
      },
    );

    test(
      'cancels the biometric resume exemption after a new background event',
      () async {
        final biometrics = _CompleterBiometricAuthenticator();
        final cubit = await _biometricLockedCubit(biometrics);
        addTearDown(cubit.close);

        final authentication = cubit.unlockWithBiometrics(
          localizedReason: 'Unlock FortuneBoot',
        );
        await _flushMicrotasks();
        await cubit.onAppBecameInactive();
        biometrics.complete(BiometricResult.authenticated);

        expect(await authentication, BiometricResult.authenticated);
        await cubit.onAppResumed();
        await cubit.onAppBecameInactive();
        await cubit.onAppResumed();

        expect(cubit.state.status, AppLockStatus.locked);
      },
    );
  });
}

Future<AppLockCubit> _biometricLockedCubit(
  BiometricAuthenticator biometricAuthenticator,
) async {
  final cubit = AppLockCubit(
    settingsStore: _FakeSettingsStore(
      const AppLockSettings(method: AppLockMethod.pin, biometricEnabled: true),
    ),
    secretStore: _FakeSecretStore(secret: 'pin:00:00'),
    biometricAuthenticator: biometricAuthenticator,
  );
  await cubit.initialize();
  await cubit.onAuthenticated();
  return cubit;
}

Future<void> _flushMicrotasks() => Future<void>.delayed(Duration.zero);

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

class _CompleterBiometricAuthenticator implements BiometricAuthenticator {
  final _result = Completer<BiometricResult>();

  void complete(BiometricResult result) => _result.complete(result);

  @override
  Future<BiometricResult> authenticate({required String localizedReason}) =>
      _result.future;

  @override
  Future<bool> isAvailable() async => true;
}
