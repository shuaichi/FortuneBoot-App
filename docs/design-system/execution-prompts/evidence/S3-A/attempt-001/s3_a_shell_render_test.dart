import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/book_request.dart';
import 'package:fortuneboot/request/group_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDir =
      'docs/design-system/execution-prompts/evidence/S3-A/attempt-001';

  setUpAll(() async {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final entry in {
      'PreviewCJK': '/System/Library/Fonts/Hiragino Sans GB.ttc',
      'PreviewSystem': '/System/Library/Fonts/SFNS.ttf',
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(
        File(entry.value).readAsBytes().then(ByteData.sublistView),
      );
      await loader.load();
    }
  });

  setUp(() {
    PendingDeepLink.instance.clear();
    MainShellSlots.dashboard = (context) {
      return const _TabStub(title: '仪表盘', detail: '本月概览 / 最近账单');
    };
    MainShellSlots.bills = (_) =>
        const _TabStub(title: '账单', detail: '账期 / 收支摘要 / 连续账单列表');
    MainShellSlots.stats = (_) =>
        const _TabStub(title: '统计', detail: '范围 / 趋势 / 分类与标签');
    MainShellSlots.profile = (_) =>
        const _TabStub(title: '我的', detail: '账本与分组 / 偏好 / 帮助');
  });

  tearDown(PendingDeepLink.instance.clear);

  final cases = <_Case>[
    const _Case(
      name: 'shell-light-390-1x-bills',
      size: Size(390, 900),
      theme: Brightness.light,
      tab: '账单',
    ),
    const _Case(
      name: 'shell-light-390-1x-dashboard',
      size: Size(390, 900),
      theme: Brightness.light,
      tab: '仪表盘',
    ),
    const _Case(
      name: 'shell-light-390-1x-stats',
      size: Size(390, 900),
      theme: Brightness.light,
      tab: '统计',
    ),
    const _Case(
      name: 'shell-dark-390-1x-profile',
      size: Size(390, 900),
      theme: Brightness.dark,
      tab: '我的',
    ),
    const _Case(
      name: 'shell-light-320-1x-bills',
      size: Size(320, 900),
      theme: Brightness.light,
      tab: '账单',
    ),
    const _Case(
      name: 'shell-light-320-2x-bills',
      size: Size(320, 1100),
      theme: Brightness.light,
      tab: '账单',
      textScale: 2,
    ),
    const _Case(
      name: 'shell-dark-440-2x-bills',
      size: Size(440, 1200),
      theme: Brightness.dark,
      tab: '账单',
      textScale: 2,
    ),
    const _Case(
      name: 'shell-light-390-1x-visitor',
      size: Size(390, 900),
      theme: Brightness.light,
      tab: '仪表盘',
      visitor: true,
    ),
    const _Case(
      name: 'shell-dark-390-1x-nobook',
      size: Size(390, 900),
      theme: Brightness.dark,
      tab: '账单',
      noBook: true,
    ),
    const _Case(
      name: 'shell-light-390-1x-deeplink-failure',
      size: Size(390, 900),
      theme: Brightness.light,
      tab: '仪表盘',
      deepLinkFailure: true,
    ),
    const _Case(
      name: 'shell-light-640-320-2x-landscape',
      size: Size(640, 320),
      theme: Brightness.light,
      tab: '账单',
      textScale: 2,
    ),
    const _Case(
      name: 'shell-dark-390-1x-keyboard',
      size: Size(390, 900),
      theme: Brightness.dark,
      tab: '账单',
      keyboard: true,
    ),
  ];

  for (final item in cases) {
    testWidgets('render ${item.name}', (tester) async {
      tester.view.physicalSize = item.size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      if (item.keyboard) {
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      }
      addTearDown(tester.view.reset);

      if (item.deepLinkFailure) {
        AppRouter.register(
          '/s3a/detail',
          (_) => const SizedBox.shrink(),
          requiredDeepLinkKeys: const ['orderId'],
        );
        PendingDeepLink.instance.capture('/s3a/detail');
      }

      final session = SessionCubit(
        groupService: _RenderGroupService(visitor: item.visitor),
        bookService: _RenderBookService(noBook: item.noBook),
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
      await session.load();

      final boundaryKey = GlobalKey();
      var theme = item.theme == Brightness.light ? FxTheme.light : FxTheme.dark;
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(
          fontFamily: 'PreviewSystem',
          fontFamilyFallback: const ['PreviewCJK'],
        ),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: session),
              BlocProvider<PreferencesCubit>.value(value: preferences),
              BlocProvider<AppLockCubit>.value(value: appLock),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              locale: const Locale('zh'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(item.textScale)),
                child: child ?? const SizedBox.shrink(),
              ),
              home: const MainShell(),
              onGenerateRoute: AppRouter.onGenerateRoute,
              onUnknownRoute: AppRouter.onUnknownRoute,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      if (item.tab != '仪表盘') {
        await tester.tap(find.text(item.tab).first);
        await tester.pump(const Duration(milliseconds: 200));
      }
      if (item.deepLinkFailure) {
        await tester.pump(const Duration(milliseconds: 400));
      }
      await tester.pump(const Duration(milliseconds: 80));

      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '$outputDir/${item.name}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    });
  }
}

class _Case {
  const _Case({
    required this.name,
    required this.size,
    required this.theme,
    required this.tab,
    this.textScale = 1,
    this.visitor = false,
    this.noBook = false,
    this.deepLinkFailure = false,
    this.keyboard = false,
  });

  final String name;
  final Size size;
  final Brightness theme;
  final String tab;
  final double textScale;
  final bool visitor;
  final bool noBook;
  final bool deepLinkFailure;
  final bool keyboard;
}

class _TabStub extends StatelessWidget {
  const _TabStub({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return ColoredBox(
      color: palette.canvas,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            FxSpacing.xl,
            FxSpacing.sm,
            FxSpacing.xl,
            ShellContentInsets.bottomOf(context),
          ),
          children: [
            Text(title, style: FxTypography.titleLarge),
            const SizedBox(height: FxSpacing.md),
            FxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail, style: FxTypography.body),
                  const SizedBox(height: FxSpacing.sm),
                  Text(
                    'MainShell render fixture · tab content slot',
                    style: FxTypography.caption.copyWith(
                      color: palette.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RenderGroupService implements GroupService {
  const _RenderGroupService({this.visitor = false});

  final bool visitor;

  @override
  Future<HJResponse> getEnableList() async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'groupId': 1,
      'groupName': '家庭共同生活分组',
      'defaultCurrency': 'CNY',
      'roleType': visitor ? 3 : 1,
      'defaultBookId': 11,
    },
  ]);

  @override
  Future<HJResponse> getDefaultGroupId() async => HJResponse(0, 'ok', 1);

  @override
  Future<HJResponse> getByGroupId(int groupId) async =>
      HJResponse(0, 'ok', <String, dynamic>{
        'groupId': 1,
        'groupName': '家庭共同生活分组',
        'defaultCurrency': 'CNY',
        'defaultBookId': 11,
      });
}

class _RenderBookService implements BookService {
  const _RenderBookService({this.noBook = false});

  final bool noBook;

  @override
  Future<HJResponse> getByGroupId(int groupId) async => HJResponse(
    0,
    'ok',
    noBook
        ? <Map<String, dynamic>>[]
        : [
            <String, dynamic>{
              'bookId': 11,
              'groupId': 1,
              'bookName': '家庭共同生活与长期储蓄账本 2026 年度',
              'defaultCurrency': 'CNY',
            },
          ],
  );

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
