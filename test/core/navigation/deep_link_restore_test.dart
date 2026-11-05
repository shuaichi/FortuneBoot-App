import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_models.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/pending_deep_link.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/book_request.dart';
import 'package:fortuneboot/request/group_request.dart';

void main() {
  setUp(() {
    PendingDeepLink.instance.clear();
    MainShellSlots.dashboard = (_) => const Center(child: Text('Dashboard'));
    MainShellSlots.bills = (_) => const Center(child: Text('Bills'));
    MainShellSlots.stats = (_) => const Center(child: Text('Stats'));
    MainShellSlots.profile = (_) => const Center(child: Text('Profile'));
    AppRouter.register(
      '/s3a/orders',
      (_) => const Scaffold(body: Text('Restored orders')),
    );
    AppRouter.register(
      '/s3a/detail',
      (_) => const Scaffold(body: Text('Detail')),
      requiredDeepLinkKeys: const ['orderId'],
    );
  });

  tearDown(PendingDeepLink.instance.clear);

  testWidgets('restores the deep-link target after the session is ready', (
    tester,
  ) async {
    PendingDeepLink.instance.capture('/s3a/orders');
    await _pumpShell(tester);

    expect(find.text('Restored orders'), findsOneWidget);
    expect(PendingDeepLink.instance.peek(), isNull);
  });

  testWidgets('keeps a tab deep link as a tab selection', (tester) async {
    PendingDeepLink.instance.capture('/stats');
    await _pumpShell(tester);

    expect(find.text('Stats'), findsOneWidget);
    expect(PendingDeepLink.instance.peek(), isNull);
  });

  testWidgets('incomplete detail link provides an explicit way back', (
    tester,
  ) async {
    PendingDeepLink.instance.capture('/s3a/detail');
    await _pumpShell(tester);

    expect(find.text('无法打开此页面'), findsOneWidget);
    expect(find.text('链接缺少打开该页面所需的参数或对象信息。'), findsOneWidget);
    await tester.tap(find.text('返回首页'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('unknown deep link explains the target instead of a blank page', (
    tester,
  ) async {
    PendingDeepLink.instance.capture('/s3a/missing');
    await _pumpShell(tester);

    expect(find.text('无法打开此页面'), findsOneWidget);
    expect(find.text('链接指向的页面不存在或已失效。'), findsOneWidget);
  });

  testWidgets('waits for session restoration before opening the target', (
    tester,
  ) async {
    final groups = _DelayedGroupService();
    PendingDeepLink.instance.capture('/s3a/orders');
    await _pumpShell(tester, groupService: groups, settle: false);

    await tester.pump();
    expect(find.text('Restored orders'), findsNothing);

    groups.release();
    await tester.pumpAndSettle();
    expect(find.text('Restored orders'), findsOneWidget);
  });
}

Future<void> _pumpShell(
  WidgetTester tester, {
  GroupService? groupService,
  bool settle = true,
}) async {
  final session = SessionCubit(
    groupService: groupService ?? const _ReadyGroupService(),
    bookService: const _ReadyBookService(),
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
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

class _ReadyGroupService implements GroupService {
  const _ReadyGroupService();

  @override
  Future<HJResponse> getEnableList() async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'groupId': 1,
      'groupName': 'Group 1',
      'defaultCurrency': 'CNY',
      'roleType': 1,
      'defaultBookId': 11,
    },
  ]);

  @override
  Future<HJResponse> getDefaultGroupId() async => HJResponse(0, 'ok', 1);

  @override
  Future<HJResponse> getByGroupId(int groupId) async =>
      HJResponse(0, 'ok', <String, dynamic>{
        'groupId': 1,
        'groupName': 'Group 1',
        'defaultCurrency': 'CNY',
        'defaultBookId': 11,
      });
}

class _DelayedGroupService extends _ReadyGroupService {
  final _ready = Completer<void>();

  void release() => _ready.complete();

  @override
  Future<HJResponse> getEnableList() async {
    await _ready.future;
    return super.getEnableList();
  }
}

class _ReadyBookService implements BookService {
  const _ReadyBookService();

  @override
  Future<HJResponse> getByGroupId(int groupId) async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'bookId': 11,
      'groupId': 1,
      'bookName': 'Book 11',
      'defaultCurrency': 'CNY',
    },
  ]);

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
