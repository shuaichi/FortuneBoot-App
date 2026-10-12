import 'package:dio/dio.dart';
import 'package:hjproject/util/dio_client.dart';
import '../model/tag_node.dart';

class TagPageService {
  final Dio _dio = DioClient().dio;

  Future<TagPageData> fetch({
    required int bookId,
    required int pageNum,
    bool recycleBin = false,
  }) async {
    final response = await _dio.get(
      '/fortune/tag/getPage',
      queryParameters: {
        'bookId': bookId,
        'recycleBin': recycleBin,
        'pageNum': pageNum,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final d = data['data'] as Map<String, dynamic>? ?? {};
        return TagPageData.fromJson(d);
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  Future<void> moveToRecycleBin({
    required int bookId,
    required int tagId,
  }) async {
    final response = await _dio.patch(
      '/fortune/tag/$bookId/$tagId/moveToRecycleBin',
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return;
      } else {
        final msg = data['msg']?.toString() ?? '操作失败';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  Future<void> modifyTag({
    required bool enable,
    required int tagId,
    required String tagName,
    required int bookId,
    required int parentId,
    required int sort,
    required bool canExpense,
    required bool canIncome,
    required bool canTransfer,
    String? remark,
    String? icon,
    bool recycleBin = false,
  }) async {
    final payload = {
      'enable': enable,
      'tagId': tagId,
      'tagName': tagName,
      'bookId': bookId,
      'parentId': parentId,
      'sort': sort,
      'canExpense': canExpense,
      'canIncome': canIncome,
      'canTransfer': canTransfer,
      'remark': remark,
      'icon': icon,
      'recycleBin': recycleBin,
      'id': tagId,
    };
    final response = await _dio.put(
      '/fortune/tag/modify',
      data: payload,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return;
      } else {
        final msg = data['msg']?.toString() ?? '操作失败';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  Future<void> addTag({
    required bool enable,
    required int parentId,
    required String tagName,
    required int bookId,
    required bool canExpense,
    required bool canIncome,
    required bool canTransfer,
    int sort = 0,
    String? remark,
    String? icon,
  }) async {
    final payload = {
      'enable': enable,
      'parentId': parentId,
      'tagName': tagName,
      'sort': sort,
      'remark': remark,
      'icon': icon,
      'bookId': bookId,
      'canExpense': canExpense,
      'canIncome': canIncome,
      'canTransfer': canTransfer,
    };
    final response = await _dio.post(
      '/fortune/tag/add',
      data: payload,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        return;
      } else {
        final msg = data['msg']?.toString() ?? '操作失败';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }

  Future<List<TagNode>> fetchList({
    required int bookId,
    required bool recycleBin,
  }) async {
    final response = await _dio.get(
      '/fortune/tag/getList',
      queryParameters: {
        'bookId': bookId,
        'recycleBin': recycleBin,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final list = (data['data'] as List? ?? []);
        return list
            .map((e) => TagNode.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final msg = data['msg']?.toString() ?? '服务返回错误';
        throw Exception(msg);
      }
    } else {
      throw Exception('网络错误: ${response.statusCode}');
    }
  }
}