import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/app_lock_preferences.dart';
import 'package:fortuneboot/core/security/app_lock_authenticator.dart';
import 'package:fortuneboot/core/security/app_lock_cubit.dart';

void main() {
  test('locks when entering the main area if the preference is on', () {
    var enabled = true;
    final cubit = AppLockCubit(
      authenticator: _FakeAppLockAuthenticator(),
      isEnabled: () => enabled,
    );
    addTearDown(cubit.close);

    cubit.enterProtectedArea();

    expect(cubit.state.inProtectedArea, isTrue);
    expect(cubit.state.locked, isTrue);
    expect(cubit.state.pendingLock, isFalse);
  });

  test('waits for preferences when the switch is still unread', () {
    var enabled = false;
    final cubit = AppLockCubit(
      authenticator: _FakeAppLockAuthenticator(),
      isEnabled: () => enabled,
    );
    addTearDown(cubit.close);

    cubit.enterProtectedArea();
    expect(cubit.state.locked, isFalse);
    expect(cubit.state.pendingLock, isTrue);

    enabled = true;
    cubit.onPreferencesLoaded();
    expect(cubit.state.locked, isTrue);
    expect(cubit.state.pendingLock, isFalse);
  });

  test('locks again after the app is backgrounded', () async {
    final auth = _FakeAppLockAuthenticator(succeed: true);
    final cubit = AppLockCubit(
      authenticator: auth,
      isEnabled: () => true,
    );
    addTearDown(cubit.close);

    cubit.enterProtectedArea();
    await cubit.authenticate(
      reason: 'reason',
      method: AppLockMethod.password,
      password: '1234',
    );
    expect(cubit.state.locked, isFalse);
    expect(auth.lastMethod, AppLockMethod.password);
    expect(auth.lastPassword, '1234');

    cubit.onBackgrounded();
    expect(cubit.state.locked, isTrue);
  });

  test('does not lock login after leaving the main area', () {
    final cubit = AppLockCubit(
      authenticator: _FakeAppLockAuthenticator(),
      isEnabled: () => true,
    );
    addTearDown(cubit.close);

    cubit.enterProtectedArea();
    cubit.exitProtectedArea();
    cubit.onBackgrounded();

    expect(cubit.state.shouldBlock, isFalse);
  });

  test('maps legacy device lock storage to custom password', () {
    expect(AppLockMethod.fromStorage('device'), AppLockMethod.password);
    expect(AppLockMethod.fromStorage('gesture'), AppLockMethod.gesture);
  });

  test('shows face when Android only reports fingerprint hardware', () {
    final resolved = resolveAndroidBiometricAvailability(
      featureFace: false,
      featureFingerprint: true,
      types: const [],
      biometricsEnrolled: true,
    );
    expect(resolved.face, isTrue);
    expect(resolved.fingerprint, isTrue);
  });
}

class _FakeAppLockAuthenticator implements AppLockAuthenticator {
  _FakeAppLockAuthenticator({this.succeed = true});

  final bool succeed;
  AppLockMethod? lastMethod;
  String? lastPassword;
  List<int>? lastGesture;

  @override
  Future<AppLockAvailability> availability({required bool unlocking}) async {
    return AppLockAvailability(
      face: true,
      fingerprint: true,
      password: unlocking,
      gesture: unlocking,
    );
  }

  @override
  Future<void> enrollPassword(String password) async {}

  @override
  Future<void> enrollGesture(List<int> cells) async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<bool> authenticate({
    required String reason,
    required AppLockMethod method,
    String? password,
    List<int>? gesture,
  }) async {
    lastMethod = method;
    lastPassword = password;
    lastGesture = gesture;
    return succeed;
  }
}
