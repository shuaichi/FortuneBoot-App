/// A validated self-hosted FortuneBoot server endpoint.
class ServerEndpoint {
  const ServerEndpoint._({
    required this.protocol,
    required this.host,
    required this.port,
  });

  factory ServerEndpoint.parse({
    required String protocol,
    required String host,
    String? port,
  }) {
    final normalizedProtocol = protocol.trim().toLowerCase();
    final normalizedHost = _normalizeHost(host);
    if (normalizedProtocol != 'http' && normalizedProtocol != 'https') {
      throw const ServerEndpointFormatException();
    }
    final normalizedPort = _parsePort(port);
    return ServerEndpoint._(
      protocol: normalizedProtocol,
      host: normalizedHost,
      port: normalizedPort,
    );
  }

  final String protocol;
  final String host;
  final int? port;

  Uri get apiBaseUri =>
      Uri(scheme: protocol, host: host, port: port, path: '/prod-api');

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
