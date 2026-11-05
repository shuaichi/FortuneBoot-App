part of 'session_cubit.dart';

enum SessionStatus { initial, loading, ready, empty, error }

class SessionState extends Equatable {
  final SessionStatus status;
  final List<FortuneGroupVo> groups;
  final FortuneGroupVo? currentGroup;
  final List<FortuneBookVo> books;
  final FortuneBookVo? currentBook;

  /// 正在尝试切换到的分组。
  ///
  /// [currentGroup] / [currentBook] 始终代表页面实际绑定的范围；切换请求完成前
  /// 不提前改名，避免旧账本数据被展示成新分组的内容。
  final FortuneGroupVo? pendingGroup;

  final String? errorMessage;
  final FxFailure? failure;

  const SessionState({
    this.status = SessionStatus.initial,
    this.groups = const [],
    this.currentGroup,
    this.books = const [],
    this.currentBook,
    this.pendingGroup,
    this.errorMessage,
    this.failure,
  });

  int? get currentGroupId => currentGroup?.groupId;
  int? get currentBookId => currentBook?.bookId;
  String? get defaultCurrency =>
      currentBook?.defaultCurrency ?? currentGroup?.defaultCurrency;

  /// 当前范围有合法旧内容、正在刷新时，页面可以继续展示旧内容但必须标注更新中。
  bool get isRefreshing => status == SessionStatus.loading;

  static const Object _unset = Object();

  SessionState copyWith({
    SessionStatus? status,
    List<FortuneGroupVo>? groups,
    Object? currentGroup = _unset,
    List<FortuneBookVo>? books,
    Object? currentBook = _unset,
    Object? pendingGroup = _unset,
    Object? errorMessage = _unset,
    Object? failure = _unset,
  }) {
    return SessionState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      currentGroup: identical(currentGroup, _unset)
          ? this.currentGroup
          : currentGroup as FortuneGroupVo?,
      books: books ?? this.books,
      currentBook: identical(currentBook, _unset)
          ? this.currentBook
          : currentBook as FortuneBookVo?,
      pendingGroup: identical(pendingGroup, _unset)
          ? this.pendingGroup
          : pendingGroup as FortuneGroupVo?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as FxFailure?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    currentGroup,
    books,
    currentBook,
    pendingGroup,
    errorMessage,
    failure,
  ];
}
