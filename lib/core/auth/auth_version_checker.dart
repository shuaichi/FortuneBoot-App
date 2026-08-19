import 'package:fortuneboot/core/app_constants.dart';

abstract interface class ApiVersionSource {
  Future<ApiVersionProbe> getApiVersion();
}

sealed class ApiVersionProbe {
  const ApiVersionProbe();
}

final class ApiVersionResponse extends ApiVersionProbe {
  const ApiVersionResponse(this.version);

  final String? version;
}

final class ApiVersionEndpointUnavailable extends ApiVersionProbe {
  const ApiVersionEndpointUnavailable();
}

final class ApiVersionConnectionFailed extends ApiVersionProbe {
  const ApiVersionConnectionFailed();
}

enum ApiVersionStatus {
  compatible,
  versionTooLow,
  versionTooHigh,
  versionInvalid,
  endpointUnavailable,
  connectionFailed,
}

class ApiVersionCheckResult {
  const ApiVersionCheckResult({required this.status, this.actualVersion = ''});

  final ApiVersionStatus status;
  final String actualVersion;

  bool get isCompatible => status == ApiVersionStatus.compatible;
}

class AuthVersionChecker {
  const AuthVersionChecker({required ApiVersionSource source})
    : _source = source;

  final ApiVersionSource _source;

  Future<ApiVersionCheckResult> check() async {
    final probe = await _source.getApiVersion();
    return switch (probe) {
      ApiVersionResponse(:final version) => _checkVersion(version),
      ApiVersionEndpointUnavailable() => const ApiVersionCheckResult(
        status: ApiVersionStatus.endpointUnavailable,
      ),
      ApiVersionConnectionFailed() => const ApiVersionCheckResult(
        status: ApiVersionStatus.connectionFailed,
      ),
    };
  }

  ApiVersionCheckResult _checkVersion(String? version) {
    final normalizedVersion = version?.trim() ?? '';
    if (!_isNumericDotVersion(normalizedVersion)) {
      return const ApiVersionCheckResult(
        status: ApiVersionStatus.versionInvalid,
      );
    }

    if (_compare(normalizedVersion, AppConstants.minApiVersion) < 0) {
      return ApiVersionCheckResult(
        status: ApiVersionStatus.versionTooLow,
        actualVersion: normalizedVersion,
      );
    }

    if (_compare(normalizedVersion, AppConstants.maxApiVersion) >= 0) {
      return ApiVersionCheckResult(
        status: ApiVersionStatus.versionTooHigh,
        actualVersion: normalizedVersion,
      );
    }

    return ApiVersionCheckResult(
      status: ApiVersionStatus.compatible,
      actualVersion: normalizedVersion,
    );
  }

  bool _isNumericDotVersion(String version) =>
      RegExp(r'^\d+(?:\.\d+)*$').hasMatch(version);

  int _compare(String first, String second) {
    final firstParts = first.split('.');
    final secondParts = second.split('.');
    final maxLength = firstParts.length > secondParts.length
        ? firstParts.length
        : secondParts.length;

    for (var index = 0; index < maxLength; index++) {
      final firstPart = index < firstParts.length
          ? int.parse(firstParts[index])
          : 0;
      final secondPart = index < secondParts.length
          ? int.parse(secondParts[index])
          : 0;
      if (firstPart != secondPart) return firstPart.compareTo(secondPart);
    }

    return 0;
  }
}
