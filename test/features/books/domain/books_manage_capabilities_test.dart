import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';

void main() {
  group('CapabilityResolver', () {
    test('grants owner full management capabilities', () {
      final capabilities = CapabilityResolver.fromRoleType(1);

      expect(capabilities.role, ManageRole.owner);
      expect(capabilities.canCreateGroup, isTrue);
      expect(capabilities.canCreateBook, isTrue);
      expect(capabilities.canInvite, isTrue);
      expect(capabilities.canRemoveMember, isTrue);
      expect(capabilities.canDeleteGroup, isTrue);
    });

    test(
      'grants actor write capabilities but no member or delete authority',
      () {
        final capabilities = CapabilityResolver.fromRoleType(2);

        expect(capabilities.role, ManageRole.actor);
        expect(capabilities.canCreateGroup, isTrue);
        expect(capabilities.canSetDefault, isTrue);
        expect(capabilities.canInvite, isFalse);
        expect(capabilities.canRemoveMember, isFalse);
        expect(capabilities.canDeleteGroup, isFalse);
      },
    );

    test('falls back to visitor when role is missing or unknown', () {
      final missing = CapabilityResolver.fromRoleType(null);
      final unknown = CapabilityResolver.fromRoleType(999);

      expect(missing.role, ManageRole.visitor);
      expect(missing.resolved, isFalse);
      expect(missing.canCreateBook, isFalse);
      expect(unknown.role, ManageRole.visitor);
      expect(unknown.canEdit, isFalse);
    });

    test('uses fallback member role when group roleType is absent', () {
      final group = ManagedGroup.fromJson({
        'groupId': '1',
        'groupName': '家庭',
        'enable': true,
      });
      const member = GroupMemberVo(username: 'zhangsan', roleType: 2);

      final capabilities = CapabilityResolver.fromGroup(
        group,
        fallbackMember: member,
      );

      expect(capabilities.role, ManageRole.actor);
    });
  });
}
