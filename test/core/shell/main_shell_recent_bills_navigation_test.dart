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
    // 空会话没有可写账本，不显示 FAB，也不再重复预留导航高度。
    expect(shellInsets.bottom, 24);

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

  testWidgets('quick add stays available on stats with one FAB inset', (
    tester,
  ) async {
    _useSlots(statsBody: const Center(child: Text('Stats tab')));
    await _pumpShell(tester, session: _readySession());

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(_shellInset(tester), 88);

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();

    expect(find.text('Stats tab'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(_shellInset(tester), 88);
    expect(find.text('Book 11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visitor sees read-only scope and no quick add action', (
    tester,
  ) async {
    _useSlots();
    await _pumpShell(tester, session: _readySession(roleType: 3));

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('只读'), findsOneWidget);
    expect(_shellInset(tester), 24);
  });

  testWidgets(
    'keyboard hides quick add and does not add another bottom inset',
    (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      _useSlots();
      await _pumpShell(tester, session: _readySession());

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(_shellInset(tester), 24);
    },
  );

  testWidgets('large labels keep four nav items readable and selected', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    _useSlots();
    await _pumpShell(
      tester,
      session: _readySession(bookName: '家庭共同生活与长期储蓄账本 2026 年度'),
      textScale: 2,
    );

    expect(find.text('仪表盘'), findsOneWidget);
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    final navItem = find.ancestor(
      of: find.text('仪表盘'),
      matching: find.byType(InkWell),
    );
    expect(navItem, findsWidgets);
    expect(tester.getSize(navItem.first).height, greaterThan(64));
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('仪表盘')),
      isSemantics(isButton: true, isSelected: true, label: '仪表盘'),
    );
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('scope strip opens the switcher from a secondary tab', (
    tester,
  ) async {
    _useSlots();
    await _pumpShell(tester, session: _readySession());

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book 11'));
    await tester.pumpAndSettle();

    expect(find.text('分组与账本'), findsWidgets);
    expect(find.text('Group 1'), findsWidgets);
  });

  testWidgets('last list action stays tappable above nav and FAB', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    _useSlots(billsBody: const _TailProbe());
    await _pumpShell(tester, session: _readySession());

    await tester.tap(find.text('账单'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -4000));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tail-action')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tail-action')));
    await tester.pump();
    expect(find.text('tail-action-tapped'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape keeps the tail action reachable', (tester) async {
    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    _useSlots(billsBody: const _TailProbe());
    await _pumpShell(tester, session: _readySession(), textScale: 2);

    await tester.tap(find.text('账单'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tail-action')));
    await tester.pump();
    expect(find.text('tail-action-tapped'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide rail stays usable with 2x text', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    _useSlots();
    await _pumpShell(tester, session: _readySession(), textScale: 2);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('仪表盘'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

void _useSlots({Widget? statsBody, Widget? billsBody}) {
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
  MainShellSlots.bills = (_) => billsBody ?? const SizedBox.shrink();
  MainShellSlots.stats = (_) => statsBody ?? const SizedBox.shrink();
  MainShellSlots.profile = (_) => const SizedBox.shrink();
}

SessionCubit _readySession({int roleType = 1, String bookName = 'Book 11'}) {
  final session = SessionCubit(
    groupService: _ReadyGroupService(roleType: roleType),
    bookService: _ReadyBookService(bookName: bookName),
  );
  addTearDown(session.close);
  return session;
}

Future<void> _pumpShell(
  WidgetTester tester, {
  required SessionCubit session,
  double textScale = 1,
}) async {
  final preferences = PreferencesCubit();
  final appLock = AppLockCubit(
    settingsStore: const _FakeAppLockSettingsStore(),
    secretStore: const _FakeAppLockSecretStore(),
    biometricAuthenticator: const _FakeAppLockBiometricAuthenticator(),
  );
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        ),
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
  await tester.pumpAndSettle();
}

double _shellInset(WidgetTester tester) =>
    tester.widget<ShellContentInsets>(find.byType(ShellContentInsets)).bottom;

class _TailProbe extends StatefulWidget {
  const _TailProbe();

  @override
  State<_TailProbe> createState() => _TailProbeState();
}

class _TailProbeState extends State<_TailProbe> {
  var _tapped = false;

  @override
  Widget build(BuildContext context) {
    final bottom = ShellContentInsets.bottomOf(context);
    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottom),
      itemCount: 31,
      itemBuilder: (context, index) {
        if (index == 30) {
          return Center(
            child: TextButton(
              key: const Key('tail-action'),
              onPressed: () => setState(() => _tapped = true),
              child: Text(_tapped ? 'tail-action-tapped' : 'tail-action'),
            ),
          );
        }
        return SizedBox(height: 56, child: Center(child: Text('Row $index')));
      },
    );
  }
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

class _ReadyGroupService implements GroupService {
  const _ReadyGroupService({this.roleType = 1});

  final int roleType;

  @override
  Future<HJResponse> getEnableList() async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'groupId': 1,
      'groupName': 'Group 1',
      'defaultCurrency': 'CNY',
      'roleType': roleType,
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

class _ReadyBookService implements BookService {
  const _ReadyBookService({required this.bookName});

  final String bookName;

  @override
  Future<HJResponse> getByGroupId(int groupId) async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'bookId': 11,
      'groupId': 1,
      'bookName': bookName,
      'defaultCurrency': 'CNY',
    },
  ]);

  @override
  Future<HJResponse> getEnableList(int id, {int? type}) =>
      throw UnimplementedError();
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
