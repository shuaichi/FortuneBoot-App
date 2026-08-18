import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';

void main() {
  group('UserProfile audit fields', () {
    test('prefers non-empty profile audit fields over cached values', () {
      final profile = UserProfile.fromJson({
        'user': {
          'loginIp': '10.0.0.1',
          'loginDate': '2026-08-18T10:29:23',
          'remark': 'from profile',
        },
      });

      final result = profile.withAuditFallback({
        'loginIp': '192.168.1.1',
        'loginDate': '2025-01-01T00:00:00',
        'remark': 'from cache',
      });

      expect(result.loginIp, '10.0.0.1');
      expect(result.loginDate, '2026-08-18T10:29:23');
      expect(result.remark, 'from profile');
    });

    test('uses cache only to fill missing audit fields', () {
      final profile = UserProfile.fromJson({
        'user': {'loginIp': '10.0.0.1', 'remark': '   '},
      });

      final result = profile.withAuditFallback({
        'loginIp': '192.168.1.1',
        'loginDate': '2026-08-18T10:29:23',
        'remark': 'from cache',
      });

      expect(result.loginIp, '10.0.0.1');
      expect(result.loginDate, '2026-08-18T10:29:23');
      expect(result.remark, 'from cache');
    });

    test('reads audit fields from the outer response when user lacks them', () {
      final profile = UserProfile.fromJson({
        'user': {'username': 'admin'},
        'loginIp': '111.202.148.166',
        'loginDate': '2026-08-18 10:29:23',
        'remark': '管理员',
      });

      expect(profile.loginIp, '111.202.148.166');
      expect(profile.loginDate, '2026-08-18 10:29:23');
      expect(profile.remark, '管理员');
    });
  });
}
