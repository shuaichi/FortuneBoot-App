part of 'session_cubit.dart';

enum SessionStatus { initial, loading, ready, empty, error }

class SessionState extends Equatable {
  final SessionStatus status;
  final List<FortuneGroupVo> groups;
  final FortuneGroupVo? currentGroup;
  final List<FortuneBookVo> books;
  final FortuneBookVo? currentBook;
  final String? errorMessage;

  const SessionState({
    this.status = SessionStatus.initial,
    this.groups = const [],
    this.currentGroup,
    this.books = const [],
    this.currentBook,
    this.errorMessage,
  });

  int? get currentGroupId => currentGroup?.groupId;
  int? get currentBookId => currentBook?.bookId;
  String? get defaultCurrency =>
      currentBook?.defaultCurrency ?? currentGroup?.defaultCurrency;

  SessionState copyWith({
    SessionStatus? status,
    List<FortuneGroupVo>? groups,
    FortuneGroupVo? currentGroup,
    List<FortuneBookVo>? books,
    FortuneBookVo? currentBook,
    String? errorMessage,
  }) {
    return SessionState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      currentGroup: currentGroup ?? this.currentGroup,
      books: books ?? this.books,
      currentBook: currentBook ?? this.currentBook,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    currentGroup,
    books,
    currentBook,
    errorMessage,
  ];
}
