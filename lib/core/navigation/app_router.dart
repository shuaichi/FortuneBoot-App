import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/deep_link_target.dart';
import 'package:fortuneboot/core/navigation/fx_page_route.dart';
import 'package:fortuneboot/core/navigation/fx_route_unavailable_page.dart';

/// 集中路由工厂。二级页面通过各 feature 的 Args 对象在 arguments 中传参。
///
/// 注意：登录三页（base_url_config / auth）仍由 app.dart 的 routes 表直接注册；
/// 本工厂负责 MainShell 及其后的所有新页面。各 feature 落地后在此登记 builder。
class AppRouter {
  const AppRouter._();

  /// feature 页面注册表。key 为 Routes 常量，value 为 builder(接收 arguments)。
  /// 各 feature 阶段落地时向此 map 注入自己的 builder（在 app 启动前 register）。
  static final Map<String, _RouteEntry> _builders = {};

  /// 注册路由。
  ///
  /// [deepLinkRestorable] 为 false 时，Web 深链恢复只显示明确出口，不把缺失
  /// 对象的页面强行打开。[requiredDeepLinkKeys] 用于必须带参数的详情页。
  static void register(
    String route,
    Widget Function(Object? args) builder, {
    bool deepLinkRestorable = true,
    List<String> requiredDeepLinkKeys = const [],
    bool requiresWriteAccess = false,
  }) {
    _builders[route] = _RouteEntry(
      builder: builder,
      deepLinkRestorable: deepLinkRestorable,
      requiredDeepLinkKeys: requiredDeepLinkKeys,
      requiresWriteAccess: requiresWriteAccess,
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final entry = _builders[settings.name];
    if (entry == null) return null;
    return buildFxRoute<dynamic>(
      builder: (_) => entry.builder(settings.arguments),
      settings: settings,
    );
  }

  /// 无匹配路由时也给出可返回的页面，不用框架灰屏替代任务出口。
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return buildFxRoute<dynamic>(
      builder: (_) => const FxRouteUnavailablePage(
        reason: FxRouteUnavailableReason.unknownRoute,
      ),
      settings: settings,
    );
  }

  static bool canRestore(DeepLinkTarget target) {
    final entry = _builders[target.route];
    if (entry == null || !entry.deepLinkRestorable) return false;
    return entry.requiredDeepLinkKeys.every(target.query.containsKey);
  }

  static bool requiresWriteAccess(String route) =>
      _builders[route]?.requiresWriteAccess ?? false;

  static bool isRegistered(String route) => _builders.containsKey(route);

  /// 便捷 push。
  ///
  /// 注意：onGenerateRoute 统一返回 `Route<dynamic>`，不能直接
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

class _RouteEntry {
  const _RouteEntry({
    required this.builder,
    required this.deepLinkRestorable,
    required this.requiredDeepLinkKeys,
    required this.requiresWriteAccess,
  });

  final Widget Function(Object? args) builder;
  final bool deepLinkRestorable;
  final List<String> requiredDeepLinkKeys;
  final bool requiresWriteAccess;
}
