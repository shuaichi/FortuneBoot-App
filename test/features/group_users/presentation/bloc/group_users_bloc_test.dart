import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/group_users/data/group_users_service.dart';
import 'package:fortuneboot/features/group_users/presentation/bloc/group_users_bloc.dart';

class FakeGroupUsersService extends GroupUsersService {
  final requestedGroupIds = <int>[];

  @override
  Future<List<RoleTypeOption>> getRoleTypes() async => const [
    RoleTypeOption(value: 1, label: '所有者'),
    RoleTypeOption(value: 2, label: '协作者'),
  ];

  @override
  Future<List<GroupUserVo>> getGroupUsers(int groupId) async {
    requestedGroupIds.add(groupId);
    return [
      GroupUserVo(
        userGroupRelationId: groupId * 10,
        groupId: groupId,
        username: 'user$groupId',
        roleType: 1,
        roleTypeDesc: '所有者',
      ),
    ];
  }
}

void main() {
  group('GroupUsersBloc', () {
    test(
      'reloads users with the latest group id after group changes',
      () async {
        final service = FakeGroupUsersService();
        final bloc = GroupUsersBloc(service: service, groupId: 1);
        addTearDown(bloc.close);

        bloc.add(const GroupUsersLoaded());
        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<GroupUsersState>().having((s) => s.groupId, 'groupId', 1),
          ),
        );

        bloc.add(const GroupUsersGroupChanged(2));
        await expectLater(
          bloc.stream,
          emitsThrough(
            isA<GroupUsersState>().having((s) => s.groupId, 'groupId', 2),
          ),
        );

        expect(service.requestedGroupIds, [1, 2]);
        expect(bloc.state.users.single.groupId, 2);
      },
    );
  });
}
