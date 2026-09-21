import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/core/network/fx_api.dart';

void main() {
  group('FxFailureMapper', () {
    test('classifies connection errors without exposing raw details', () {
      final failure = FxFailureMapper.map(
        _dioException(
          type: DioExceptionType.connectionError,
          message: 'https://example.test?token=secret',
        ),
      );

      expect(failure.kind, FxFailureKind.network);
      expect(failure.shouldClearAuth, isFalse);
      expect(failure.diagnostic, isNull);
    });

    test('classifies timeout variants as timeout', () {
      for (final type in const [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          FxFailureMapper.map(_dioException(type: type)).kind,
          FxFailureKind.timeout,
        );
      }
    });

    test('classifies HTTP 401 and 403 as authentication expiry', () {
      for (final statusCode in const [401, 403]) {
        final failure = FxFailureMapper.map(
          _dioException(
            type: DioExceptionType.badResponse,
            statusCode: statusCode,
          ),
        );

        expect(failure.shouldClearAuth, isTrue);
        expect(
          failure.kind,
          statusCode == 401
              ? FxFailureKind.unauthorized
              : FxFailureKind.forbidden,
        );
      }
    });

    test(
      'classifies confirmed business expiry codes as authentication expiry',
      () {
        for (final code in const [106, 107, 108]) {
          final failure = FxFailureMapper.map(
            FxApiException(code, 'server message with token=secret'),
          );

          expect(failure.kind, FxFailureKind.unauthorized);
          expect(failure.shouldClearAuth, isTrue);
          expect(failure.apiCode, code);
          expect(failure.diagnostic, isNull);
        }
      },
    );

    test('classifies 5xx separately from network failures', () {
      final failure = FxFailureMapper.map(
        _dioException(type: DioExceptionType.badResponse, statusCode: 503),
      );

      expect(failure.kind, FxFailureKind.serverUnavailable);
      expect(failure.shouldClearAuth, isFalse);
    });

    test('classifies parsing and unknown failures without raw messages', () {
      expect(
        FxFailureMapper.map(const FormatException('token=secret')).kind,
        FxFailureKind.invalidResponse,
      );
      final unknown = FxFailureMapper.map(StateError('https://example.test'));
      expect(unknown.kind, FxFailureKind.unknown);
      expect(unknown.diagnostic, isNull);
    });
  });
}

DioException _dioException({
  required DioExceptionType type,
  int? statusCode,
  String? message,
}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: statusCode),
    message: message,
  );
}
