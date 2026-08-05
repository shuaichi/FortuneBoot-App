part of 'books_bloc.dart';

enum BooksStatus { initial, loading, loaded, error }

enum GroupFilter { all, enabled, disabled }

enum BooksSegment { active, recycleBin }

class BooksState extends Equatable {
  const BooksState({
    this.status = BooksStatus.initial,
    this.groups = const [],
    this.enabledGroups = const [],
    this.defaultGroupId,
    this.selectedGroupId,
    this.books = const [],
    this.recycledBooks = const [],
    this.enabledActiveBooks = const [],
    this.groupSearch = '',
    this.bookSearch = '',
    this.groupFilter = GroupFilter.all,
    this.bookSegment = BooksSegment.active,
    this.capabilitiesByGroupId = const {},
    this.errorMessage,
    this.groupsTotal,
    this.hasMoreGroups = false,
    this.currentUsername,
  });

  final BooksStatus status;
  final List<ManagedGroup> groups;
  final List<FortuneGroupVo> enabledGroups;
  final int? defaultGroupId;
  final int? selectedGroupId;
  final List<FortuneBookVo> books;
  final List<FortuneBookVo> recycledBooks;
  final List<FortuneBookVo> enabledActiveBooks;
  final String groupSearch;
  final String bookSearch;
  final GroupFilter groupFilter;
  final BooksSegment bookSegment;
  final Map<int, ManageCapabilities> capabilitiesByGroupId;
  final String? errorMessage;
  final int? groupsTotal;
  final bool hasMoreGroups;
  final String? currentUsername;

  ManagedGroup? get selectedManagedGroup {
    for (final group in groups) {
      if (group.groupId == selectedGroupId) return group;
    }
    return groups.isEmpty ? null : groups.first;
  }

  FortuneGroupVo? get selectedGroup => selectedManagedGroup?.group;

  ManageCapabilities capabilitiesFor(int? groupId) {
    if (groupId == null) return ManageCapabilities.visitor;
    return capabilitiesByGroupId[groupId] ?? ManageCapabilities.visitor;
  }

  List<ManagedGroup> get visibleGroups {
    final query = groupSearch.trim().toLowerCase();
    return groups
        .where((group) {
          final matchesFilter = switch (groupFilter) {
            GroupFilter.all => true,
            GroupFilter.enabled => group.enable,
            GroupFilter.disabled => !group.enable,
          };
          if (!matchesFilter) return false;
          if (query.isEmpty) return true;
          final text = [
            group.name,
            group.defaultCurrency,
            group.remark,
          ].whereType<String>().join(' ').toLowerCase();
          return text.contains(query);
        })
        .toList(growable: false);
  }

  List<FortuneBookVo> get visibleBooks {
    final source = bookSegment == BooksSegment.recycleBin
        ? recycledBooks
        : books;
    final query = bookSearch.trim().toLowerCase();
    if (query.isEmpty) return source;
    return source
        .where((book) {
          final text = [
            book.bookName,
            book.remark,
          ].whereType<String>().join(' ').toLowerCase();
          return text.contains(query);
        })
        .toList(growable: false);
  }

  BooksState copyWith({
    BooksStatus? status,
    List<ManagedGroup>? groups,
    List<FortuneGroupVo>? enabledGroups,
    Object? defaultGroupId = _sentinel,
    Object? selectedGroupId = _sentinel,
    List<FortuneBookVo>? books,
    List<FortuneBookVo>? recycledBooks,
    List<FortuneBookVo>? enabledActiveBooks,
    String? groupSearch,
    String? bookSearch,
    GroupFilter? groupFilter,
    BooksSegment? bookSegment,
    Map<int, ManageCapabilities>? capabilitiesByGroupId,
    Object? errorMessage = _sentinel,
    Object? groupsTotal = _sentinel,
    bool? hasMoreGroups,
    Object? currentUsername = _sentinel,
  }) {
    return BooksState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      enabledGroups: enabledGroups ?? this.enabledGroups,
      defaultGroupId: defaultGroupId == _sentinel
          ? this.defaultGroupId
          : defaultGroupId as int?,
      selectedGroupId: selectedGroupId == _sentinel
          ? this.selectedGroupId
          : selectedGroupId as int?,
      books: books ?? this.books,
      recycledBooks: recycledBooks ?? this.recycledBooks,
      enabledActiveBooks: enabledActiveBooks ?? this.enabledActiveBooks,
      groupSearch: groupSearch ?? this.groupSearch,
      bookSearch: bookSearch ?? this.bookSearch,
      groupFilter: groupFilter ?? this.groupFilter,
      bookSegment: bookSegment ?? this.bookSegment,
      capabilitiesByGroupId:
          capabilitiesByGroupId ?? this.capabilitiesByGroupId,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      groupsTotal: groupsTotal == _sentinel
          ? this.groupsTotal
          : groupsTotal as int?,
      hasMoreGroups: hasMoreGroups ?? this.hasMoreGroups,
      currentUsername: currentUsername == _sentinel
          ? this.currentUsername
          : currentUsername as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    enabledGroups,
    defaultGroupId,
    selectedGroupId,
    books,
    recycledBooks,
    enabledActiveBooks,
    groupSearch,
    bookSearch,
    groupFilter,
    bookSegment,
    capabilitiesByGroupId,
    errorMessage,
    groupsTotal,
    hasMoreGroups,
    currentUsername,
  ];
}

const Object _sentinel = Object();
