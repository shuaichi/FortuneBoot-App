import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/books/presentation/bloc/books_bloc.dart';
import 'package:fortuneboot/features/books/presentation/books_page.dart';

/// 注册 Books（账本 + 分组管理）feature 路由。由 main.dart 统一调用。
///
/// Routes.groups → 默认落到「分组管理」分段；Routes.books → 默认落到「账本管理」分段。
/// 两个入口共用同一页面与 Bloc，仅初始分段不同。
void registerBooksFeature() {
  AppRouter.register(
    Routes.books,
    (args) => _buildBooksPage(BooksTab.books),
  );
  AppRouter.register(
    Routes.groups,
    (args) => _buildBooksPage(BooksTab.groups),
  );
}

Widget _buildBooksPage(BooksTab initialTab) {
  return Builder(
    builder: (BuildContext context) {
      final session = context.read<SessionCubit>().state;
      return BlocProvider<BooksBloc>(
        create: (_) => BooksBloc(initialGroupId: session.currentGroupId)
          ..add(const BooksLoaded()),
        child: BooksPage(initialTab: initialTab),
      );
    },
  );
}
