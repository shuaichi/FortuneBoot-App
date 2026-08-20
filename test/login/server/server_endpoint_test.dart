import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';

void main() {
  group('ServerEndpoint', () {
    test('builds HTTP and HTTPS API URIs with optional ports', () {
      expect(
        ServerEndpoint.parse(
          protocol: 'https',
          host: 'demo.example.com',
          port: '443',
        ).apiBaseUri.toString(),
        'https://demo.example.com/prod-api',
      );
      expect(
        ServerEndpoint.parse(
          protocol: 'http',
          host: '192.168.1.8',
        ).apiBaseUri.toString(),
        'http://192.168.1.8/prod-api',
      );
    });

    test('accepts IPv6 hosts and trims persisted values', () {
      final endpoint = ServerEndpoint.parse(
        protocol: ' https ',
        host: ' [2001:db8::1] ',
        port: ' 8080 ',
      );

      expect(endpoint.host, '2001:db8::1');
      expect(endpoint.port, 8080);
      expect(
        endpoint.apiBaseUri.toString(),
        'https://[2001:db8::1]:8080/prod-api',
      );
    });

    test('rejects hosts containing URI components or whitespace', () {
      for (final host in const [
        '',
        ' https://example.com',
        'example.com/path',
        'example.com?query=1',
        'user@example.com',
        'example .com',
      ]) {
        expect(
          () => ServerEndpoint.parse(protocol: 'https', host: host),
          throwsA(isA<ServerEndpointFormatException>()),
        );
      }
    });

    test('rejects invalid protocols and ports', () {
      expect(
        () => ServerEndpoint.parse(protocol: 'ftp', host: 'example.com'),
        throwsA(isA<ServerEndpointFormatException>()),
      );
      for (final port in const ['0', '65536', '-1', 'abc']) {
        expect(
          () => ServerEndpoint.parse(
            protocol: 'http',
            host: 'example.com',
            port: port,
          ),
          throwsA(isA<ServerEndpointFormatException>()),
        );
      }
    });
  });
}
