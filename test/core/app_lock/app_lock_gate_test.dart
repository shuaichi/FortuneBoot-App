import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_gate.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('renders localized locked screen text in English', (
    tester,
  ) async {
    final cubit = await _lockedCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(cubit, const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('FortuneBoot is locked'), findsOneWidget);
    expect(find.text('Enter your PIN to continue'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
    expect(find.text('6–12 digit PIN'), findsOneWidget);
  });

  testWidgets('shows localized credential failures in Chinese', (tester) async {
    final cubit = await _lockedCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_app(cubit, const Locale('zh')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('解锁'));
    await tester.pumpAndSettle();

    expect(find.text('验证失败，请重试'), findsOneWidget);
  });
}

Future<AppLockCubit> _lockedCubit() async {
  final cubit = AppLockCubit(
    settingsStore: const _SettingsStore(
      AppLockSettings(method: AppLockMethod.pin),
    ),
    secretStore: _SecretStore(),
    biometricAuthenticator: _BiometricAuthenticator(),
  );
  await cubit.initialize();
  await cubit.onAuthenticated();
  return cubit;
}

Widget _app(AppLockCubit cubit, Locale locale) {
  return BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: FxTheme.light,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: AppLockGate(child: const Scaffold(body: Text('Protected content'))),
    ),
  );
}

class _SettingsStore implements AppLockSettingsStore {
  const _SettingsStore(this.settings);

  final AppLockSettings settings;

  @override
  Future<void> clear() async {}

  @override
  Future<AppLockSettings?> read() async => settings;

  @override
  Future<void> write(AppLockSettings settings) async {}
}

class _SecretStore implements AppLockSecretStore {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readVerifier() async => 'pin:00:00';

  @override
  Future<void> writeVerifier(String value) async {}
}

class _BiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
    AppLockPreferredUnlock? preferredBiometric,
  }) async => BiometricResult.cancelled;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> isFaceAvailable() async => false;

  @override
  Future<bool> isFingerprintAvailable() async => false;
}
