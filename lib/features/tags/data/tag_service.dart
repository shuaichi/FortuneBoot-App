import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';

/// 标签数据服务 /fortune/tag（树形，含 can* 开关）。
class TagService {
  final FxApi _api = FxApi.instance;

  /// 拉取标签树：GET /fortune/tag/getList?bookId&recycleBin。
  ///
  /// 回收站改走平铺 [getFlatList] 再本地建林，避免仅二级标签进回收站时被丢弃。
  Future<List<FortuneTagVo>> getList({
    required int bookId,
    bool recycleBin = false,
  }) async {
    if (recycleBin) {
      return buildForest(await getFlatList(bookId: bookId, recycleBin: true));
    }
    final data = await _api.get(
      '/fortune/tag/getList',
      query: {'bookId': bookId, 'recycleBin': recycleBin},
    );
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => FortuneTagVo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 平铺分页：GET /fortune/tag/getListPage。
  Future<List<FortuneTagVo>> getFlatList({
    required int bookId,
    bool recycleBin = false,
    int pageSize = 200,
  }) async {
    final all = <FortuneTagVo>[];
    var pageNum = 1;
    var total = 0;
    while (true) {
      final data = await _api.get(
        '/fortune/tag/getListPage',
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
          .map((e) => FortuneTagVo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      all.addAll(rows);
      total = FxApi.asId(data['total']) ?? all.length;
      if (rows.isEmpty || all.length >= total) break;
      pageNum++;
    }
    return all;
  }

  /// 将平铺节点建林：父节点缺失时提升为根。
  static List<FortuneTagVo> buildForest(List<FortuneTagVo> flat) {
    if (flat.isEmpty) return const [];
    final childrenMap = <int, List<FortuneTagVo>>{};
    for (final node in flat) {
      final id = node.tagId;
      if (id == null) continue;
      childrenMap.putIfAbsent(id, () => []);
    }
    final roots = <FortuneTagVo>[];
    final idSet = flat.map((e) => e.tagId).whereType<int>().toSet();
    for (final node in flat) {
      final id = node.tagId;
      if (id == null) continue;
      final parentId = node.parentId;
      final isRoot =
          parentId == null || parentId == -1 || !idSet.contains(parentId);
      if (isRoot) {
        roots.add(node);
      } else {
        childrenMap.putIfAbsent(parentId, () => []).add(node);
      }
    }
    FortuneTagVo attach(FortuneTagVo node) {
      final id = node.tagId;
      final kids =
          id == null ? const <FortuneTagVo>[] : childrenMap[id] ?? const [];
      return node.copyWith(children: kids.map(attach).toList());
    }

    return roots.map(attach).toList();
  }

  Future<void> add(Map<String, dynamic> body) =>
      _api.post('/fortune/tag/add', data: body);

  Future<void> modify(Map<String, dynamic> body) =>
      _api.put('/fortune/tag/modify', data: body);

  /// 开关/回收站切换：PATCH /fortune/tag/{bookId}/{tagId}/{action}。
  Future<void> toggle({
    required int bookId,
    required int tagId,
    required String action,
  }) => _api.patch('/fortune/tag/$bookId/$tagId/$action');

  Future<void> moveToRecycleBin({required int bookId, required int tagId}) =>
      toggle(bookId: bookId, tagId: tagId, action: 'moveToRecycleBin');

  Future<void> putBack({required int bookId, required int tagId}) =>
      toggle(bookId: bookId, tagId: tagId, action: 'putBack');

  Future<void> remove({required int bookId, required int tagId}) =>
      _api.delete('/fortune/tag/$bookId/$tagId/remove');
}
