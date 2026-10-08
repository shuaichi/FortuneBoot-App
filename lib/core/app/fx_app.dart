import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fortuneboot/core/app/main_version_gate.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/app_lock/app_lock_gate.dart';
import 'package:fortuneboot/core/app_lock/app_lock_stores.dart';
import 'package:fortuneboot/core/desktop_widget/ohos_desktop_widget.dart';
import 'package:fortuneboot/core/navigation/app_nav.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/view/auth_version_gate.dart';
import 'package:fortuneboot/login/view/base_url_config_page.dart';
import 'package:fortuneboot/util/dio_client.dart';

/// 新应用根：挂全局 SessionCubit、FxTheme、集中路由。
/// 登录三页保留在 routes 表；MainShell 及后续新页面走 AppRouter.onGenerateRoute。
class FxApp extends StatelessWidget {
  const FxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appLockDependencies = AppLockPlatformDependencies.create();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(create: (_) => SessionCubit()),
        BlocProvider<PreferencesCubit>(
          create: (_) => PreferencesCubit()..load(),
        ),
        BlocProvider<AppLockCubit>(
          create: (_) => AppLockCubit(
            settingsStore: SharedPreferencesAppLockSettingsStore(),
            secretStore: appLockDependencies.secretStore,
            biometricAuthenticator: appLockDependencies.biometricAuthenticator,
          )..initialize(),
        ),
      ],
      child: const _FxAppView(),
    );
  }
}

class _FxAppView extends StatefulWidget {
  const _FxAppView();

  @override
  State<_FxAppView> createState() => _FxAppViewState();
}

class _FxAppViewState extends State<_FxAppView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    OhosDesktopWidget.bindMonthChangedHandler(_syncDesktopWidget);
  }

  void _syncDesktopWidget() {
    if (!mounted) return;
    final session = context.read<SessionCubit>().state;
    final bookId = session.currentBookId;
    if (bookId == null) return;
    unawaited(
      OhosDesktopWidget.syncAll(
        bookId: bookId,
        groupId: session.currentGroupId,
        currencyCode: session.defaultCurrency,
        hideAmounts: context.read<PreferencesCubit>().state.dashboard.hideAmounts,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<AppLockCubit>().onAppResumed());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(context.read<AppLockCubit>().onAppBecameInactive());
    }
    if (state == AppLifecycleState.resumed) {
      _syncDesktopWidget();
      if (context.read<SessionCubit>().state.currentBookId == null) {
        unawaited(OhosDesktopWidget.publishNow());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DioClient().onAuthExpired = () {
      // 会话过期：重置会话状态并回登录。
      final ctx = appNavigatorKey.currentContext;
      if (ctx != null) {
        ctx.read<SessionCubit>().reset();
        ctx.read<AppLockCubit>().onSignedOut();
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
          onGenerateTitle: (context) => S.of(context).appTitle,
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
            Routes.auth: (context) => const AuthVersionGate(),
            Routes.main: (context) => const MainVersionGate(),
          },
          builder: (context, child) =>
              AppLockGate(child: child ?? const SizedBox.shrink()),
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
