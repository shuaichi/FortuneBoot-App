import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/view/auth_page.dart';

void main() {
  testWidgets('legacy sign-in password reaches the request untouched', (
    tester,
  ) async {
    LoginData? submitted;
    var continued = false;
    await _pumpAuth(
      tester,
      onLogin: (data) async {
        submitted = data;
        return null;
      },
      onLoginSuccess: () async => continued = true,
    );

    await tester.enterText(find.byType(TextFormField).at(0), ' legacy ');
    await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(submitted?.name, 'legacy');
    expect(submitted?.password, 'abc123');
    expect(continued, isTrue);
    expect(find.text(AuthCopy.zh.passwordPolicy), findsNothing);
  });

  testWidgets(
    'account field disables username autocorrection and suggestions',
    (tester) async {
      await _pumpAuth(tester);

      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.textCapitalization, TextCapitalization.none);
    },
  );

  testWidgets('primary and secondary actions keep native tap targets', (
    tester,
  ) async {
    await _pumpAuth(tester);

    expect(
      tester.getSize(find.widgetWithText(FilledButton, '登录')).height,
      greaterThanOrEqualTo(50),
    );
    expect(
      tester.getSize(find.widgetWithText(TextButton, '忘记密码')).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSize(find.byType(IconButton)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('forgot password is hidden when no recover handler exists', (
    tester,
  ) async {
    await _pumpAuth(tester, enableRecover: false);

    expect(find.text('忘记密码'), findsNothing);
  });

  testWidgets('consent label stays beside the checkbox and view is separate', (
    tester,
  ) async {
    var termsOpened = 0;
    await _pumpAuth(tester, onOpenTerms: () async => termsOpened++);
    await tester.tap(find.text('创建账户'));
    await tester.pumpAndSettle();

    final checkboxRect = tester.getRect(find.byType(Checkbox));
    final labelRect = tester.getRect(find.text('我已阅读并同意服务条款'));
    expect(labelRect.left - checkboxRect.right, lessThan(24));

    await tester.tap(find.text('查看'));
    await tester.pump();
    expect(termsOpened, 1);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.text('我已阅读并同意服务条款'));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('mode change returns the long sign-up form to the top', (
    tester,
  ) async {
    await _pumpAuth(
      tester,
      surfaceSize: const Size(320, 640),
      additionalSignupFields: _signupFields,
    );
    await tester.tap(find.text('创建账户'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('返回登录'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('返回登录'));
    await tester.pumpAndSettle();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('auth-scroll')),
    );
    expect(scrollView.controller?.offset, 0);
    expect(find.text('登录'), findsWidgets);
  });

  testWidgets('long sign-up form survives 2x text at 320 width', (
    tester,
  ) async {
    await _pumpAuth(
      tester,
      surfaceSize: const Size(320, 640),
      textScale: 2,
      additionalSignupFields: _signupFields,
    );
    await tester.scrollUntilVisible(
      find.text('创建账户'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('创建账户'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, '创建账户'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop sign-in is one column, not a split hero', (
    tester,
  ) async {
    await _pumpAuth(tester, surfaceSize: const Size(1440, 900));

    final titleRect = tester.getRect(find.text('登录').first);
    final fieldRect = tester.getRect(find.byType(TextFormField).first);
    expect((titleRect.left - fieldRect.left).abs(), lessThan(1));
  });

  testWidgets('server label is the real injected value', (tester) async {
    await _pumpAuth(tester, serverLabel: 'fin.example.com');

    expect(find.text('fin.example.com'), findsOneWidget);
    expect(find.text('demo.fortuneboot.com'), findsNothing);
  });
}

const _signupFields = [
  UserFormField(keyName: 'nickname', displayName: '昵称'),
  UserFormField(keyName: 'sex', displayName: '性别', defaultValue: '男'),
  UserFormField(
    keyName: 'email',
    displayName: '邮箱',
    userType: LoginUserType.email,
  ),
  UserFormField(
    keyName: 'phone_number',
    displayName: '手机号',
    userType: LoginUserType.phone,
  ),
];

Future<void> _pumpAuth(
  WidgetTester tester, {
  Future<String?> Function(LoginData data)? onLogin,
  Future<String?> Function(SignupData data)? onSignup,
  Future<String?> Function(String account)? onRecoverPassword,
  Future<String?> Function(String account)? onCheckUsername,
  Future<void> Function()? onLoginSuccess,
  Future<void> Function()? onOpenTerms,
  List<UserFormField> additionalSignupFields = const [],
  bool enableRecover = true,
  String? serverLabel,
  Size surfaceSize = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: FxTheme.light,
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
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: AuthPage(
        copy: AuthCopy.zh,
        serverLabel: serverLabel,
        additionalSignupFields: additionalSignupFields,
        onLogin: onLogin ?? (_) async => null,
        onSignup: onSignup ?? (_) async => null,
        onRecoverPassword: enableRecover
            ? (onRecoverPassword ?? (_) async => null)
            : null,
        onCheckUsername: onCheckUsername ?? (_) async => null,
        onLoginSuccess: onLoginSuccess ?? () async {},
        onOpenTerms: onOpenTerms,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
