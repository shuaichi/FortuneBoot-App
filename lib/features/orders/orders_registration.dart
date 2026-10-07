import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/orders_page.dart';

/// 注册 Orders（单据）feature 路由。由 main.dart 在启动时统一调用。
void registerOrdersFeature() {
  AppRouter.register(Routes.orders, (args) {
    return Builder(
      builder: (BuildContext context) {
        final session = context.read<SessionCubit>().state;
        return BlocProvider<OrdersBloc>(
          create: (_) =>
              OrdersBloc(bookId: session.currentBookId)
                ..add(const OrdersLoaded()),
          child: const OrdersPage(),
        );
      },
    );
  });
}
