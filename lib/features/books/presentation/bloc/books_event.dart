part of 'books_bloc.dart';

/// 账本/分组管理事件。
sealed class BooksEvent extends Equatable {
  const BooksEvent();

  @override
  List<Object?> get props => [];
}

/// 首次加载 / 刷新：拉分组列表 + 当前分组账本（正常+回收站）。
class BooksLoaded extends BooksEvent {
  const BooksLoaded();
}

/// 选中某分组查看其账本（分组管理内部选择，不改全局 Session）。
class BooksGroupSelected extends BooksEvent {
  final int groupId;
  const BooksGroupSelected(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// 写操作成功后重拉。
class BooksMutated extends BooksEvent {
  const BooksMutated();
}
