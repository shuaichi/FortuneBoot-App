import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';

/// 分类数据服务 /fortune/category（树形，无 can* 开关）。
class CategoryService {
  final FxApi _api = FxApi.instance;

  /// 拉取分类树：GET /fortune/category/getList?bookId&recycleBin。
  ///
  /// 回收站改走平铺 [getFlatList] 再本地建林，避免仅二级分类进回收站时
  /// 后端旧版 TreeUtil 因父节点不在结果集而丢弃节点。
  Future<List<FortuneCategoryVo>> getList({
    required int bookId,
    bool recycleBin = false,
  }) async {
    if (recycleBin) {
      return buildForest(await getFlatList(bookId: bookId, recycleBin: true));
    }
    final data = await _api.get(
      '/fortune/category/getList',
      query: {'bookId': bookId, 'recycleBin': recycleBin},
    );
    return _parseTree(data);
  }

  /// 平铺分页：GET /fortune/category/getListPage（回收站等场景用）。
  Future<List<FortuneCategoryVo>> getFlatList({
    required int bookId,
    bool recycleBin = false,
    int pageSize = 200,
  }) async {
    final all = <FortuneCategoryVo>[];
    var pageNum = 1;
    var total = 0;
    while (true) {
      final data = await _api.get(
        '/fortune/category/getListPage',
        query: {
          'bookId': bookId,
          'recycleBin': recycleBin,
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );
      if (data is! Map) break;
      final rowsRaw =
          (data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[])
              as List<dynamic>;
      final rows = rowsRaw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => FortuneCategoryVo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      all.addAll(rows);
      total = FxApi.asId(data['total']) ?? all.length;
      if (rows.isEmpty || all.length >= total) break;
      pageNum++;
    }
    return all;
  }

  /// 将平铺节点建林：父节点缺失时提升为根（与后端 TreeUtil 修复一致）。
  static List<FortuneCategoryVo> buildForest(List<FortuneCategoryVo> flat) {
    if (flat.isEmpty) return const [];
    final childrenMap = <int, List<FortuneCategoryVo>>{};
    for (final node in flat) {
      final id = node.categoryId;
      if (id == null) continue;
      childrenMap.putIfAbsent(id, () => []);
    }
    final roots = <FortuneCategoryVo>[];
    final idSet = flat.map((e) => e.categoryId).whereType<int>().toSet();
    for (final node in flat) {
      final id = node.categoryId;
      if (id == null) continue;
      final parentId = node.parentId;
      final isRoot = parentId == null || parentId == -1 || !idSet.contains(parentId);
      if (isRoot) {
        roots.add(node);
      } else {
        childrenMap.putIfAbsent(parentId, () => []).add(node);
      }
    }
    FortuneCategoryVo attach(FortuneCategoryVo node) {
      final id = node.categoryId;
      final kids = id == null ? const <FortuneCategoryVo>[] : childrenMap[id] ?? const [];
      return node.copyWith(children: kids.map(attach).toList());
    }
    return roots.map(attach).toList();
  }

  List<FortuneCategoryVo> _parseTree(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => FortuneCategoryVo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 新增：POST /fortune/category/add。
  Future<void> add(Map<String, dynamic> body) =>
      _api.post('/fortune/category/add', data: body);

  /// 修改：PUT /fortune/category/modify（body 含 categoryId）。
  Future<void> modify(Map<String, dynamic> body) =>
      _api.put('/fortune/category/modify', data: body);

  /// 开关/回收站切换：PATCH /fortune/category/{bookId}/{categoryId}/{action}。
  Future<void> toggle({
    required int bookId,
    required int categoryId,
    required String action,
  }) => _api.patch('/fortune/category/$bookId/$categoryId/$action');

  Future<void> moveToRecycleBin({
    required int bookId,
    required int categoryId,
  }) => toggle(
    bookId: bookId,
    categoryId: categoryId,
    action: 'moveToRecycleBin',
  );

  Future<void> putBack({required int bookId, required int categoryId}) =>
      toggle(bookId: bookId, categoryId: categoryId, action: 'putBack');

  /// 彻底删除：DELETE /fortune/category/{bookId}/{categoryId}/remove。
  Future<void> remove({required int bookId, required int categoryId}) =>
      _api.delete('/fortune/category/$bookId/$categoryId/remove');
}
