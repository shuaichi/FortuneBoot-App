import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/util/dio_client.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

import 'widgets/category_delete_confirm_dialog.dart';
import 'category_edit_page.dart';
import 'category_add_page.dart';
import 'widgets/category_list_view.dart';
import 'widgets/category_manage_appbar.dart';
import 'widgets/category_filter_bar.dart';
class CategoryManagePage extends StatefulWidget {
  const CategoryManagePage({Key? key}) : super(key: key);

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  static const int expenseType = 1;
  static const int incomeType = 2;

  int _categoryType = expenseType;
  int _currentPage = 1;
  int _total = 0;
  int _lastPageSize = 0;
  bool _loading = true;
  String? _error;
  List<CategoryNode> _roots = [];
  final Set<int> _expandedNodeIds = {};

  final CategoryPageService _service = CategoryPageService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      final data = await _service.fetch(
        bookId: bookId,
        categoryType: _categoryType,
        pageNum: _currentPage,
      );
      setState(() {
        _total = data.total;
        _roots = data.rows;
        _lastPageSize = data.rows.length;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _switchType(int type) {
    if (_categoryType == type) return;
    setState(() {
      _categoryType = type;
      _currentPage = 1;
    });
    _load();
  }

  bool get _hasPrev => _currentPage > 1;

  bool get _hasNext {
    if (_lastPageSize <= 0) return false;
    return _currentPage * _lastPageSize < _total;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double gap = width < 600 ? 8 : 12;
    return Scaffold(
      appBar: CategoryManageAppBar(
        onAddPressed: () => _openAddPage(initialParentId: -1),
      ),
      body: Column(
        children: [
          CategoryFilterBar(
            selectedType: _categoryType,
            onTypeChanged: (type) {
              _switchType(type);
            },
          ),
          SizedBox(height: gap),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _currentPage = 1;
                await _load();
              },
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildBody() {
    return CategoryListView<CategoryNode>(
      loading: _loading,
      error: _error,
      onRetry: _load,
      typeText: _categoryType == expenseType ? '支出' : '收入',
      total: _total,
      currentPage: _currentPage,
      roots: _roots,
      expandedNodeIds: _expandedNodeIds,
      childrenOf: (n) => n.children,
      nameOf: (n) => n.categoryName,
      remarkOf: (n) => n.remark,
      idOf: (n) => n.categoryId,
      iconOf: (n) => n.icon,
      onToggleNode: (node, expanded) {
        setState(() {
          if (expanded) {
            _expandedNodeIds.add(node.categoryId);
          } else {
            _expandedNodeIds.remove(node.categoryId);
          }
        });
      },
      onModify: (node) => _openEditPage(node),
      onMoveToRecycle: (node) => _confirmMoveToRecycle(node),
      onAddChild: (node) => _openAddPage(initialParentId: node.categoryId),
      hasPrev: _hasPrev,
      hasNext: _hasNext,
      onPrev: () {
        setState(() => _currentPage -= 1);
        _load();
      },
      onNext: () {
        setState(() => _currentPage += 1);
        _load();
      },
    );
  }








  Future<void> _confirmMoveToRecycle(CategoryNode node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CategoryDeleteConfirmDialog(
          categoryName: node.categoryName,
          onConfirm: () async {
            final bookId = context.read<BillsRepository>().bookId() ?? 1;
            await _service.moveToRecycleBin(
              bookId: bookId,
              categoryId: node.categoryId,
            );
          },
        );
      },
    );
    if (confirmed == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已移入回收站')),
      );
      await _load();
    }
  }



  // 已被新的页面形式替代：原对话框交互改为页面导航
  Future<void> _openEditPage(CategoryNode node) async {
    final int bookId = context.read<BillsRepository>().bookId() ?? 1;
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryEditPage(
          categoryId: node.categoryId,
          name: node.categoryName,
          enable: node.enable,
          sort: node.sort,
          remark: node.remark,
          categoryType: node.categoryType,
          parentId: node.parentId,
          bookId: bookId,
          icon: node.icon,
        ),
      ),
    );
    if (ok == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('修改成功')),
      );
      await _load();
    }
  }

  Future<void> _openAddPage({int initialParentId = -1}) async {
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryAddPage(
          categoryType: _categoryType,
          initialParentId: initialParentId,
        ),
      ),
    );
    if (ok == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('新增成功')),
      );
      await _load();
    }
  }
}

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
