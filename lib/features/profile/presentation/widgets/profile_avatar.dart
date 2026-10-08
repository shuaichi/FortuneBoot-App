import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/dio_client.dart';

/// 把后端返回的头像路径补成可请求的绝对地址。
String? resolveProfileMediaUrl(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  final base = DioClient().dio.options.baseUrl.trim();
  if (base.isEmpty) return value;

  final normalizedBase = base.endsWith('/') ? base : '$base/';
  final baseUri = Uri.tryParse(normalizedBase);
  if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
    return value;
  }

  if (value.startsWith('/')) {
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: value,
    ).toString();
  }
  return baseUri.resolve(value).toString();
}

/// 个人中心头像：支持本地预览、相对路径补全、鉴权头与缓存刷新。
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.label,
    required this.size,
    this.imageUrl,
    this.localFile,
    this.cacheToken,
  });

  final String? imageUrl;
  final File? localFile;
  final String label;
  final double size;

  /// 变化后强制绕过 ImageCache（同 URL 覆盖上传时必需）。
  final String? cacheToken;

  String get _initial {
    final trimmed = label.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }

  Map<String, String>? get _authHeaders {
    final headers = <String, String>{};
    DioClient().authHeaders.forEach((key, value) {
      final text = value?.toString() ?? '';
      if (text.isNotEmpty) headers[key] = text;
    });
    return headers.isEmpty ? null : headers;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final resolved = resolveProfileMediaUrl(imageUrl);
    final token = cacheToken?.trim();
    String? networkUrl = resolved;
    if (networkUrl != null && token != null && token.isNotEmpty) {
      final uri = Uri.parse(networkUrl);
      networkUrl = uri
          .replace(
            queryParameters: {...uri.queryParameters, 't': token},
          )
          .toString();
    }

    ImageProvider? provider;
    Object imageKey;
    if (localFile != null) {
      provider = FileImage(localFile!);
      imageKey = localFile!.path;
    } else if (networkUrl != null) {
      provider = NetworkImage(networkUrl, headers: _authHeaders);
      imageKey = networkUrl;
    } else {
      imageKey = 'fallback';
    }

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: provider == null
            ? _fallback(palette)
            : Image(
                key: ValueKey(imageKey),
                image: provider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _fallback(palette),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return _fallback(palette);
                },
              ),
      ),
    );
  }

  Widget _fallback(FxPalette palette) {
    return ColoredBox(
      color: palette.primaryContainer,
      child: Center(
        child: Text(
          _initial,
          style: FxTypography.titleLarge.copyWith(color: palette.primary),
        ),
      ),
    );
  }
}
