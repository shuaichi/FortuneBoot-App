import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fortuneboot/login/view/base_url_config_page.dart';
import 'package:fortuneboot/repository/repository/bills_repository.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/view/login_screen.dart';
import 'package:fortuneboot/home/theme/theme.dart';

class App extends StatelessWidget {
  const App(
      {required this.createBillsRepository,
      super.key});

  final BillsRepository Function() createBillsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BillsRepository>(
          create: (_) => createBillsRepository(),
          dispose: (repository) => repository.dispose(),
        )
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const AppView({super.key});
  @override
  Widget build(BuildContext context) {
    log('lxjtodo ${S.delegate.supportedLocales}');
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: FlutterTodosTheme.light,
      darkTheme: FlutterTodosTheme.dark,
      themeMode: ThemeMode.light,
      locale: const Locale('zh', 'CN'),
    localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // 提供 Material 组件本地化资源
        GlobalWidgetsLocalizations.delegate, // 支持文本方向（如阿拉伯语右对齐）
        GlobalCupertinoLocalizations.delegate,
        S.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      // home: const HomePage(),
      initialRoute: BaseUrlConfigPage.routeName,
      routes: {
        BaseUrlConfigPage.routeName: (context) => const BaseUrlConfigPage(),
        LoginScreen.routeName: (context) => const LoginScreen(),
      },
    );
  }
}
