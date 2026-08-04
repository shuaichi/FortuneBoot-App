part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, loaded, error, empty }

class CategoriesState extends Equatable {
  final CategoriesStatus status;

  /// 当前 recycleBin 维度下的完整树（未按 enable/搜索过滤）。
  final List<FortuneCategoryVo> tree;
  final ManageTab tab;
  final String keyword;
  final String? errorMessage;
  final String? toastMessage;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.tree = const [],
    this.tab = ManageTab.all,
    this.keyword = '',
    this.errorMessage,
    this.toastMessage,
  });

  /// 按 tab（enable）+ 搜索词过滤后的树。
  /// 节点保留条件：自身匹配，或任一后代匹配（保留祖先路径）。
  List<FortuneCategoryVo> get filtered {
    final enableFilter = tab.enableFilter;
    final kw = keyword.trim().toLowerCase();
    List<FortuneCategoryVo> filterNodes(List<FortuneCategoryVo> nodes) {
      final result = <FortuneCategoryVo>[];
      for (final node in nodes) {
        final children = filterNodes(node.children);
        final selfEnableOk =
            enableFilter == null || node.enable == enableFilter;
        final selfNameOk =
            kw.isEmpty ||
            (node.categoryName?.toLowerCase().contains(kw) ?? false);
        final selfOk = selfEnableOk && selfNameOk;
        if (selfOk || children.isNotEmpty) {
          result.add(node.copyWith(children: children));
        }
      }
      return result;
    }

    return filterNodes(tree);
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
    String? errorMessage,
    String? toastMessage,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      tree: tree ?? this.tree,
      tab: tab ?? this.tab,
      keyword: keyword ?? this.keyword,
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
    errorMessage,
    toastMessage,
  ];
}
