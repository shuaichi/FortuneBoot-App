import 'package:dio/dio.dart';
import 'package:hjproject/util/dio_client.dart';

class CategoryPageService {
  final Dio _dio = DioClient().dio;

  Future<CategoryPageData> fetch({
    required int bookId,
    required int categoryType,
    required int pageNum,
  }) async {
    final response = await _dio.get(
      '/fortune/category/getPage',
      queryParameters: {
        'bookId': bookId,
        'recycleBin': false,
        'categoryType': categoryType,
        'pageNum': pageNum,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final d = data['data'] as Map<String, dynamic>? ?? {};
        return CategoryPageData.fromJson(d);
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
    required int categoryId,
  }) async {
    final response = await _dio.patch(
      '/fortune/category/$bookId/$categoryId/moveToRecycleBin',
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

  Future<void> modifyCategory({
    required bool enable,
    required int categoryId,
    required String categoryName,
    required int categoryType,
    required int bookId,
    required int parentId,
    required int sort,
    String? remark,
    String? icon,
    bool recycleBin = false,
  }) async {
    final payload = {
      'enable': enable,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryType': categoryType,
      'bookId': bookId,
      'parentId': parentId,
      'sort': sort,
      'remark': remark,
      'icon': icon,
      'recycleBin': recycleBin,
      'id': categoryId,
    };
    final response = await _dio.put(
      '/fortune/category/modify',
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

  Future<void> addCategory({
    required bool enable,
    required int parentId,
    required String categoryName,
    required int categoryType,
    required int bookId,
    int sort = 0,
    String? remark,
    String? icon,
  }) async {
    final payload = {
      'enable': enable,
      'parentId': parentId,
      'categoryName': categoryName,
      'sort': sort,
      'remark': remark,
      'icon': icon,
      'bookId': bookId,
      'categoryType': categoryType,
    };
    final response = await _dio.post(
      '/fortune/category/add',
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

  Future<List<CategoryNode>> fetchList({
    required int bookId,
    required int categoryType,
    required bool recycleBin,
  }) async {
    final response = await _dio.get(
      '/fortune/category/getList',
      queryParameters: {
        'bookId': bookId,
        'categoryType': categoryType,
        'recycleBin': recycleBin,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data;
      final code = data['code'] as int? ?? -1;
      if (code == 0) {
        final list = (data['data'] as List? ?? []);
        return list
            .map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
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

class CategoryPageData {
  final int total;
  final List<CategoryNode> rows;

  CategoryPageData({required this.total, required this.rows});

  factory CategoryPageData.fromJson(Map<String, dynamic> json) {
    final total = json['total'] as int? ?? 0;
    final rowsList = (json['rows'] as List? ?? [])
        .map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
        .toList();
    return CategoryPageData(total: total, rows: rowsList);
  }
}

class CategoryNode {
  final int categoryId;
  final int id;
  final String categoryName;
  final int categoryType;
  final int bookId;
  final int parentId;
  final int sort;
  final String? remark;
  final bool enable;
  final bool recycleBin;
  final List<CategoryNode> children;

  /// 自定义图标名（Iconify 名称）；为空时使用默认图标
  final String? icon;

  CategoryNode({
    required this.categoryId,
    required this.id,
    required this.categoryName,
    required this.categoryType,
    required this.bookId,
    required this.parentId,
    required this.sort,
    required this.remark,
    required this.enable,
    required this.recycleBin,
    required this.children,
    this.icon,
  });

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    return CategoryNode(
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ??
          (json['categoryId'] as num?)?.toInt() ??
          0,
      categoryName: json['categoryName']?.toString() ?? '',
      categoryType: (json['categoryType'] as num?)?.toInt() ?? 1,
      bookId: (json['bookId'] as num?)?.toInt() ?? 0,
      parentId: (json['parentId'] as num?)?.toInt() ?? -1,
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      remark: json['remark']?.toString(),
      enable: json['enable'] as bool? ?? true,
      recycleBin: json['recycleBin'] as bool? ?? false,
      children: (json['children'] as List? ?? [])
          .map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      icon: json['icon']?.toString(),
    );
  }
}