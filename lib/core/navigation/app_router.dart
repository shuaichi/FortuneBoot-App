import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/app_nav.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/util/custom_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 恢复栈中的一跳：路由名 + JSON 安全参数。
class RouteRestoreHop {
  final String name;
  final Map<String, dynamic> args;

  const RouteRestoreHop(this.name, this.args);
}

/// 集中路由工厂。二级页面通过各 feature 的 Args 对象在 arguments 中传参。
///
/// 注意：登录三页（base_url_config / auth）仍由 app.dart 的 routes 表直接注册；
/// 本工厂负责 MainShell 及其后的所有新页面。各 feature 落地后在此登记 builder。
class AppRouter {
  const AppRouter._();

  /// feature 页面注册表。key 为 Routes 常量，value 为 builder(接收 arguments)。
  /// 各 feature 阶段落地时向此 map 注入自己的 builder（在 app 启动前 register）。
  static final Map<String, Widget Function(Object? args)> _builders = {};

  static void register(String route, Widget Function(Object? args) builder) {
    _builders[route] = builder;
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = _builders[settings.name];
    if (builder == null) return null;
    // 白名单功能页（单据管理）记录最近一次访问，供 Web/App 冷启动恢复，
    // 避免刷新后必须从首页重新点开功能。
    unawaited(persistRestorableRoute(settings));
    return FadePageRoute(
      builder: (_) => builder(settings.arguments),
      settings: settings,
    );
  }

  // ---- 冷启动路由恢复（前端持久化，非后端契约） ----

  static const String lastRouteKey = 'last_feature_route_v1';

  /// 可恢复的白名单路由：参数均可 JSON 序列化，恢复不依赖业务对象。
  static const Set<String> _restorableRoutes = {
    Routes.orders,
    Routes.orderDetail,
    Routes.orderReconciliation,
  };

  /// 记录白名单路由访问。非白名单路由直接忽略。
  static Future<void> persistRestorableRoute(RouteSettings settings) async {
    final name = settings.name;
    if (name == null || !_restorableRoutes.contains(name)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      lastRouteKey,
      jsonEncode({'name': name, 'args': _jsonSafeArgs(settings.arguments)}),
    );
  }

  /// 计算冷启动恢复栈：详情页前自动压入列表页，保证返回键落到列表而不是空前缀。
  static Future<List<RouteRestoreHop>> restoreRouteStack() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(lastRouteKey);
    if (raw == null) return const [];
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const [];
    }
    if (decoded is! Map) return const [];
    final name = decoded['name'];
    final args = decoded['args'];
    if (name is! String || !_restorableRoutes.contains(name)) return const [];
    final safeArgs = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    if (name == Routes.orderDetail &&
        safeArgs['bookId'] is int &&
        safeArgs['orderId'] is int) {
      return [
        const RouteRestoreHop(Routes.orders, {}),
        RouteRestoreHop(name, safeArgs),
      ];
    }
    return [RouteRestoreHop(name, safeArgs)];
  }

  /// 冷启动（会话校验通过进入主界面后）恢复最近打开的白名单功能页。
  static Future<void> restoreLastRoute() async {
    final stack = await restoreRouteStack();
    if (stack.isEmpty) return;
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    for (final hop in stack) {
      await navigator.pushNamed(
        hop.name,
        arguments: hop.args.isEmpty ? null : hop.args,
      );
    }
  }

  static Map<String, dynamic> _jsonSafeArgs(Object? args) {
    if (args is! Map) return <String, dynamic>{};
    final result = <String, dynamic>{};
    args.forEach((key, value) {
      if (key is! String) return;
      if (value == null || value is num || value is bool || value is String) {
        result[key] = value;
      }
    });
    return result;
  }

  /// 便捷 push。
  ///
  /// 注意：onGenerateRoute 统一返回 `FadePageRoute<dynamic>`，不能直接
  /// `pushNamed<T>`（Flutter 会把路由强转为 `Route<T>`，运行时会抛
  /// `Route<dynamic> is not a subtype of Route<T?>`）。因此这里以 dynamic
  /// 入栈，再对返回值做类型收敛。
  static Future<T?> push<T>(
    BuildContext context,
    String route, {
    Object? args,
  }) async {
    final result = await Navigator.of(
      context,
    ).pushNamed<dynamic>(route, arguments: args);
    return result is T ? result : null;
  }
}
