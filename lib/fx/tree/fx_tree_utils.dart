/// 树形结构通用工具，供 FxTreePicker 与业务层复用。
///
/// 通过访问器函数适配任意节点类型（分类 / 标签 / 目录等），
/// 不与具体模型耦合。
library;

/// 带深度的扁平节点。
class FxFlatNode<T> {
  final T node;
  final int depth;

  /// 从根到当前节点的名称路径（含自身）。
  final List<String> path;
  final bool hasChildren;

  const FxFlatNode({
    required this.node,
    required this.depth,
    required this.path,
    required this.hasChildren,
  });

  String get pathLabel => path.join(' / ');
}

/// 深度优先展开整棵树（含每个节点自身），保留深度与路径。
///
/// [childrenOf] 返回子节点；[labelOf] 返回节点显示名。
List<FxFlatNode<T>> flattenTreeWithDepth<T>(
  List<T> roots, {
  required List<T> Function(T node) childrenOf,
  required String Function(T node) labelOf,
}) {
  final result = <FxFlatNode<T>>[];

  void visit(T node, int depth, List<String> parentPath) {
    final children = childrenOf(node);
    final path = [...parentPath, labelOf(node)];
    result.add(
      FxFlatNode(
        node: node,
        depth: depth,
        path: path,
        hasChildren: children.isNotEmpty,
      ),
    );
    for (final child in children) {
      visit(child, depth + 1, path);
    }
  }

  for (final root in roots) {
    visit(root, 0, const []);
  }
  return result;
}

/// 仅展开叶子节点（无子节点者），保留完整路径。
List<FxFlatNode<T>> flattenLeavesWithPath<T>(
  List<T> roots, {
  required List<T> Function(T node) childrenOf,
  required String Function(T node) labelOf,
}) {
  return flattenTreeWithDepth(
    roots,
    childrenOf: childrenOf,
    labelOf: labelOf,
  ).where((f) => !f.hasChildren).toList();
}

/// 按关键字过滤扁平列表：匹配路径任意一段即保留。
List<FxFlatNode<T>> filterFlat<T>(List<FxFlatNode<T>> flat, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return flat;
  return flat.where((f) => f.pathLabel.toLowerCase().contains(q)).toList();
}
