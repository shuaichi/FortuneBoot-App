import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/view/auth_flow_form.dart';
import 'package:fortuneboot/login/view/auth_scaffold.dart';

void main() {
  testWidgets('successful sign-in submits trimmed credentials and continues', (
    tester,
  ) async {
    LoginData? submitted;
    var continued = false;
    await _pumpForm(
      tester,
      onLogin: (data) async {
        submitted = data;
        return null;
      },
      onLoginSuccess: () async => continued = true,
    );

    await tester.enterText(find.byType(TextFormField).at(0), '  demo-user  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'Abcdef12');
    await tester.tap(find.widgetWithText(FxButton, '登录'));
    await tester.pump();
    await tester.pump();

    expect(submitted?.name, 'demo-user');
    expect(submitted?.password, 'Abcdef12');
    expect(continued, isTrue);
  });

  testWidgets('failed sign-in shows the service error without continuing', (
    tester,
  ) async {
    var continued = false;
    await _pumpForm(
      tester,
      onLogin: (_) async => '服务不可用',
      onLoginSuccess: () async => continued = true,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'demo-user');
    await tester.enterText(find.byType(TextFormField).at(1), 'Abcdef12');
    await tester.tap(find.widgetWithText(FxButton, '登录'));
    await tester.pump();
    await tester.pump();

    expect(find.text('服务不可用'), findsOneWidget);
    expect(continued, isFalse);
  });

  testWidgets('thrown sign-in failures recover to a visible error state', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      onLogin: (_) async => throw StateError('socket closed'),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'demo-user');
    await tester.enterText(find.byType(TextFormField).at(1), 'Abcdef12');
    await tester.tap(find.widgetWithText(FxButton, '登录'));
    await tester.pump();
    await tester.pump();

    expect(find.text('敬请期待'), findsOneWidget);
    expect(
      tester.widget<FxButton>(find.widgetWithText(FxButton, '登录')).loading,
      isFalse,
    );
  });

  testWidgets('sign-up enforces terms and submits the assembled account data', (
    tester,
  ) async {
    SignupData? submitted;
    var usernameChecks = 0;
    await _pumpForm(
      tester,
      onCheckUsername: (_) async {
        usernameChecks++;
        return null;
      },
      onSignup: (data) async {
        submitted = data;
        return null;
      },
      additionalSignupFields: const [
        UserFormField(keyName: 'nickname', displayName: '昵称'),
      ],
    );

    await tester.tap(find.text('注册'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), 'demo-user');
    await tester.enterText(find.byType(TextFormField).at(1), 'Abcdef12');
    await tester.enterText(find.byType(TextFormField).at(2), 'Abcdef12');
    await tester.enterText(find.byType(TextFormField).at(3), '演示用户');

    await tester.tap(find.widgetWithText(FxButton, '注册'));
    await tester.pump();
    expect(find.text('同意以继续'), findsOneWidget);
    expect(usernameChecks, 0);
    expect(submitted, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(FxButton, '注册'));
    await tester.pump();
    await tester.pump();

    expect(usernameChecks, 1);
    expect(submitted?.name, 'demo-user');
    expect(submitted?.password, 'Abcdef12');
    expect(submitted?.additionalSignupData?['nickname'], '演示用户');
    expect(find.text('注册成功'), findsOneWidget);
  });

  testWidgets('narrow screens keep the secondary actions inside the form', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      surfaceSize: const Size(320, 640),
      pageBuilder: (form) => AuthScaffold(
        title: '好记',
        subtitle: 'demo.fortuneboot.com',
        child: form,
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('你不会忘了密码吧？点我'), findsOneWidget);
    expect(find.text('注册'), findsOneWidget);

    final forgotRect = tester.getRect(
      find.widgetWithText(FxButton, '你不会忘了密码吧？点我'),
    );
    final registerRect = tester.getRect(find.widgetWithText(FxButton, '注册'));
    expect(forgotRect.top, registerRect.top);
    expect(forgotRect.left, greaterThanOrEqualTo(0));
    expect(registerRect.right, lessThanOrEqualTo(320));
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  Future<String?> Function(LoginData data)? onLogin,
  Future<String?> Function(SignupData data)? onSignup,
  Future<String?> Function(String account)? onRecoverPassword,
  Future<String?> Function(String account)? onCheckUsername,
  Future<void> Function()? onLoginSuccess,
  List<UserFormField> additionalSignupFields = const [],
  Size? surfaceSize,
  Widget Function(Widget form)? pageBuilder,
}) {
  if (surfaceSize != null) {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final form = AuthFlowForm(
    additionalSignupFields: additionalSignupFields,
    onLogin: onLogin ?? (_) async => null,
    onSignup: onSignup ?? (_) async => null,
    onRecoverPassword: onRecoverPassword ?? (_) async => null,
    onCheckUsername: onCheckUsername ?? (_) async => null,
    onLoginSuccess: onLoginSuccess ?? () async {},
  );
  return tester.pumpWidget(
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
      home:
          pageBuilder?.call(form) ??
          Scaffold(body: SingleChildScrollView(child: form)),
    ),
  );
}
