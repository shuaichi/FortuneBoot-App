import 'package:fortuneboot/core/network/fx_api.dart';

/// 精简账单模板选项（recurring 自建，不依赖 bill_editor 模块）。
///
/// 仅拉取构造 billRequest 所需的最小集合：账户 / 支出分类 / 收入分类 / 标签。
class TemplateOptionsService {
  final FxApi _api = FxApi.instance;

  Future<List<SimpleOption>> getAccounts(int groupId) async {
    final data = await _api.get('/fortune/account/$groupId/getEnableList');
    return _list(data, idKey: 'accountId', nameKey: 'accountName');
  }

  Future<List<SimpleOption>> getCategories({
    required int bookId,
    required int billType,
  }) async {
    final data = await _api.get(
      '/fortune/category/$bookId/getEnableList',
      query: {'billType': billType},
    );
    return _flattenLeaves(data);
  }

  Future<List<SimpleOption>> getTags(int bookId) async {
    final data = await _api.get(
      '/fortune/tag/$bookId/getEnableList',
      query: {'billType': ''},
    );
    return _flattenTags(data);
  }

  /// 并发拉取模板所需全部选项。
  Future<TemplateOptions> loadAll({
    required int bookId,
    required int groupId,
  }) async {
    final results = await Future.wait([
      getAccounts(groupId),
      getCategories(bookId: bookId, billType: 1),
      getCategories(bookId: bookId, billType: 2),
      getTags(bookId),
    ]);
    return TemplateOptions(
      accounts: results[0],
      expenseCategories: results[1],
      incomeCategories: results[2],
      tags: results[3],
    );
  }

  List<SimpleOption> _list(
    dynamic data, {
    required String idKey,
    required String nameKey,
  }) {
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) {
          final m = Map<String, dynamic>.from(e);
          return SimpleOption(
            id: FxApi.asId(m[idKey]),
            name: m[nameKey]?.toString() ?? '',
          );
        })
        .where((o) => o.id != null)
        .toList();
  }

  /// 分类树 → 仅叶子（可选记账目标）。
  List<SimpleOption> _flattenLeaves(dynamic data) {
    final out = <SimpleOption>[];
    void walk(Map<String, dynamic> node) {
      final children = node['children'];
      if (children is List && children.isNotEmpty) {
        for (final c in children.whereType<Map<dynamic, dynamic>>()) {
          walk(Map<String, dynamic>.from(c));
        }
      } else {
        final id = FxApi.asId(node['categoryId']);
        if (id != null) {
          out.add(SimpleOption(id: id, name: node['categoryName']?.toString() ?? ''));
        }
      }
    }

    if (data is List) {
      for (final n in data.whereType<Map<dynamic, dynamic>>()) {
        walk(Map<String, dynamic>.from(n));
      }
    }
    return out;
  }

  List<SimpleOption> _flattenTags(dynamic data) {
    final out = <SimpleOption>[];
    void walk(Map<String, dynamic> node) {
      final id = FxApi.asId(node['tagId']);
      if (id != null) {
        out.add(SimpleOption(id: id, name: node['tagName']?.toString() ?? ''));
      }
      final children = node['children'];
      if (children is List) {
        for (final c in children.whereType<Map<dynamic, dynamic>>()) {
          walk(Map<String, dynamic>.from(c));
        }
      }
    }

    if (data is List) {
      for (final n in data.whereType<Map<dynamic, dynamic>>()) {
        walk(Map<String, dynamic>.from(n));
      }
    }
    return out;
  }
}

/// 简单 id+name 选项。
class SimpleOption {
  final int? id;
  final String name;
  const SimpleOption({this.id, required this.name});
}

/// 模板选项集合。
class TemplateOptions {
  final List<SimpleOption> accounts;
  final List<SimpleOption> expenseCategories;
  final List<SimpleOption> incomeCategories;
  final List<SimpleOption> tags;

  const TemplateOptions({
    this.accounts = const [],
    this.expenseCategories = const [],
    this.incomeCategories = const [],
    this.tags = const [],
  });
}
