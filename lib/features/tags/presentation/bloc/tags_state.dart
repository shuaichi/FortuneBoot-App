part of 'tags_bloc.dart';

enum TagsStatus { initial, loading, loaded, error, empty }

class TagsState extends Equatable {
  final TagsStatus status;
  final List<FortuneTagVo> tree;
  final ManageTab tab;
  final String keyword;
  final Set<int> expandedIds;
  final Set<int> searchCollapsedIds;
  final String? errorMessage;
  final String? toastMessage;

  TagsState({
    this.status = TagsStatus.initial,
    this.tree = const [],
    this.tab = ManageTab.all,
    this.keyword = '',
    this.expandedIds = const {},
    this.searchCollapsedIds = const {},
    this.errorMessage,
    this.toastMessage,
  });

  late final _projection = _TagTreeProjection(
    tree: tree,
    enableFilter: tab.enableFilter,
    keyword: keyword,
  );

  /// 按 tab（enable）+ 搜索词过滤后的树（保留匹配后代的祖先）。
  List<FortuneTagVo> get filtered => _projection.tree;

  Set<int> get autoExpandedIds => _projection.autoExpandedIds;

  int matchCountFor(int? tagId) => _projection.matchCountFor(tagId);

  bool isExpanded(int? tagId) {
    if (tagId == null) return false;
    final automaticallyExpanded =
        keyword.trim().isNotEmpty && autoExpandedIds.contains(tagId);
    return (expandedIds.contains(tagId) || automaticallyExpanded) &&
        !searchCollapsedIds.contains(tagId);
  }

  TagsState copyWith({
    TagsStatus? status,
    List<FortuneTagVo>? tree,
    ManageTab? tab,
    String? keyword,
    Set<int>? expandedIds,
    Set<int>? searchCollapsedIds,
    String? errorMessage,
    String? toastMessage,
  }) {
    return TagsState(
      status: status ?? this.status,
      tree: tree ?? this.tree,
      tab: tab ?? this.tab,
      keyword: keyword ?? this.keyword,
      expandedIds: expandedIds ?? this.expandedIds,
      searchCollapsedIds: searchCollapsedIds ?? this.searchCollapsedIds,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tree,
    tab,
    keyword,
    expandedIds,
    searchCollapsedIds,
    errorMessage,
    toastMessage,
  ];
}

class _TagTreeProjection {
  _TagTreeProjection({
    required List<FortuneTagVo> tree,
    required bool? enableFilter,
    required String keyword,
  }) : _isSearchActive = keyword.trim().isNotEmpty {
    final projection = _projectNodes(
      tree,
      enableFilter,
      keyword.trim().toLowerCase(),
    );
    this.tree = projection.nodes;
    _matchCounts = projection.matchCounts;
    autoExpandedIds = projection.autoExpandedIds;
  }

  late final List<FortuneTagVo> tree;
  late final Map<int, int> _matchCounts;
  late final Set<int> autoExpandedIds;
  final bool _isSearchActive;

  int matchCountFor(int? tagId) => tagId == null ? 0 : _matchCounts[tagId] ?? 0;

  _TagProjectionResult _projectNodes(
    List<FortuneTagVo> nodes,
    bool? enableFilter,
    String keyword,
  ) {
    final result = <FortuneTagVo>[];
    final matchCounts = <int, int>{};
    final autoExpandedIds = <int>{};
    var totalMatches = 0;

    for (final node in nodes) {
      final childrenProjection = _projectNodes(
        node.children,
        enableFilter,
        keyword,
      );
      final enableMatches = enableFilter == null || node.enable == enableFilter;
      final nameMatches =
          keyword.isEmpty ||
          (node.tagName?.toLowerCase().contains(keyword) ?? false);
      final selfMatches = enableMatches && nameMatches;
      if (!selfMatches && childrenProjection.nodes.isEmpty) continue;

      final nodeId = node.tagId;
      final matchCount =
          (selfMatches ? 1 : 0) + childrenProjection.totalMatches;
      totalMatches += matchCount;
      if (_isSearchActive &&
          nodeId != null &&
          childrenProjection.totalMatches > 0) {
        autoExpandedIds.add(nodeId);
      }
      if (nodeId != null && matchCount > 0) matchCounts[nodeId] = matchCount;
      matchCounts.addAll(childrenProjection.matchCounts);
      autoExpandedIds.addAll(childrenProjection.autoExpandedIds);
      result.add(node.copyWith(children: childrenProjection.nodes));
    }

    return _TagProjectionResult(
      nodes: result,
      matchCounts: matchCounts,
      autoExpandedIds: autoExpandedIds,
      totalMatches: totalMatches,
    );
  }
}

class _TagProjectionResult {
  const _TagProjectionResult({
    required this.nodes,
    required this.matchCounts,
    required this.autoExpandedIds,
    required this.totalMatches,
  });

  final List<FortuneTagVo> nodes;
  final Map<int, int> matchCounts;
  final Set<int> autoExpandedIds;
  final int totalMatches;
}
