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
    final shellInsets = tester.widget<ShellContentInsets>(
      find.byType(ShellContentInsets),
    );
    expect(shellInsets.bottom, 144);

    await tester.tap(find.text('全部'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Bills tab'), findsOneWidget);
  });

  testWidgets('wide layout uses sidebar navigation and bounded content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    MainShellSlots.dashboard = (_) => const Center(child: Text('Dashboard'));
    MainShellSlots.bills = (_) => const Center(child: Text('Bills tab'));
    MainShellSlots.stats = (_) => const SizedBox.shrink();
    MainShellSlots.profile = (_) => const SizedBox.shrink();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: SessionCubit(
              groupService: const _EmptyGroupService(),
              bookService: const _UnusedBookService(),
            ),
          ),
          BlocProvider.value(value: PreferencesCubit()),
          BlocProvider.value(
            value: AppLockCubit(
              settingsStore: const _FakeAppLockSettingsStore(),
              secretStore: const _FakeAppLockSecretStore(),
              biometricAuthenticator:
                  const _FakeAppLockBiometricAuthenticator(),
            ),
          ),
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

    expect(MediaQuery.widthOf(tester.element(find.byType(MainShell))), 1280);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomAppBar), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox && widget.constraints.maxWidth == 1120,
      ),
      findsOneWidget,
    );
  });

  testWidgets('stats tab hides quick add and releases its content inset', (
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

    MainShellSlots.dashboard = (_) => const SizedBox.shrink();
    MainShellSlots.bills = (_) => const SizedBox.shrink();
    MainShellSlots.stats = (_) => const Center(child: Text('Stats tab'));
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

    final dashboardInset = tester
        .widget<ShellContentInsets>(find.byType(ShellContentInsets))
        .bottom;
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();

    final statsInset = tester
        .widget<ShellContentInsets>(find.byType(ShellContentInsets))
        .bottom;
    expect(find.text('Stats tab'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(statsInset, lessThan(dashboardInset));
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
