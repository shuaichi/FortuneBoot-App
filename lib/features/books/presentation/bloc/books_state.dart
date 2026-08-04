part of 'books_bloc.dart';

enum BooksStatus { initial, loading, loaded, error }

/// 账本/分组管理状态。
///
/// [selectedGroupId] 是"账本管理"当前查看的分组（默认取当前会话分组）。
class BooksState extends Equatable {
  final BooksStatus status;
  final List<FortuneGroupVo> groups;
  final int? selectedGroupId;
  final List<FortuneBookVo> books; // 选中分组下正常账本
  final List<FortuneBookVo> recycledBooks; // 回收站账本
  final String? errorMessage;
  final String? toastMessage;

  const BooksState({
    this.status = BooksStatus.initial,
    this.groups = const [],
    this.selectedGroupId,
    this.books = const [],
    this.recycledBooks = const [],
    this.errorMessage,
    this.toastMessage,
  });

  FortuneGroupVo? get selectedGroup {
    for (final g in groups) {
      if (g.groupId == selectedGroupId) return g;
    }
    return groups.isEmpty ? null : groups.first;
  }

  BooksState copyWith({
    BooksStatus? status,
    List<FortuneGroupVo>? groups,
    int? selectedGroupId,
    List<FortuneBookVo>? books,
    List<FortuneBookVo>? recycledBooks,
    String? errorMessage,
    String? toastMessage,
  }) {
    return BooksState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      books: books ?? this.books,
      recycledBooks: recycledBooks ?? this.recycledBooks,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        groups,
        selectedGroupId,
        books,
        recycledBooks,
        errorMessage,
        toastMessage,
      ];
}
