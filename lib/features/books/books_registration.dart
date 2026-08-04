import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/books/presentation/bloc/books_bloc.dart';
import 'package:fortuneboot/features/books/presentation/books_page.dart';

/// 注册 Books（账本 + 分组管理）feature 路由。由 main.dart 统一调用。
void registerBooksFeature() {
  AppRouter.register(Routes.books, (args) {
    return Builder(
      builder: (BuildContext context) {
        final session = context.read<SessionCubit>().state;
        return BlocProvider<BooksBloc>(
          create: (_) =>
              BooksBloc(initialGroupId: session.currentGroupId)
                ..add(const BooksLoaded()),
          child: const BooksPage(),
        );
      },
    );
  });
}
