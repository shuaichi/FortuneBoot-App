import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
      return GuardDecision.blocked(S.current.booksNoPermissionSetDefaultGroup);
    }
    if (!group.enable) {
      return GuardDecision.blocked(S.current.booksEnableGroupFirst);
    }
    if (group.groupId == defaultGroupId) {
      return GuardDecision.blocked(S.current.booksAlreadyDefaultGroup);
    }
    if (enabledActiveBooksCount <= 0) {
      return GuardDecision.blocked(S.current.booksGroupNoAvailableBook);
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
      return GuardDecision.blocked(S.current.booksNoPermissionToggleGroup);
    }
    if (targetEnable) {
      if (group.enable) {
        return GuardDecision.blocked(S.current.booksGroupAlreadyEnabled);
      }
      return const GuardDecision.allowed();
    }
    if (!group.enable) {
      return GuardDecision.blocked(S.current.booksGroupAlreadyDisabled);
    }
    if (enabledGroupCount <= 1) {
      return GuardDecision.blocked(S.current.booksKeepOneEnabledGroup);
    }
    if (group.groupId == defaultGroupId) {
      return GuardDecision.blocked(S.current.booksSetOtherDefaultGroupFirst);
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
      return GuardDecision.blocked(S.current.booksNoPermissionDeleteGroup);
    }
    if (group.enable && enabledGroupCount <= 1) {
      return GuardDecision.blocked(S.current.booksKeepOneEnabledGroup);
    }
    if (group.groupId == defaultGroupId) {
      return GuardDecision.blocked(S.current.booksSetOtherDefaultGroupFirst);
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
      return GuardDecision.blocked(S.current.booksNoPermissionSetDefaultBook);
    }
    if (inRecycleBin) {
      return GuardDecision.blocked(S.current.booksRestoreBookFirst);
    }
    if (!book.enable) {
      return GuardDecision.blocked(S.current.booksEnableBookBeforeDefault);
    }
    if (isDefaultBook(book, defaultBookId)) {
      return GuardDecision.blocked(S.current.booksAlreadyDefaultBook);
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
      return GuardDecision.blocked(S.current.booksNoPermissionToggleBook);
    }
    if (targetEnable) {
      if (book.enable) {
        return GuardDecision.blocked(S.current.booksBookAlreadyEnabled);
      }
      return const GuardDecision.allowed();
    }
    if (!book.enable) {
      return GuardDecision.blocked(S.current.booksBookAlreadyDisabled);
    }
    if (isDefaultBook(book, defaultBookId)) {
      return GuardDecision.blocked(S.current.booksSetOtherDefaultBookFirst);
    }
    if (enabledActiveBookCount <= 1) {
      return GuardDecision.blocked(S.current.booksOnlyAvailableBook);
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
      return GuardDecision.blocked(S.current.booksNoPermissionMoveBook);
    }
    if (isDefaultBook(book, defaultBookId)) {
      return GuardDecision.blocked(S.current.booksSetOtherDefaultBookFirst);
    }
    if (book.enable && enabledActiveBookCount <= 1) {
      return GuardDecision.blocked(S.current.booksOnlyAvailableBook);
    }
    return const GuardDecision.allowed();
  }

  static GuardDecision canRestore({required ManageCapabilities capabilities}) {
    if (!capabilities.canEdit) {
      return GuardDecision.blocked(S.current.booksNoPermissionRestoreBook);
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
      return GuardDecision.blocked(S.current.booksNoPermissionDeleteBook);
    }
    if (isDefaultBook(book, defaultBookId)) {
      return GuardDecision.blocked(S.current.booksSetOtherDefaultBookFirst);
    }
    if (!inRecycleBin && book.enable && enabledActiveBookCount <= 1) {
      return GuardDecision.blocked(S.current.booksOnlyAvailableBook);
    }
    return const GuardDecision.allowed();
  }
}
