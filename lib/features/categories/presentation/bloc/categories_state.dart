part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, loaded, error, empty }

class CategoriesState extends Equatable {
  final CategoriesStatus status;

  /// 当前 recycleBin 维度下的完整树（未按 enable/搜索过滤）。
  final List<FortuneCategoryVo> tree;
  final ManageTab tab;
  final String keyword;
  final Set<int> expandedIds;
  final Set<int> searchCollapsedIds;
  final String? errorMessage;
  final String? toastMessage;

  CategoriesState({
    this.status = CategoriesStatus.initial,
    this.tree = const [],
    this.tab = ManageTab.all,
    this.keyword = '',
    this.expandedIds = const {},
    this.searchCollapsedIds = const {},
    this.errorMessage,
    this.toastMessage,
  });

  late final _projection = _CategoryTreeProjection(
    tree: tree,
    enableFilter: tab.enableFilter,
    keyword: keyword,
  );

  /// 按 tab（enable）+ 搜索词过滤后的树，并保留命中后代的祖先路径。
  List<FortuneCategoryVo> get filtered => _projection.tree;

  /// 搜索态下需要自动展开、以展示命中后代的祖先节点。
  Set<int> get autoExpandedIds => _projection.autoExpandedIds;

  /// 当前搜索词下一个分支中的匹配结果数量。
  int matchCountFor(int? categoryId) => _projection.matchCountFor(categoryId);

  bool isExpanded(int? categoryId) {
    if (categoryId == null) return false;
    final isSearchActive = keyword.trim().isNotEmpty;
    final automaticallyExpanded =
        isSearchActive && autoExpandedIds.contains(categoryId);
    return (expandedIds.contains(categoryId) || automaticallyExpanded) &&
        !searchCollapsedIds.contains(categoryId);
  }

  /// 支出分类根节点（categoryType==1 或未标注）。
  List<FortuneCategoryVo> get expenseRoots =>
      filtered.where((c) => c.categoryType != 2).toList();

  /// 收入分类根节点（categoryType==2）。
  List<FortuneCategoryVo> get incomeRoots =>
      filtered.where((c) => c.categoryType == 2).toList();

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<FortuneCategoryVo>? tree,
    ManageTab? tab,
    String? keyword,
    Set<int>? expandedIds,
    Set<int>? searchCollapsedIds,
    String? errorMessage,
    String? toastMessage,
  }) {
    return CategoriesState(
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

class _CategoryTreeProjection {
  _CategoryTreeProjection({
    required List<FortuneCategoryVo> tree,
    required bool? enableFilter,
    required String keyword,
  }) : _isSearchActive = keyword.trim().isNotEmpty {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final projection = _projectNodes(tree, enableFilter, normalizedKeyword);
    this.tree = projection.nodes;
    _matchCounts = projection.matchCounts;
    autoExpandedIds = projection.autoExpandedIds;
  }

  late final List<FortuneCategoryVo> tree;
  late final Map<int, int> _matchCounts;
  late final Set<int> autoExpandedIds;
  final bool _isSearchActive;

  int matchCountFor(int? categoryId) =>
      categoryId == null ? 0 : _matchCounts[categoryId] ?? 0;

  _CategoryProjectionResult _projectNodes(
    List<FortuneCategoryVo> nodes,
    bool? enableFilter,
    String keyword,
  ) {
    final result = <FortuneCategoryVo>[];
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
          (node.categoryName?.toLowerCase().contains(keyword) ?? false);
      final selfMatches = enableMatches && nameMatches;
      final matchedDescendantCount = childrenProjection.totalMatches;
      if (!selfMatches && childrenProjection.nodes.isEmpty) continue;

      final nodeId = node.categoryId;
      final matchCount = (selfMatches ? 1 : 0) + matchedDescendantCount;
      totalMatches += matchCount;
      if (_isSearchActive && nodeId != null && matchedDescendantCount > 0) {
        autoExpandedIds.add(nodeId);
      }
      if (nodeId != null && matchCount > 0) {
        matchCounts[nodeId] = matchCount;
      }
      matchCounts.addAll(childrenProjection.matchCounts);
      autoExpandedIds.addAll(childrenProjection.autoExpandedIds);
      result.add(node.copyWith(children: childrenProjection.nodes));
    }

    return _CategoryProjectionResult(
      nodes: result,
      matchCounts: matchCounts,
      autoExpandedIds: autoExpandedIds,
      totalMatches: totalMatches,
    );
  }
}

class _CategoryProjectionResult {
  const _CategoryProjectionResult({
    required this.nodes,
    required this.matchCounts,
    required this.autoExpandedIds,
    required this.totalMatches,
  });

  final List<FortuneCategoryVo> nodes;
  final Map<int, int> matchCounts;
  final Set<int> autoExpandedIds;
  final int totalMatches;
}
