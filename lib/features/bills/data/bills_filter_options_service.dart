import 'package:fortuneboot/core/network/fx_api.dart';

/// 筛选用树节点（分类 / 标签），供 [FxTreePicker] 缩进展开。
class BillsFilterTreeNode {
  const BillsFilterTreeNode({
    this.id,
    required this.label,
    this.children = const [],
  });

  final int? id;
  final String label;
  final List<BillsFilterTreeNode> children;

  bool get hasChildren => children.isNotEmpty;
}

class BillsFilterOption {
  const BillsFilterOption({required this.id, required this.label});

  final int id;
  final String label;
}

class BillsFilterOptions {
  const BillsFilterOptions({
    this.categoryTrees = const [],
    this.tagTrees = const [],
    this.accounts = const [],
    this.payees = const [],
  });

  final List<BillsFilterTreeNode> categoryTrees;
  final List<BillsFilterTreeNode> tagTrees;
  final List<BillsFilterOption> accounts;
  final List<BillsFilterOption> payees;

  /// 扁平化树，便于摘要展示。
  static List<BillsFilterOption> flatten(List<BillsFilterTreeNode> roots) {
    final out = <BillsFilterOption>[];
    void walk(BillsFilterTreeNode node) {
      final id = node.id;
      if (id != null && node.label.isNotEmpty) {
        out.add(BillsFilterOption(id: id, label: node.label));
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    for (final root in roots) {
      walk(root);
    }
    return out;
  }
}

/// Bills 筛选候选数据，仅使用已存在的启用项接口。
class BillsFilterOptionsService {
  BillsFilterOptionsService({FxApi? api}) : _api = api ?? FxApi.instance;

  final FxApi _api;

  Future<BillsFilterOptions> load({
    required int bookId,
    required int groupId,
  }) async {
    final results = await Future.wait([
      _api.get(
        '/fortune/category/$bookId/getEnableList',
        query: {'billType': 1},
      ),
      _api.get(
        '/fortune/category/$bookId/getEnableList',
        query: {'billType': 2},
      ),
      _api.get('/fortune/tag/$bookId/getEnableList', query: {'billType': ''}),
      _api.get('/fortune/account/$groupId/getEnableList'),
      _api.get('/fortune/payee/$bookId/getEnableList', query: {'billType': ''}),
    ]);
    return BillsFilterOptions(
      categoryTrees: _mergeTrees([
        _parseTree(results[0], 'categoryId', 'categoryName'),
        _parseTree(results[1], 'categoryId', 'categoryName'),
      ]),
      tagTrees: _parseTree(results[2], 'tagId', 'tagName'),
      accounts: _flatOptions(results[3], 'accountId', 'accountName'),
      payees: _flatOptions(results[4], 'payeeId', 'payeeName'),
    );
  }

  List<BillsFilterTreeNode> _mergeTrees(List<List<BillsFilterTreeNode>> sources) {
    final roots = <BillsFilterTreeNode>[];
    final seen = <int>{};
    for (final list in sources) {
      for (final node in list) {
        final id = node.id;
        if (id != null && !seen.add(id)) continue;
        roots.add(node);
      }
    }
    return List.unmodifiable(roots);
  }

  List<BillsFilterTreeNode> _parseTree(
    dynamic source,
    String idKey,
    String labelKey,
  ) {
    if (source is! List) return const [];
    return List.unmodifiable(
      source
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => _nodeFromMap(Map<String, dynamic>.from(e), idKey, labelKey))
          .toList(),
    );
  }

  BillsFilterTreeNode _nodeFromMap(
    Map<String, dynamic> item,
    String idKey,
    String labelKey,
  ) {
    final childrenRaw = item['children'];
    final children = childrenRaw is List
        ? childrenRaw
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (e) => _nodeFromMap(
                  Map<String, dynamic>.from(e),
                  idKey,
                  labelKey,
                ),
              )
              .toList()
        : const <BillsFilterTreeNode>[];
    return BillsFilterTreeNode(
      id: FxApi.asId(item[idKey] ?? item['id']),
      label: item[labelKey]?.toString().trim() ?? '',
      children: List.unmodifiable(children),
    );
  }

  List<BillsFilterOption> _flatOptions(
    dynamic source,
    String idKey,
    String labelKey,
  ) {
    final options = <BillsFilterOption>[];
    final ids = <int>{};

    void walk(dynamic node) {
      if (node is List) {
        for (final item in node) {
          walk(item);
        }
        return;
      }
      if (node is! Map) return;
      final item = Map<String, dynamic>.from(node);
      final id = FxApi.asId(item[idKey] ?? item['id']);
      final label = item[labelKey]?.toString().trim() ?? '';
      if (id != null && label.isNotEmpty && ids.add(id)) {
        options.add(BillsFilterOption(id: id, label: label));
      }
      walk(item['children']);
    }

    walk(source);
    return List.unmodifiable(options);
  }
}
