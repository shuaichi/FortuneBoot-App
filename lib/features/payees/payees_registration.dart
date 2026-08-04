import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/payees/presentation/bloc/payees_bloc.dart';
import 'package:fortuneboot/features/payees/presentation/payees_page.dart';

/// 注册 Payees feature 路由。由 main.dart 在启动时统一调用。
void registerPayeesFeature() {
  AppRouter.register(Routes.payees, (args) {
    return Builder(
      builder: (BuildContext context) {
        final bookId = context.read<SessionCubit>().state.currentBookId;
        return BlocProvider<PayeesBloc>(
          create: (_) =>
              PayeesBloc(bookId: bookId)..add(const PayeesLoaded()),
          child: const PayeesPage(),
        );
      },
    );
  });
}
