import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';

/// 分页结果。
class MemberPage {
  final List<FortuneMemberVo> rows;
  final int total;
  const MemberPage({this.rows = const [], this.total = 0});
}

/// 成员数据服务 /fortune/member（分页列表，仅 enable 开关）。
class MemberService {
  final FxApi _api = FxApi.instance;

  /// 分页查询：GET /fortune/member/getPage。recycleBin 必传。
  ///
  /// 成员为扁平列表，UI 需全量展示；total 超过单页时循环拉取聚合，避免静默截断。
  Future<MemberPage> getPage({
    required int bookId,
    required bool recycleBin,
    String? memberName,
    int pageSize = 200,
  }) async {
    final all = <FortuneMemberVo>[];
    var pageNum = 1;
    var total = 0;
    while (true) {
      final query = <String, dynamic>{
        'bookId': bookId,
        'recycleBin': recycleBin,
        'pageNum': pageNum,
        'pageSize': pageSize,
      };
      if (memberName != null && memberName.trim().isNotEmpty) {
        query['memberName'] = memberName.trim();
      }
      final data = await _api.get('/fortune/member/getPage', query: query);
      final page = _parse(data);
      all.addAll(page.rows);
      total = page.total;
      if (page.rows.isEmpty || all.length >= total) break;
      pageNum++;
    }
    return MemberPage(rows: all, total: total);
  }

  MemberPage _parse(dynamic data) {
    if (data is! Map) return const MemberPage();
    final rowsRaw =
        (data['rows'] ?? data['list'] ?? data['records'] ?? <dynamic>[])
            as List<dynamic>;
    final rows = rowsRaw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => FortuneMemberVo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final total = FxApi.asId(data['total']) ?? rows.length;
    return MemberPage(rows: rows, total: total);
  }

  Future<void> add(Map<String, dynamic> body) =>
      _api.post('/fortune/member/add', data: body);

  Future<void> modify(Map<String, dynamic> body) =>
      _api.put('/fortune/member/modify', data: body);

  /// 开关/回收站切换：PATCH /fortune/member/{bookId}/{memberId}/{action}。
  Future<void> toggle({
    required int bookId,
    required int memberId,
    required String action,
  }) => _api.patch('/fortune/member/$bookId/$memberId/$action');

  Future<void> moveToRecycleBin({required int bookId, required int memberId}) =>
      toggle(bookId: bookId, memberId: memberId, action: 'moveToRecycleBin');

  Future<void> putBack({required int bookId, required int memberId}) =>
      toggle(bookId: bookId, memberId: memberId, action: 'putBack');

  Future<void> remove({required int bookId, required int memberId}) =>
      _api.delete('/fortune/member/$bookId/$memberId/remove');
}
