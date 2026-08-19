import 'package:dio/dio.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/network/fx_api.dart';

/// Maps technical failures to stable values that are safe for UI state.
abstract final class FxFailureMapper {
  static const _expiredBusinessCodes = {106, 107, 108};

  static FxFailure map(Object error) {
    if (error is FxApiException) {
      if (_expiredBusinessCodes.contains(error.code)) {
        return FxFailure(kind: FxFailureKind.unauthorized, apiCode: error.code);
      }
      return FxFailure(kind: FxFailureKind.businessApi, apiCode: error.code);
    }
    if (error is DioException) return _fromDio(error);
    if (error is FormatException || error is TypeError) {
      return const FxFailure(kind: FxFailureKind.invalidResponse);
    }
    return const FxFailure(kind: FxFailureKind.unknown);
  }

  static FxFailure _fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return const FxFailure(
        kind: FxFailureKind.unauthorized,
        httpStatusCode: 401,
      );
    }
    if (statusCode == 403) {
      return const FxFailure(
        kind: FxFailureKind.forbidden,
        httpStatusCode: 403,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return FxFailure(
        kind: FxFailureKind.serverUnavailable,
        httpStatusCode: statusCode,
      );
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const FxFailure(
        kind: FxFailureKind.timeout,
      ),
      DioExceptionType.connectionError => const FxFailure(
        kind: FxFailureKind.network,
      ),
      DioExceptionType.badResponse => FxFailure(
        kind: FxFailureKind.businessApi,
        httpStatusCode: statusCode,
      ),
      _ => const FxFailure(kind: FxFailureKind.unknown),
    };
  }
}
