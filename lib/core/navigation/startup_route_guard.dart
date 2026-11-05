import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/deep_link_target.dart';
import 'package:fortuneboot/core/navigation/pending_deep_link.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/login/view/base_url_config_page.dart';

/// 启动路由守卫：把 Web 深链根栈拉回统一启动流程。
///
/// Flutter Web 刷新时，浏览器 URL 路径会通过 PlatformDispatcher.defaultRouteName
/// 覆盖 MaterialApp.initialRoute，使功能页（如 /orders）成为 Navigator 根路由：
/// 一方面绕过 baseUrlConfig 的版本与会话校验，另一方面返回键没有上级栈可退。
/// 守卫在首帧后检测该场景并重置回 baseUrlConfig，保证原生冷启动与 Web 刷新
/// 都统一经过启动校验并落到首页仪表盘。
class StartupRouteGuard {
  const StartupRouteGuard._();

  /// 判断 Navigator 的初始路由是否绕过了启动流程页面。
  static bool bypassedStartupFlow(NavigatorState navigator) {
    final initialRoute = navigator.widget.initialRoute;
    if (initialRoute == null || initialRoute == Navigator.defaultRouteName) {
      return false;
    }
    final path = DeepLinkTarget.tryParse(initialRoute)?.route ?? initialRoute;
    return path != BaseUrlConfigPage.routeName && path != Routes.auth;
  }

  /// 首帧后执行一次：若初始路由绕过启动流程，则清栈重置回 baseUrlConfig。
  static void scheduleStartupReset(GlobalKey<NavigatorState> navigatorKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      if (!bypassedStartupFlow(navigator)) return;
      // 先保留目标，再清栈回启动校验；登录/会话恢复后由主壳继续。
      PendingDeepLink.instance.capture(navigator.widget.initialRoute);
      navigator.pushNamedAndRemoveUntil(
        BaseUrlConfigPage.routeName,
        (route) => false,
      );
    });
  }
}
