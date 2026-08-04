import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fortuneboot/features/profile/presentation/profile_edit_page.dart';
import 'package:fortuneboot/features/profile/presentation/profile_page.dart';

/// 个人中心 feature 注入入口。由 main.dart 在启动时统一调用（本文件不碰 main.dart）。
///
/// - 注入 MainShell 的 "我的" tab（自持 ProfileBloc，进入即加载）。
/// - 注册编辑资料路由（args 为 [ProfileEditArgs]，页内 push 时也可直接 new）。
void registerProfileFeature() {
  MainShellSlots.profile = (context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => ProfileBloc()..add(const ProfileLoaded()),
      child: const ProfilePage(),
    );
  };

  AppRouter.register(Routes.profileEdit, (args) {
    final profile = args is ProfileEditArgs ? args.profile : const UserProfile();
    return ProfileEditPage(profile: profile);
  });
}
