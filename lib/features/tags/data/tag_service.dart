import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';

/// 标签数据服务 /fortune/tag（树形，含 can* 开关）。
class TagService {
  final FxApi _api = FxApi.instance;

  /// 拉取标签树：GET /fortune/tag/getList?bookId&recycleBin。
  Future<List<FortuneTagVo>> getList({
    required int bookId,
    bool recycleBin = false,
  }) async {
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
