import 'package:fortuneboot/core/network/fx_api.dart';

class BillsFilterOption {
  const BillsFilterOption({required this.id, required this.label});

  final int id;
  final String label;
}

class BillsFilterOptions {
  const BillsFilterOptions({
    this.categories = const [],
    this.tags = const [],
    this.accounts = const [],
    this.payees = const [],
  });

  final List<BillsFilterOption> categories;
  final List<BillsFilterOption> tags;
  final List<BillsFilterOption> accounts;
  final List<BillsFilterOption> payees;
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
      categories: _options(
        [results[0], results[1]],
        'categoryId',
        'categoryName',
      ),
      tags: _options([results[2]], 'tagId', 'tagName'),
      accounts: _options([results[3]], 'accountId', 'accountName'),
      payees: _options([results[4]], 'payeeId', 'payeeName'),
    );
  }

  List<BillsFilterOption> _options(
    List<dynamic> sources,
    String idKey,
    String labelKey,
  ) {
    final options = <BillsFilterOption>[];
    final ids = <int>{};

    void walk(dynamic source) {
      if (source is List) {
        for (final item in source) {
          walk(item);
        }
        return;
      }
      if (source is! Map) return;
      final item = Map<String, dynamic>.from(source);
      final id = FxApi.asId(item[idKey] ?? item['id']);
      final label = item[labelKey]?.toString().trim() ?? '';
      if (id != null && label.isNotEmpty && ids.add(id)) {
        options.add(BillsFilterOption(id: id, label: label));
      }
      walk(item['children']);
    }

    for (final source in sources) {
      walk(source);
    }
    return List.unmodifiable(options);
  }
}
