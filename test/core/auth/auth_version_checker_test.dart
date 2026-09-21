import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';

void main() {
  group('AuthVersionChecker', () {
    test('accepts the minimum supported API version', () async {
      final source = _FakeApiVersionSource(const ApiVersionResponse('1.7.0'));
      final checker = AuthVersionChecker(source: source);

      final result = await checker.check();

      expect(result.status, ApiVersionStatus.compatible);
      expect(result.actualVersion, '1.7.0');
    });

    test('accepts versions below the exclusive upper bound', () async {
      final source = _FakeApiVersionSource(const ApiVersionResponse('1.9.9'));
      final checker = AuthVersionChecker(source: source);

      final result = await checker.check();

      expect(result.status, ApiVersionStatus.compatible);
    });

    test('rejects versions below the minimum supported API version', () async {
      final source = _FakeApiVersionSource(const ApiVersionResponse('1.6.9'));
      final checker = AuthVersionChecker(source: source);

      final result = await checker.check();

      expect(result.status, ApiVersionStatus.versionTooLow);
      expect(result.actualVersion, '1.6.9');
    });

    test('rejects the exclusive upper API version bound', () async {
      final source = _FakeApiVersionSource(const ApiVersionResponse('2.0.0'));
      final checker = AuthVersionChecker(source: source);

      final result = await checker.check();

      expect(result.status, ApiVersionStatus.versionTooHigh);
      expect(result.actualVersion, '2.0.0');
    });

    test('treats missing and malformed versions as invalid', () async {
      final missingChecker = AuthVersionChecker(
        source: _FakeApiVersionSource(const ApiVersionResponse(null)),
      );
      final malformedChecker = AuthVersionChecker(
        source: _FakeApiVersionSource(const ApiVersionResponse('1.x.0')),
      );

      expect(
        (await missingChecker.check()).status,
        ApiVersionStatus.versionInvalid,
      );
      expect(
        (await malformedChecker.check()).status,
        ApiVersionStatus.versionInvalid,
      );
    });

    test(
      'classifies an unavailable endpoint separately from connection failure',
      () async {
        final unavailableChecker = AuthVersionChecker(
          source: _FakeApiVersionSource(const ApiVersionEndpointUnavailable()),
        );
        final connectionChecker = AuthVersionChecker(
          source: _FakeApiVersionSource(const ApiVersionConnectionFailed()),
        );

        expect(
          (await unavailableChecker.check()).status,
          ApiVersionStatus.endpointUnavailable,
        );
        expect(
          (await connectionChecker.check()).status,
          ApiVersionStatus.connectionFailed,
        );
      },
    );
  });
}

class _FakeApiVersionSource implements ApiVersionSource {
  const _FakeApiVersionSource(this.probe);

  final ApiVersionProbe probe;

  @override
  Future<ApiVersionProbe> getApiVersion() async => probe;
}
