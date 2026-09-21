import 'package:fortuneboot/core/network/fx_api.dart';

/// 分组成员关系 VO。
class GroupUserVo {
  final int? userGroupRelationId;
  final int? roleType;
  final String? roleTypeDesc;
  final int? groupId;
  final String? username;
  final String? nickname;

  const GroupUserVo({
    this.userGroupRelationId,
    this.roleType,
    this.roleTypeDesc,
    this.groupId,
    this.username,
    this.nickname,
  });

  factory GroupUserVo.fromJson(Map<String, dynamic> json) => GroupUserVo(
    userGroupRelationId: FxApi.asId(json['userGroupRelationId']),
    roleType: FxApi.asId(json['roleType']),
    roleTypeDesc: json['roleTypeDesc']?.toString(),
    groupId: FxApi.asId(json['groupId']),
    username: json['username']?.toString(),
    nickname: json['nickname']?.toString(),
  );

  String get displayName => (nickname != null && nickname!.isNotEmpty)
      ? nickname!
      : (username ?? '-');
}

/// 角色类型选项（roleType int → 描述）。
class RoleTypeOption {
  final int value;
  final String label;

  const RoleTypeOption({required this.value, required this.label});
}

/// 分组协作数据服务：成员列表 / 角色枚举 / 邀请 / 移除。
class GroupUsersService {
  final FxApi _api = FxApi.instance;

  Future<List<GroupUserVo>> getGroupUsers(int groupId) async {
    final data = await _api.get('/fortune/group/$groupId/getGroupUser');
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => GroupUserVo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  /// 角色枚举 `Map<int,String>`，动态消费不硬编码。
  Future<List<RoleTypeOption>> getRoleTypes() async {
    final data = await _api.get('/fortune/group/getRoleTypes');
    if (data is Map) {
      final out = <RoleTypeOption>[];
      data.forEach((k, v) {
        final value = FxApi.asId(k);
        if (value != null) {
          out.add(
            RoleTypeOption(value: value, label: v?.toString() ?? '$value'),
          );
        }
      });
      out.sort((a, b) => a.value.compareTo(b.value));
      return out;
    }
    return const [];
  }

  /// 邀请用户（仅 owner，后端 SpEL 兜底）。
  Future<void> inviteUser({
    required int groupId,
    required int roleType,
    required String username,
  }) => _api.post(
    '/fortune/group/inviteUser',
    data: {'groupId': groupId, 'roleType': roleType, 'username': username},
  );

  /// 移除成员（仅 owner）。
  Future<void> removeGroupUser(int relationId) =>
      _api.delete('/fortune/group/$relationId/removeGroupUser');
}
