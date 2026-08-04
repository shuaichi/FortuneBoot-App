import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:intl/intl.dart';

/// 账户数据服务：分页 / 净资产 / 新增 / 修改 / 余额调整 / 开关 / 回收站。
/// 全部走 [FxApi.instance]，解包后返 data；异常统一为 [FxApiException]。
class AccountService {
  final FxApi _api = FxApi.instance;

  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  /// 拉取分组下全部账户（recycleBin=false）。
  ///
  /// 先尝试不传 accountType 一次性拉全部；若后端要求必传 accountType 而报错，
  /// 则回退为按类型 1-4 分别拉取后合并。
  Future<List<FortuneAccountVo>> getAllAccounts(
    int groupId, {
    bool recycleBin = false,
  }) async {
    try {
      return await _getPage(groupId: groupId, recycleBin: recycleBin);
    } on FxApiException {
      // 回退：按类型循环拉取合并。
      final merged = <FortuneAccountVo>[];
      for (final type in const [1, 2, 3, 4]) {
        final rows = await _getPage(
          groupId: groupId,
          recycleBin: recycleBin,
          accountType: type,
        );
        merged.addAll(rows);
      }
      return merged;
    }
  }

  Future<List<FortuneAccountVo>> _getPage({
    required int groupId,
    required bool recycleBin,
    int? accountType,
    int pageNum = 1,
    int pageSize = 200,
  }) async {
    final query = <String, dynamic>{
      'groupId': groupId,
      'recycleBin': recycleBin,
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (accountType != null) query['accountType'] = accountType;
    final data = await _api.get('/fortune/account/getPage', query: query);
    return _parseRows(data);
  }

  List<FortuneAccountVo> _parseRows(dynamic data) {
    final List<dynamic> rowsRaw;
    if (data is Map) {
      rowsRaw =
          (data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[])
              as List<dynamic>;
    } else if (data is List) {
      rowsRaw = data;
    } else {
      return const [];
    }
    return rowsRaw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => FortuneAccountVo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 净资产总览：GET /fortune/include/{groupId}/getFortuneAssetsLiabilities。
  Future<AssetsLiabilities> getAssetsLiabilities(int groupId) async {
    final data = await _api.get(
      '/fortune/include/$groupId/getFortuneAssetsLiabilities',
    );
    if (data is Map) {
      return AssetsLiabilities.fromJson(Map<String, dynamic>.from(data));
    }
    return const AssetsLiabilities();
  }

  /// 新增账户：POST /fortune/account/add。
  Future<void> addAccount(Map<String, dynamic> body) =>
      _api.post('/fortune/account/add', data: body);

  /// 修改账户：PUT /fortune/account/modify（body 需含 accountId）。
  Future<void> modifyAccount(Map<String, dynamic> body) =>
      _api.put('/fortune/account/modify', data: body);

  /// 余额调整：PATCH /fortune/account/balanceAdjust。需 bookId。
  Future<void> balanceAdjust({
    required int bookId,
    required int accountId,
    required double balance,
    required DateTime tradeTime,
    String? title,
    String? remark,
  }) {
    final body = <String, dynamic>{
      'bookId': bookId,
      'accountId': accountId,
      'balance': balance,
      'tradeTime': _dateTime.format(tradeTime),
    };
    if (title != null && title.trim().isNotEmpty) body['title'] = title.trim();
    if (remark != null && remark.trim().isNotEmpty) {
      body['remark'] = remark.trim();
    }
    return _api.patch('/fortune/account/balanceAdjust', data: body);
  }

  /// 开关切换：PATCH /fortune/account/{groupId}/{accountId}/{action}。
  Future<void> toggle({
    required int groupId,
    required int accountId,
    required String action,
  }) => _api.patch('/fortune/account/$groupId/$accountId/$action');

  Future<void> moveToRecycleBin({
    required int groupId,
    required int accountId,
  }) => toggle(
    groupId: groupId,
    accountId: accountId,
    action: 'moveToRecycleBin',
  );

  Future<void> putBack({required int groupId, required int accountId}) =>
      toggle(groupId: groupId, accountId: accountId, action: 'putBack');

  /// 彻底删除：DELETE /fortune/account/{groupId}/{accountId}/remove。
  Future<void> remove({required int groupId, required int accountId}) =>
      _api.delete('/fortune/account/$groupId/$accountId/remove');

  static String formatDay(DateTime d) => _day.format(d);
}

/// 账户开关字段 → 开/关两个 PATCH 动作名。
enum AccountToggleField {
  canExpense('canExpense', 'cannotExpense', '可支出'),
  canIncome('canIncome', 'cannotIncome', '可收入'),
  canTransferOut('canTransferOut', 'cannotTransferOut', '可转出'),
  canTransferIn('canTransferIn', 'cannotTransferIn', '可转入'),
  include('includeAccount', 'excludeAccount', '计入净资产'),
  enable('enable', 'disable', '启用');

  const AccountToggleField(this.onAction, this.offAction, this.label);

  final String onAction;
  final String offAction;
  final String label;

  String action(bool on) => on ? onAction : offAction;
}
