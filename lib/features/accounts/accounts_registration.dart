import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/accounts/presentation/accounts_page.dart';
import 'package:fortuneboot/features/accounts/presentation/bloc/accounts_bloc.dart';

/// 注册 Accounts feature 路由。由 main.dart 在启动时统一调用（本文件不碰 main.dart）。
void registerAccountsFeature() {
  AppRouter.register(Routes.accounts, (args) {
    return Builder(
      builder: (BuildContext context) {
        final session = context.read<SessionCubit>().state;
        return BlocProvider<AccountsBloc>(
          create: (_) => AccountsBloc(
            groupId: session.currentGroupId,
            currencyCode: session.defaultCurrency,
          )..add(const AccountsLoaded()),
          child: const AccountsPage(),
        );
      },
    );
  });
}
