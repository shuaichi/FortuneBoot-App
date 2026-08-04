import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';

/// 归物数据服务：分页 / 统计 / 新增(multipart) / 修改(multipart) / 删除，
/// 以及分类/标签下拉选项。全部走 [FxApi.instance]。
class GoodsService {
  final FxApi _api = FxApi.instance;

  static const String _base = '/fortune/goods/keeper';

  /// 分页列表。
  Future<GoodsPage> getPage({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    String? goodsName,
    int? categoryId,
    int? tagId,
    int? status,
  }) async {
    final query = <String, dynamic>{
      'bookId': bookId,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (goodsName != null && goodsName.trim().isNotEmpty) {
      query['goodsName'] = goodsName.trim();
    }
    if (categoryId != null) query['categoryId'] = categoryId;
    if (tagId != null) query['tagId'] = tagId;
    if (status != null) query['status'] = status;
    final data = await _api.get('$_base/getPage', query: query);
    return _parsePage(data);
  }

  GoodsPage _parsePage(dynamic data) {
    if (data is Map) {
      final rowsRaw =
          data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[];
      final rows = (rowsRaw as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (e) => FortuneGoodsKeeperVo.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      final total = FxApi.asId(data['total']) ?? rows.length;
      return GoodsPage(rows: rows, total: total);
    }
    if (data is List) {
      final rows = data
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (e) => FortuneGoodsKeeperVo.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      return GoodsPage(rows: rows, total: rows.length);
    }
    return const GoodsPage();
  }

  /// 统计条：GET /fortune/goods/keeper/{bookId}/getGoodsKeeperStatistics。
  Future<GoodsStatistics> getStatistics(int bookId) async {
    final data = await _api.get('$_base/$bookId/getGoodsKeeperStatistics');
    if (data is Map) {
      return GoodsStatistics.fromJson(Map<String, dynamic>.from(data));
    }
    return const GoodsStatistics();
  }

  /// 删除：DELETE /fortune/goods/keeper/{bookId}/{keeperId}/remove。
  Future<void> remove({required int bookId, required int keeperId}) =>
      _api.delete('$_base/$bookId/$keeperId/remove');

  /// 新增/编辑（multipart: data JSON part + 可选 files）。
  Future<void> submit(
    Map<String, dynamic> data, {
    required bool modify,
    List<File>? files,
  }) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(data),
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );
    if (files != null) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }
    }
    final path = modify ? '$_base/modify' : '$_base/add';
    final res = modify
        ? await _api.dio.put<dynamic>(
            path,
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          )
        : await _api.dio.post<dynamic>(
            path,
            data: formData,
            options: Options(contentType: 'multipart/form-data'),
          );
    FxApi.unwrapRaw(res);
  }

  /// 分类下拉（复用账单分类 getEnableList；扁平化叶子）。
  Future<List<GoodsOption>> getCategoryOptions(int bookId) async {
    // 支出分类通常覆盖“物品”类目；billType=1。
    final data = await _api.get(
      '/fortune/category/$bookId/getEnableList',
      query: {'billType': 1},
    );
    return _flattenOptions(data, idKey: 'categoryId', nameKey: 'categoryName');
  }

  /// 标签下拉（复用 tag getEnableList；扁平化）。
  Future<List<GoodsOption>> getTagOptions(int bookId) async {
    final data = await _api.get(
      '/fortune/tag/$bookId/getEnableList',
      query: {'billType': ''},
    );
    return _flattenOptions(data, idKey: 'tagId', nameKey: 'tagName');
  }

  List<GoodsOption> _flattenOptions(
    dynamic data, {
    required String idKey,
    required String nameKey,
  }) {
    final out = <GoodsOption>[];
    void walk(Map<String, dynamic> node) {
      final id = FxApi.asId(node[idKey]);
      final name = node[nameKey]?.toString();
      if (id != null && name != null) {
        out.add(GoodsOption(id: id, name: name));
      }
      final children = node['children'];
      if (children is List) {
        for (final c in children.whereType<Map<dynamic, dynamic>>()) {
          walk(Map<String, dynamic>.from(c));
        }
      }
    }

    if (data is List) {
      for (final e in data.whereType<Map<dynamic, dynamic>>()) {
        walk(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }
}
