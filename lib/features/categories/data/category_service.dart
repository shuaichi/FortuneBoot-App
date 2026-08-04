import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';

/// 分类数据服务 /fortune/category（树形，无 can* 开关）。
class CategoryService {
  final FxApi _api = FxApi.instance;

  /// 拉取分类树：GET /fortune/category/getList?bookId&recycleBin。
  Future<List<FortuneCategoryVo>> getList({
    required int bookId,
    bool recycleBin = false,
  }) async {
    final data = await _api.get(
      '/fortune/category/getList',
      query: {'bookId': bookId, 'recycleBin': recycleBin},
    );
    return _parseTree(data);
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
