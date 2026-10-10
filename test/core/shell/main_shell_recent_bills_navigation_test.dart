import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/recent_bills_card.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/book_request.dart';
import 'package:fortuneboot/request/group_request.dart';

void main() {
  testWidgets('tapping recent bills view-all switches to the bills tab', (
    tester,
  ) async {
    final originalDashboard = MainShellSlots.dashboard;
    final originalBills = MainShellSlots.bills;
    final originalStats = MainShellSlots.stats;
    final originalProfile = MainShellSlots.profile;
    addTearDown(() {
      MainShellSlots.dashboard = originalDashboard;
      MainShellSlots.bills = originalBills;
      MainShellSlots.stats = originalStats;
      MainShellSlots.profile = originalProfile;
    });

    MainShellSlots.dashboard = (_) => RecentBillsCard(
      section: const DashboardSection<List<FortuneBillVo>>.ready([]),
      currencyCode: null,
      onRetry: () {},
    );
    MainShellSlots.bills = (_) => const Center(child: Text('Bills tab'));
    MainShellSlots.stats = (_) => const SizedBox.shrink();
    MainShellSlots.profile = (_) => const SizedBox.shrink();

    final session = SessionCubit(
      groupService: const _EmptyGroupService(),
      bookService: const _UnusedBookService(),
    );
    final preferences = PreferencesCubit();
    final appLock = AppLockCubit(
      settingsStore: const _FakeAppLockSettingsStore(),
      secretStore: const _FakeAppLockSecretStore(),
      biometricAuthenticator: const _FakeAppLockBiometricAuthenticator(),
    );
    addTearDown(session.close);
    addTearDown(preferences.close);
    addTearDown(appLock.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: session),
          BlocProvider.value(value: preferences),
          BlocProvider.value(value: appLock),
        ],
        child: MaterialApp(
          theme: FxTheme.light,
          locale: const Locale('zh'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const MainShell(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('Bills tab'), findsNothing);

    await tester.tap(find.text('全部'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Bills tab'), findsOneWidget);
  });
}

class _EmptyGroupService implements GroupService {
  const _EmptyGroupService();

  @override
  Future<HJResponse> getEnableList() async =>
      HJResponse(0, 'ok', const <Object>[]);

  @override
  Future<HJResponse> getDefaultGroupId() async => HJResponse(0, 'ok', null);

  @override
  Future<HJResponse> getByGroupId(int groupId) => throw UnimplementedError();
}

class _UnusedBookService implements BookService {
  const _UnusedBookService();

  @override
  Future<HJResponse> getByGroupId(int groupId) => throw UnimplementedError();

  @override
  Future<HJResponse> getEnableList(int id, {int? type}) =>
      throw UnimplementedError();
}

class _FakeAppLockSettingsStore implements AppLockSettingsStore {
  const _FakeAppLockSettingsStore();

  @override
  Future<AppLockSettings?> read() async => null;

  @override
  Future<void> write(AppLockSettings settings) async {}

  @override
  Future<void> clear() async {}
}

class _FakeAppLockSecretStore implements AppLockSecretStore {
  const _FakeAppLockSecretStore();

  @override
  Future<String?> readVerifier() async => null;

  @override
  Future<void> writeVerifier(String value) async {}

  @override
  Future<void> clear() async {}
}

class _FakeAppLockBiometricAuthenticator implements BiometricAuthenticator {
  const _FakeAppLockBiometricAuthenticator();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> isFaceAvailable() async => false;

  @override
  Future<bool> isFingerprintAvailable() async => false;

  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
    AppLockPreferredUnlock? preferredBiometric,
  }) async => BiometricResult.unavailable;
}
