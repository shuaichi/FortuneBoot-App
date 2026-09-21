import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:fortuneboot/features/categories/presentation/categories_page.dart';

/// 注册 Categories feature 路由。由 main.dart 在启动时统一调用。
void registerCategoriesFeature() {
  AppRouter.register(Routes.categories, (args) {
    return Builder(
      builder: (BuildContext context) {
        final bookId = context.read<SessionCubit>().state.currentBookId;
        return BlocProvider<CategoriesBloc>(
          create: (_) =>
              CategoriesBloc(bookId: bookId)..add(const CategoriesLoaded()),
          child: const CategoriesPage(),
        );
      },
    );
  });
}
