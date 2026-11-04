import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/view/auth_scaffold.dart';
import 'package:fortuneboot/login/view/base_url_config_page.dart';
import 'package:fortuneboot/login/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('base URL page follows the active surface and platform physics', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });
    final preferences = PreferencesCubit();
    addTearDown(preferences.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: preferences,
        child: MaterialApp(
          theme: FxTheme.light,
          darkTheme: FxTheme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('zh'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const BaseUrlConfigPage(),
        ),
      ),
    );
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, FxPalette.dark.surface);
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollView.physics, isNot(isA<BouncingScrollPhysics>()));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('desktop startup uses the same quiet single-column auth frame', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const AuthScaffold(
          title: '服务器配置',
          subtitle: '',
          child: SizedBox(
            key: ValueKey('startup-form'),
            width: double.infinity,
            height: 56,
          ),
        ),
      ),
    );

    final titleRect = tester.getRect(find.text('服务器配置'));
    final formRect = tester.getRect(find.byKey(const ValueKey('startup-form')));
    expect(titleRect.left, closeTo(formRect.left, 0.01));
    expect(formRect.width, lessThanOrEqualTo(400));
    expect(find.text('FORTUNEBOOT'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login no longer delegates its presentation to FlutterLogin', (
    tester,
  ) async {
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
        home: const LoginScreen(),
      ),
    );
    await tester.pump();

    expect(find.byType(FlutterLogin), findsNothing);
    expect(find.text('账号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
  });
}
