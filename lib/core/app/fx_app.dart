import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fortuneboot/core/navigation/app_nav.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/view/base_url_config_page.dart';
import 'package:fortuneboot/login/view/login_screen.dart';
import 'package:fortuneboot/util/dio_client.dart';

/// 新应用根：挂全局 SessionCubit、FxTheme、集中路由。
/// 登录三页保留在 routes 表；MainShell 及后续新页面走 AppRouter.onGenerateRoute。
class FxApp extends StatelessWidget {
  const FxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>(
      create: (_) => SessionCubit(),
      child: const _FxAppView(),
    );
  }
}

class _FxAppView extends StatelessWidget {
  const _FxAppView();

  @override
  Widget build(BuildContext context) {
    DioClient().onAuthExpired = () {
      // 会话过期：重置会话状态并回登录。
      final ctx = appNavigatorKey.currentContext;
      if (ctx != null) {
        ctx.read<SessionCubit>().reset();
      }
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        Routes.auth,
        (route) => false,
      );
    };

    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          title: '好记',
          debugShowCheckedModeBanner: false,
          theme: FxTheme.light,
          themeMode: ThemeMode.light,
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          initialRoute: BaseUrlConfigPage.routeName,
          routes: {
            BaseUrlConfigPage.routeName: (context) => const BaseUrlConfigPage(),
            LoginScreen.routeName: (context) => const LoginScreen(),
            Routes.main: (context) => const MainShell(),
          },
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}

/// 运行时 locale 持有者（Profile 语言切换用）。
class AppLocale {
  static Locale? value = const Locale('zh', 'CN');
  static final ValueNotifier<Locale?> notifier = ValueNotifier(value);

  static void set(Locale? l) {
    value = l;
    notifier.value = l;
  }
}
