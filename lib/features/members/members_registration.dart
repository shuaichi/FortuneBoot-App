import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/members/presentation/bloc/members_bloc.dart';
import 'package:fortuneboot/features/members/presentation/members_page.dart';

/// 注册 Members feature 路由。由 main.dart 在启动时统一调用。
void registerMembersFeature() {
  AppRouter.register(Routes.members, (args) {
    return Builder(
      builder: (BuildContext context) {
        final bookId = context.read<SessionCubit>().state.currentBookId;
        return BlocProvider<MembersBloc>(
          create: (_) =>
              MembersBloc(bookId: bookId)..add(const MembersLoaded()),
          child: const MembersPage(),
        );
      },
    );
  });
}
