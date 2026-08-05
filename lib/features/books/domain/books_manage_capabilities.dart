import 'package:flutter/foundation.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/generated/l10n.dart';

enum ManageRole { owner, actor, visitor }

extension ManageRoleX on ManageRole {
  String get label => switch (this) {
    ManageRole.owner => S.current.booksRoleOwner,
    ManageRole.actor => S.current.booksRoleActor,
    ManageRole.visitor => S.current.booksRoleVisitor,
  };

  int get value => switch (this) {
    ManageRole.owner => 1,
    ManageRole.actor => 2,
    ManageRole.visitor => 3,
  };
}

class ManageCapabilities {
  const ManageCapabilities({required this.role, this.resolved = true});

  final ManageRole role;
  final bool resolved;

  static const visitor = ManageCapabilities(role: ManageRole.visitor);

  bool get canWrite => role == ManageRole.owner || role == ManageRole.actor;
  bool get canCreateGroup => canWrite;
  bool get canCreateBook => canWrite;
  bool get canEdit => canWrite;
  bool get canSetDefault => canWrite;
  bool get canToggle => canWrite;
  bool get canInvite => role == ManageRole.owner;
  bool get canRemoveMember => role == ManageRole.owner;
  bool get canDeleteGroup => role == ManageRole.owner;
}

class CapabilityResolver {
  const CapabilityResolver._();

  static ManageCapabilities fromGroup(
    ManagedGroup group, {
    GroupMemberVo? fallbackMember,
  }) {
    return fromRoleType(
      group.roleType ?? fallbackMember?.roleType,
      description: group.roleTypeDesc ?? fallbackMember?.roleTypeDesc,
    );
  }

  static ManageCapabilities fromRoleType(int? roleType, {String? description}) {
    final role = switch (roleType) {
      1 => ManageRole.owner,
      2 => ManageRole.actor,
      3 => ManageRole.visitor,
      null => _roleFromDescription(description),
      _ => _unknownRole(roleType),
    };
    return ManageCapabilities(role: role, resolved: roleType != null);
  }

  static ManageRole _roleFromDescription(String? description) {
    final text = description?.trim();
    if (text == null || text.isEmpty) return ManageRole.visitor;
    if (text.contains('超级') || text.contains('管理员') || text.contains('所有者')) {
      return ManageRole.owner;
    }
    if (text.contains('协作') || text.contains('成员') || text.contains('编辑')) {
      return ManageRole.actor;
    }
    return ManageRole.visitor;
  }

  static ManageRole _unknownRole(int? roleType) {
    debugPrint('Unknown books manage roleType: $roleType');
    return ManageRole.visitor;
  }
}
