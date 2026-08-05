import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';

class GuardDecision {
  const GuardDecision.allowed({this.reason}) : allowed = true;
  const GuardDecision.blocked(this.reason) : allowed = false;

  final bool allowed;
  final String? reason;
}

class GroupGuard {
  const GroupGuard._();

  static GuardDecision canSetDefault({
    required ManagedGroup group,
    required int? defaultGroupId,
    required int enabledActiveBooksCount,
    required ManageCapabilities capabilities,
  }) {
    if (!capabilities.canSetDefault) {
      return const GuardDecision.blocked('你没有设置默认分组的权限');
    }
    if (!group.enable) {
      return const GuardDecision.blocked('请先启用该分组');
    }
    if (group.groupId == defaultGroupId) {
      return const GuardDecision.blocked('该分组已是默认分组');
    }
    if (enabledActiveBooksCount <= 0) {
      return const GuardDecision.blocked('该分组暂无可用账本，请先新建或启用账本');
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canToggle({
    required ManagedGroup group,
    required bool targetEnable,
    required int? defaultGroupId,
    required int enabledGroupCount,
    required ManageCapabilities capabilities,
  }) {
    if (!capabilities.canToggle) {
      return const GuardDecision.blocked('你没有启停分组的权限');
    }
    if (targetEnable) {
      if (group.enable) {
        return const GuardDecision.blocked('该分组已启用');
      }
      return const GuardDecision.allowed();
    }
    if (!group.enable) {
      return const GuardDecision.blocked('该分组已停用');
    }
    if (enabledGroupCount <= 1) {
      return const GuardDecision.blocked('至少保留一个启用分组');
    }
    if (group.groupId == defaultGroupId) {
      return const GuardDecision.blocked('请先设置其他分组为默认分组');
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canDelete({
    required ManagedGroup group,
    required int? defaultGroupId,
    required int enabledGroupCount,
    required ManageCapabilities capabilities,
  }) {
    if (!capabilities.canDeleteGroup) {
      return const GuardDecision.blocked('你没有删除分组的权限');
    }
    if (group.enable && enabledGroupCount <= 1) {
      return const GuardDecision.blocked('至少保留一个启用分组');
    }
    if (group.groupId == defaultGroupId) {
      return const GuardDecision.blocked('请先设置其他分组为默认分组');
    }
    return const GuardDecision.allowed();
  }
}

class BookGuard {
  const BookGuard._();

  static bool isDefaultBook(FortuneBookVo book, int? defaultBookId) {
    return book.bookId != null && book.bookId == defaultBookId;
  }

  static GuardDecision canSetDefault({
    required FortuneBookVo book,
    required int? defaultBookId,
    required bool inRecycleBin,
    required ManageCapabilities capabilities,
  }) {
    if (!capabilities.canSetDefault) {
      return const GuardDecision.blocked('你没有设置默认账本的权限');
    }
    if (inRecycleBin) {
      return const GuardDecision.blocked('请先恢复该账本');
    }
    if (!book.enable) {
      return const GuardDecision.blocked('请先启用该账本再设为默认');
    }
    if (isDefaultBook(book, defaultBookId)) {
      return const GuardDecision.blocked('该账本已是默认账本');
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canToggle({
    required FortuneBookVo book,
    required bool targetEnable,
    required int? defaultBookId,
    required int enabledActiveBookCount,
    required ManageCapabilities capabilities,
  }) {
    if (!capabilities.canToggle) {
      return const GuardDecision.blocked('你没有启停账本的权限');
    }
    if (targetEnable) {
      if (book.enable) {
        return const GuardDecision.blocked('该账本已启用');
      }
      return const GuardDecision.allowed();
    }
    if (!book.enable) {
      return const GuardDecision.blocked('该账本已停用');
    }
    if (isDefaultBook(book, defaultBookId)) {
      return const GuardDecision.blocked('请先设置其他账本为默认账本');
    }
    if (enabledActiveBookCount <= 1) {
      return const GuardDecision.blocked('这是当前分组唯一可用账本，请先新建或启用其他账本');
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canMoveToRecycle({
    required FortuneBookVo book,
    required int? defaultBookId,
    required int enabledActiveBookCount,
    required ManageCapabilities capabilities,
  }) {
    if (!capabilities.canEdit) {
      return const GuardDecision.blocked('你没有移动账本的权限');
    }
    if (isDefaultBook(book, defaultBookId)) {
      return const GuardDecision.blocked('请先设置其他账本为默认账本');
    }
    if (book.enable && enabledActiveBookCount <= 1) {
      return const GuardDecision.blocked('这是当前分组唯一可用账本，请先新建或启用其他账本');
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canRestore({required ManageCapabilities capabilities}) {
    if (!capabilities.canEdit) {
      return const GuardDecision.blocked('你没有恢复账本的权限');
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canDeleteForever({
    required FortuneBookVo book,
    required int? defaultBookId,
    required int enabledActiveBookCount,
    required ManageCapabilities capabilities,
    bool inRecycleBin = false,
  }) {
    if (!capabilities.canEdit) {
      return const GuardDecision.blocked('你没有删除账本的权限');
    }
    if (isDefaultBook(book, defaultBookId)) {
      return const GuardDecision.blocked('请先设置其他账本为默认账本');
    }
    if (!inRecycleBin && book.enable && enabledActiveBookCount <= 1) {
      return const GuardDecision.blocked('这是当前分组唯一可用账本，请先新建或启用其他账本');
    }
    return const GuardDecision.allowed();
  }
}
