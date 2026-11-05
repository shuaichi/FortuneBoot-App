import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_scope_strip.dart';
import 'package:fortuneboot/core/session/widgets/session_scoped_page.dart';
import 'package:fortuneboot/features/group_users/presentation/bloc/group_users_bloc.dart';
import 'package:fortuneboot/features/group_users/presentation/group_users_page.dart';

/// 注册 GroupUsers（分组协作成员管理）feature 路由。由 main.dart 统一调用。
void registerGroupUsersFeature() {
  AppRouter.register(Routes.groupUsers, (args) {
    return SessionScopedPage(
      level: SessionScopeLevel.group,
      child: Builder(
        builder: (BuildContext context) {
          final session = context.read<SessionCubit>().state;
          return BlocProvider<GroupUsersBloc>(
            create: (_) =>
                GroupUsersBloc(groupId: session.currentGroupId)
                  ..add(const GroupUsersLoaded()),
            child: const GroupUsersPage(),
          );
        },
      ),
    );
  });
}
