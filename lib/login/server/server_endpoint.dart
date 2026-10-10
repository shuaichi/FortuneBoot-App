/// A validated self-hosted FortuneBoot server endpoint.
class ServerEndpoint {
  const ServerEndpoint._({
    required this.protocol,
    required this.host,
    required this.port,
    required this.apiPrefix,
  });

  factory ServerEndpoint.parse({
    required String protocol,
    required String host,
    String? port,
    String? apiPrefix,
  }) {
    final normalizedProtocol = protocol.trim().toLowerCase();
    final normalizedHost = _normalizeHost(host);
    if (normalizedProtocol != 'http' && normalizedProtocol != 'https') {
      throw const ServerEndpointFormatException();
    }
    final normalizedPort = _parsePort(port);
    final normalizedApiPrefix = _normalizeApiPrefix(apiPrefix);
    return ServerEndpoint._(
      protocol: normalizedProtocol,
      host: normalizedHost,
      port: normalizedPort,
      apiPrefix: normalizedApiPrefix,
    );
  }

  final String protocol;
  final String host;
  final int? port;

  /// 后端接口前缀（如 /prod-api、/dev-api）；空字符串表示无前缀，接口直接挂在
  /// 域名根路径，常用于无网关的本地调试。
  final String apiPrefix;

  /// 不传前缀时的历史默认行为。
  static const String defaultApiPrefix = '/prod-api';

  /// 开发者会话前缀：仅保留在进程内存，不落盘、不进历史；冷启动（新进程）为
  /// null，回滚为 [defaultApiPrefix]。配置页在开发者模式下设置后，启动恢复、
  /// 版本门禁、主流程校验都应在本次启动内沿用，保证同一前缀贯穿整个会话。
  static String? sessionApiPrefix;

  Uri get apiBaseUri => Uri(
    scheme: protocol,
    host: host,
    port: port,
    path: apiPrefix.isEmpty ? '' : apiPrefix,
  );

  String get storedPort => port?.toString() ?? '';

  static String _normalizeHost(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const ServerEndpointFormatException();
    }
    final unbracketed = trimmed.startsWith('[') && trimmed.endsWith(']')
        ? trimmed.substring(1, trimmed.length - 1)
        : trimmed;
    final isIpv6 = unbracketed.contains(':');
    if (unbracketed.isEmpty ||
        unbracketed.contains(RegExp(r'\s')) ||
        unbracketed.contains(RegExp(r'[/@?#]'))) {
      throw const ServerEndpointFormatException();
    }
    final parsed = Uri.tryParse(
      isIpv6 ? 'http://[$unbracketed]' : 'http://$unbracketed',
    );
    if (parsed == null ||
        parsed.host.isEmpty ||
        parsed.host != unbracketed ||
        parsed.userInfo.isNotEmpty ||
        (!isIpv6 && unbracketed.contains(':')) ||
        parsed.path.isNotEmpty ||
        parsed.query.isNotEmpty ||
        parsed.fragment.isNotEmpty) {
      throw const ServerEndpointFormatException();
    }
    return unbracketed;
  }

  static String _normalizeApiPrefix(String? value) {
    if (value == null) return defaultApiPrefix;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed == '/' ||
        !trimmed.startsWith('/') ||
        trimmed.endsWith('/') ||
        trimmed.contains(RegExp(r'[\s@?#]'))) {
      throw const ServerEndpointFormatException();
    }
    return trimmed;
  }

  static int? _parsePort(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final port = int.tryParse(trimmed);
    if (port == null || port < 1 || port > 65535) {
      throw const ServerEndpointFormatException();
    }
    return port;
  }
}

class ServerEndpointFormatException implements Exception {
  const ServerEndpointFormatException();
}
