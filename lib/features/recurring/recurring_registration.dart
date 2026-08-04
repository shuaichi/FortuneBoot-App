import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:fortuneboot/features/recurring/presentation/recurring_page.dart';

/// 注册 Recurring（周期记账）feature 路由。由 main.dart 统一调用。
void registerRecurringFeature() {
  AppRouter.register(Routes.recurring, (args) {
    return Builder(
      builder: (BuildContext context) {
        final session = context.read<SessionCubit>().state;
        return BlocProvider<RecurringBloc>(
          create: (_) =>
              RecurringBloc(bookId: session.currentBookId)
                ..add(const RecurringLoaded()),
          child: const RecurringPage(),
        );
      },
    );
  });
}
