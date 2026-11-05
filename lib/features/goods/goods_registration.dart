import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_scoped_page.dart';
import 'package:fortuneboot/features/goods/presentation/bloc/goods_bloc.dart';
import 'package:fortuneboot/features/goods/presentation/goods_page.dart';

/// 注册 Goods（归物）feature 路由。由 main.dart 在启动时统一调用。
void registerGoodsFeature() {
  AppRouter.register(Routes.goods, (args) {
    return SessionScopedPage(
      child: Builder(
        builder: (BuildContext context) {
          final session = context.read<SessionCubit>().state;
          return BlocProvider<GoodsBloc>(
            create: (_) => GoodsBloc(
              bookId: session.currentBookId,
              currencyCode: session.defaultCurrency,
            )..add(const GoodsLoaded()),
            child: const GoodsPage(),
          );
        },
      ),
    );
  });
}
