import 'package:flutter/foundation.dart';

/// 从启动路由中保留的可恢复目标。
///
/// Web 刷新时 Flutter 会把浏览器路径作为初始路由；这里只保存路径和查询参数，
/// 不伪造页面对象，也不在会话未恢复时提前放行。
@immutable
class DeepLinkTarget {
  const DeepLinkTarget({
    required this.route,
    required this.query,
    required this.rawRoute,
  });

  /// 去掉查询串后的规范化路由，例如 `/orders/detail`。
  final String route;

  /// URL 查询参数。
  final Map<String, String> query;

  /// 原始初始路由，用于诊断。
  final String rawRoute;

  /// 路由参数；没有查询参数时保持 null，避免把空 Map 当成完整对象。
  Object? get arguments =>
      query.isEmpty ? null : Map<String, dynamic>.from(query);

  static DeepLinkTarget? tryParse(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null) return null;

    var path = uri.path;
    var query = uri.queryParameters;
    // 兼容 hash 路由被完整传入的情况，例如 `/#/orders/detail?orderId=1`。
    final fragment = uri.fragment.trim();
    if ((path.isEmpty || path == '/') && fragment.startsWith('/')) {
      final fragmentUri = Uri.tryParse(fragment);
      if (fragmentUri != null) {
        path = fragmentUri.path;
        if (fragmentUri.queryParameters.isNotEmpty) {
          query = fragmentUri.queryParameters;
        }
      }
    }
    if (path.isEmpty || path == '/') return null;
    final normalized = path.length > 1 && path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    if (!normalized.startsWith('/')) return null;
    return DeepLinkTarget(
      route: normalized,
      query: Map<String, String>.unmodifiable(query),
      rawRoute: text,
    );
  }

  @override
  String toString() => rawRoute;
}
