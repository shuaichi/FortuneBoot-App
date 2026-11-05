import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/fx_route_unavailable_page.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_page.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 注册 BillEditor 路由。由 main.dart 统一调用。
void registerBillEditorFeature() {
  AppRouter.register(Routes.billEditor, (args) {
    final editorArgs = BillEditorArgs.fromRouteArgs(args);
    return Builder(
      builder: (context) {
        final session = context.read<SessionCubit>().state;
        final copyUsesCurrentTime = context
            .read<PreferencesCubit>()
            .state
            .billing
            .copyUsesCurrentTime;
        final requestedBookId = editorArgs.presetBookId;
        final requestedBooks = requestedBookId == null
            ? session.books.take(0).toList()
            : session.books
                  .where((book) => book.bookId == requestedBookId)
                  .toList();
        final requestedBook = requestedBooks.isEmpty
            ? null
            : requestedBooks.first;
        // 单据/深链指定了本会话不可见的账本时，不能悄悄记到当前账本。
        if (requestedBookId != null && requestedBook == null) {
          return const FxRouteUnavailablePage(
            reason: FxRouteUnavailableReason.missingContext,
          );
        }
        final bookId = requestedBook?.bookId ?? session.currentBookId;
        final groupId = requestedBook?.groupId ?? session.currentGroupId;
        // 账本未就绪时拦截，避免用 bookId=0 发脏请求 / 提交脏数据。
        if (bookId == null || groupId == null) {
          return Scaffold(
            appBar: AppBar(),
            body: FxStateView.empty(
              message: S.of(context).billEditorSelectBookFirst,
            ),
          );
        }
        return BlocProvider(
          create: (_) => BillEditorBloc(
            bookId: bookId,
            groupId: groupId,
            copyUsesCurrentTime: copyUsesCurrentTime,
          )..add(BillEditorInitialized(editorArgs)),
          child: const BillEditorPage(),
        );
      },
    );
  }, requiresWriteAccess: true);
}
