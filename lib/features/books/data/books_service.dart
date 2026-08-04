import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';

/// 下拉选项（后端 {value,label} 通用结构）。
class OptionItem {
  final String value;
  final String label;

  const OptionItem({required this.value, required this.label});

  factory OptionItem.fromJson(Map<String, dynamic> json) => OptionItem(
        value: (json['value'] ?? '').toString(),
        label: (json['label'] ?? json['value'] ?? '').toString(),
      );
}

/// 账本与分组管理数据服务。
///
/// 分组走 `/fortune/group`，账本走 `/fortune/book/base`。全部经 [FxApi.instance]
/// 解包返 data，异常统一为 [FxApiException]。
class BooksService {
  final FxApi _api = FxApi.instance;

  // ---- 分组 ----

  /// 启用分组列表（含当前用户 roleTypeDesc）。
  Future<List<FortuneGroupVo>> getGroups() async {
    final data = await _api.get('/fortune/group/getEnableList');
    return _rows(data).map(FortuneGroupVo.fromJson).toList();
  }

  Future<List<OptionItem>> getCurrencyTemplate() async {
    final data = await _api.get('/fortune/group/getCurrencyTemplate');
    return _rows(data).map(OptionItem.fromJson).toList();
  }

  Future<List<OptionItem>> getBookTemplate() async {
    final data = await _api.get('/fortune/group/getBookTemplate');
    return _rows(data).map(OptionItem.fromJson).toList();
  }

  Future<void> addGroup(Map<String, dynamic> body) =>
      _api.post('/fortune/group/add', data: body);

  Future<void> modifyGroup(Map<String, dynamic> body) =>
      _api.put('/fortune/group/modify', data: body);

  Future<void> removeGroup(int groupId) =>
      _api.delete('/fortune/group/$groupId/remove');

  /// 分组开关动作：setDefaultGroup / enable / disable。
  Future<void> groupAction(int groupId, String action) =>
      _api.patch('/fortune/group/$groupId/$action');

  // ---- 账本 ----

  /// 分组下账本分页（recycleBin 区分正常/回收站）。
  Future<List<FortuneBookVo>> getBooks({
    required int groupId,
    bool recycleBin = false,
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    final data = await _api.get(
      '/fortune/book/base/getPage',
      query: {
        'groupId': groupId,
        'recycleBin': recycleBin,
        'pageNum': pageNum,
        'pageSize': pageSize,
      },
    );
    return _rows(data).map(FortuneBookVo.fromJson).toList();
  }

  Future<void> addBook(Map<String, dynamic> body) =>
      _api.post('/fortune/book/base/add', data: body);

  Future<void> modifyBook(Map<String, dynamic> body) =>
      _api.put('/fortune/book/base/modify', data: body);

  Future<void> removeBook(int bookId) =>
      _api.delete('/fortune/book/base/$bookId/remove');

  /// 账本开关动作：moveToRecycleBin / putBack / setDefaultBook / enable / disable。
  Future<void> bookAction(int bookId, String action) =>
      _api.patch('/fortune/book/base/$bookId/$action');

  // ---- 解析 ----

  List<Map<String, dynamic>> _rows(dynamic data) {
    final List<dynamic> raw;
    if (data is Map) {
      raw = (data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[])
          as List<dynamic>;
    } else if (data is List) {
      raw = data;
    } else {
      return const [];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
