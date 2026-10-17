import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/navigation/startup_route_guard.dart';
import 'package:fortuneboot/login/view/base_url_config_page.dart';

void main() {
  // 模拟 Web 刷新深链：浏览器 URL 路径覆盖 MaterialApp.initialRoute，
  // 使功能页成为 Navigator 根路由。
  Widget buildApp(
    GlobalKey<NavigatorState> navigatorKey,
    NavigatorObserver observer, {
    required String initialRoute,
  }) {
    AppRouter.register(
      Routes.orders,
      (args) => const Scaffold(key: Key('orders-root')),
    );
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      navigatorObservers: [observer],
      routes: {
        BaseUrlConfigPage.routeName: (context) =>
            const Scaffold(key: Key('startup-root')),
        Routes.auth: (context) => const Scaffold(key: Key('auth-root')),
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }

  testWidgets('deep-linked feature root is reset into startup flow', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final observer = _PushCounterObserver();
    await tester.pumpWidget(
      buildApp(navigatorKey, observer, initialRoute: Routes.orders),
    );
    expect(find.byKey(const Key('orders-root')), findsOneWidget);
    final pushesBeforeReset = observer.pushes;
    StartupRouteGuard.scheduleStartupReset(navigatorKey);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startup-root')), findsOneWidget);
    expect(find.byKey(const Key('orders-root')), findsNothing);
    // 深链根路由被移除后，启动页是栈中唯一路由。
    expect(navigatorKey.currentState!.canPop(), isFalse);
    expect(observer.pushes, pushesBeforeReset + 1);
  });

  testWidgets('normal startup route is kept unchanged', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final observer = _PushCounterObserver();
    await tester.pumpWidget(
      buildApp(
        navigatorKey,
        observer,
        initialRoute: BaseUrlConfigPage.routeName,
      ),
    );
    final pushesBeforeReset = observer.pushes;
    StartupRouteGuard.scheduleStartupReset(navigatorKey);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startup-root')), findsOneWidget);
    expect(observer.pushes, pushesBeforeReset);
  });
}

class _PushCounterObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}
