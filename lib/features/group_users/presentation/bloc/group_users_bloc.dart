import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/group_users/data/group_users_service.dart';

part 'group_users_event.dart';
part 'group_users_state.dart';

/// 分组成员 Bloc：拉取当前分组成员列表。
class GroupUsersBloc extends Bloc<GroupUsersEvent, GroupUsersState> {
  final GroupUsersService _service;
  final int? _groupId;

  GroupUsersBloc({GroupUsersService? service, int? groupId})
    : _service = service ?? GroupUsersService(),
      _groupId = groupId,
      super(const GroupUsersState()) {
    on<GroupUsersLoaded>(_onLoaded);
    on<GroupUsersMutated>(_onLoaded);
  }

  Future<void> _onLoaded(
    GroupUsersEvent event,
    Emitter<GroupUsersState> emit,
  ) async {
    final groupId = _groupId;
    if (groupId == null) {
      emit(state.copyWith(status: GroupUsersStatus.empty, users: const []));
      return;
    }
    emit(state.copyWith(status: GroupUsersStatus.loading));
    try {
      // 角色枚举只需拉一次；已有则复用，避免每次刷新重复请求。
      final roleTypes = state.roleTypes.isNotEmpty
          ? state.roleTypes
          : await _service.getRoleTypes();
      final users = await _service.getGroupUsers(groupId);
      emit(
        state.copyWith(
          status: users.isEmpty
              ? GroupUsersStatus.empty
              : GroupUsersStatus.loaded,
          users: users,
          roleTypes: roleTypes,
        ),
      );
    } on FxApiException catch (e) {
      emit(
        state.copyWith(status: GroupUsersStatus.error, errorMessage: e.message),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: GroupUsersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
