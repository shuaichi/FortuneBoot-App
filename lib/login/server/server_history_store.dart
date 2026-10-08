import 'dart:convert';

import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';

/// 本地记住的自建服务器地址（最近优先）。
class ServerHistoryEntry {
  const ServerHistoryEntry({
    required this.protocol,
    required this.host,
    required this.port,
  });

  final String protocol;
  final String host;

  /// 空字符串表示未指定端口。
  final String port;

  factory ServerHistoryEntry.fromEndpoint(ServerEndpoint endpoint) {
    return ServerHistoryEntry(
      protocol: endpoint.protocol,
      host: endpoint.host,
      port: endpoint.storedPort,
    );
  }

  factory ServerHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ServerHistoryEntry(
      protocol: (json['protocol'] ?? 'https').toString(),
      host: (json['host'] ?? '').toString(),
      port: (json['port'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'protocol': protocol,
    'host': host,
    'port': port,
  };

  ServerEndpoint toEndpoint() => ServerEndpoint.parse(
    protocol: protocol,
    host: host,
    port: port.isEmpty ? null : port,
  );

  /// 展示用，如 `https://demo.example.com` / `http://192.168.1.8:8080`。
  String get displayLabel {
    final hostPart = host.contains(':') ? '[$host]' : host;
    if (port.isEmpty) return '$protocol://$hostPart';
    return '$protocol://$hostPart:$port';
  }

  String get identityKey => '$protocol|$host|$port';

  @override
  bool operator ==(Object other) =>
      other is ServerHistoryEntry && other.identityKey == identityKey;

  @override
  int get hashCode => identityKey.hashCode;
}

/// SharedPreferences 持久化的服务器历史。
class ServerHistoryStore {
  ServerHistoryStore({UserDataSingleton? userData})
    : _userData = userData ?? UserDataSingleton();

  static const String prefsKey = 'serverUrlHistory';
  static const int maxEntries = 12;

  final UserDataSingleton _userData;

  Future<List<ServerHistoryEntry>> load() async {
    final raw = await _userData.getStr(prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final entries = <ServerHistoryEntry>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          final entry = ServerHistoryEntry.fromJson(
            Map<String, dynamic>.from(item),
          );
          entry.toEndpoint();
          entries.add(entry);
        } on ServerEndpointFormatException {
          continue;
        }
      }
      return entries;
    } on FormatException {
      return const [];
    }
  }

  Future<void> remember(ServerEndpoint endpoint) async {
    final next = ServerHistoryEntry.fromEndpoint(endpoint);
    final current = await load();
    final merged = <ServerHistoryEntry>[
      next,
      ...current.where((e) => e != next),
    ];
    await _persist(merged.take(maxEntries).toList());
  }

  /// 从当前已保存的 baseUrl 字段写入历史（兼容老用户）。
  Future<void> rememberCurrentSaved() async {
    final protocol = await _userData.getStr(UserDataSingleton.baseUrlProtocol);
    final host = await _userData.getStr(UserDataSingleton.baseUrlDomain);
    final port = await _userData.getStr(UserDataSingleton.baseUrlPort);
    if (protocol == null ||
        protocol.isEmpty ||
        host == null ||
        host.isEmpty) {
      return;
    }
    try {
      await remember(
        ServerEndpoint.parse(protocol: protocol, host: host, port: port),
      );
    } on ServerEndpointFormatException {
      // ignore invalid persisted values
    }
  }

  Future<void> remove(ServerHistoryEntry entry) async {
    final current = await load();
    await _persist(current.where((e) => e != entry).toList());
  }

  Future<void> _persist(List<ServerHistoryEntry> entries) async {
    _userData.setStr(
      prefsKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }
}
