import 'package:flutter/material.dart';
import 'package:fortuneboot/util/custom_route.dart';

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
    return FadePageRoute(
      builder: (_) => builder(settings.arguments),
      settings: settings,
    );
  }

  /// 便捷 push。
  static Future<T?> push<T>(
    BuildContext context,
    String route, {
    Object? args,
  }) {
    return Navigator.of(context).pushNamed<T>(route, arguments: args);
  }
}
