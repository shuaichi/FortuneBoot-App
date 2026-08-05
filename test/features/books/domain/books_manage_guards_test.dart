import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/features/books/domain/books_manage_guards.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  setUpAll(() async {
    await S.load(const Locale('zh'));
  });

  const owner = ManageCapabilities(role: ManageRole.owner);
  const actor = ManageCapabilities(role: ManageRole.actor);
  const visitor = ManageCapabilities.visitor;

  ManagedGroup managedGroup({bool enable = true, int id = 1}) {
    return ManagedGroup.fromJson({
      'groupId': id,
      'groupName': '家庭',
      'enable': enable,
      'roleType': 1,
    });
  }

  FortuneBookVo book({bool enable = true, int id = 1}) {
    return FortuneBookVo(
      bookId: id,
      groupId: 1,
      bookName: '日常',
      enable: enable,
    );
  }

  group('GroupGuard', () {
    test('blocks disabling the last enabled group', () {
      final decision = GroupGuard.canToggle(
        group: managedGroup(),
        targetEnable: false,
        defaultGroupId: 2,
        enabledGroupCount: 1,
        capabilities: actor,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, contains('至少保留'));
    });

    test('blocks deleting the default group before switching default', () {
      final decision = GroupGuard.canDelete(
        group: managedGroup(id: 3),
        defaultGroupId: 3,
        enabledGroupCount: 2,
        capabilities: owner,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, contains('默认分组'));
    });

    test('blocks visitor from setting default group', () {
      final decision = GroupGuard.canSetDefault(
        group: managedGroup(id: 4),
        defaultGroupId: 1,
        enabledActiveBooksCount: 1,
        capabilities: visitor,
      );

      expect(decision.allowed, isFalse);
    });
  });

  group('BookGuard', () {
    test('blocks disabling the default book', () {
      final decision = BookGuard.canToggle(
        book: book(id: 8),
        targetEnable: false,
        defaultBookId: 8,
        enabledActiveBookCount: 2,
        capabilities: actor,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, contains('默认账本'));
    });

    test('blocks recycling the only enabled active book', () {
      final decision = BookGuard.canMoveToRecycle(
        book: book(id: 9),
        defaultBookId: 8,
        enabledActiveBookCount: 1,
        capabilities: actor,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, contains('唯一可用账本'));
    });

    test('blocks setting disabled book as default', () {
      final decision = BookGuard.canSetDefault(
        book: book(id: 10, enable: false),
        defaultBookId: 8,
        inRecycleBin: false,
        capabilities: actor,
      );

      expect(decision.allowed, isFalse);
      expect(decision.reason, contains('先启用'));
    });
  });
}
