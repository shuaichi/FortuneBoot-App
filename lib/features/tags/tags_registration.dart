import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_scoped_page.dart';
import 'package:fortuneboot/features/tags/presentation/bloc/tags_bloc.dart';
import 'package:fortuneboot/features/tags/presentation/tags_page.dart';

/// 注册 Tags feature 路由。由 main.dart 在启动时统一调用。
void registerTagsFeature() {
  AppRouter.register(Routes.tags, (args) {
    return SessionScopedPage(
      child: Builder(
        builder: (BuildContext context) {
          final bookId = context.read<SessionCubit>().state.currentBookId;
          return BlocProvider<TagsBloc>(
            create: (_) => TagsBloc(bookId: bookId)..add(const TagsLoaded()),
            child: const TagsPage(),
          );
        },
      ),
    );
  });
}
