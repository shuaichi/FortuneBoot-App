part of 'tags_bloc.dart';

enum TagsStatus { initial, loading, loaded, error, empty }

class TagsState extends Equatable {
  final TagsStatus status;
  final List<FortuneTagVo> tree;
  final ManageTab tab;
  final String keyword;
  final String? errorMessage;
  final String? toastMessage;

  const TagsState({
    this.status = TagsStatus.initial,
    this.tree = const [],
    this.tab = ManageTab.all,
    this.keyword = '',
    this.errorMessage,
    this.toastMessage,
  });

  /// 按 tab（enable）+ 搜索词过滤后的树（保留匹配后代的祖先）。
  List<FortuneTagVo> get filtered {
    final enableFilter = tab.enableFilter;
    final kw = keyword.trim().toLowerCase();
    List<FortuneTagVo> filterNodes(List<FortuneTagVo> nodes) {
      final result = <FortuneTagVo>[];
      for (final node in nodes) {
        final children = filterNodes(node.children);
        final selfEnableOk =
            enableFilter == null || node.enable == enableFilter;
        final selfNameOk =
            kw.isEmpty || (node.tagName?.toLowerCase().contains(kw) ?? false);
        if ((selfEnableOk && selfNameOk) || children.isNotEmpty) {
          result.add(node.copyWith(children: children));
        }
      }
      return result;
    }

    return filterNodes(tree);
  }

  TagsState copyWith({
    TagsStatus? status,
    List<FortuneTagVo>? tree,
    ManageTab? tab,
    String? keyword,
    String? errorMessage,
    String? toastMessage,
  }) {
    return TagsState(
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
