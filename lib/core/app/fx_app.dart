import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fortuneboot/core/navigation/app_nav.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(create: (_) => SessionCubit()),
        BlocProvider<PreferencesCubit>(
          create: (_) => PreferencesCubit()..load(),
        ),
      ],
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

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        final financeColors = FxFinanceColors.fromPreferences(
          prefs.financeColors,
        );
        // 保持 AppLocale 兼容旧引用，但事实来源为偏好中心。
        final locale = prefs.locale.locale;
        AppLocale.value = locale;
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          title: '好记',
          debugShowCheckedModeBanner: false,
          theme: FxTheme.buildLight(financeColors: financeColors),
          darkTheme: FxTheme.buildDark(financeColors: financeColors),
          themeMode: prefs.theme.mode,
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

/// 运行时 locale 只读镜像（兼容旧引用）。真正的语言偏好由 PreferencesCubit 管理，
/// 通过 `context.read<PreferencesCubit>().setLocaleCode(...)` 切换。
class AppLocale {
  static Locale? value = const Locale('zh', 'CN');
}
