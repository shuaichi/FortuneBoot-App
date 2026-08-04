import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_page.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';

/// 注册 BillEditor 路由。由 main.dart 统一调用。
void registerBillEditorFeature() {
  AppRouter.register(Routes.billEditor, (args) {
    final editorArgs = BillEditorArgs.fromRouteArgs(args);
    return Builder(
      builder: (context) {
        final session = context.read<SessionCubit>().state;
        final bookId = session.currentBookId;
        final groupId = session.currentGroupId;
        // 账本未就绪时拦截，避免用 bookId=0 发脏请求 / 提交脏数据。
        if (bookId == null || groupId == null) {
          return Scaffold(
            appBar: AppBar(),
            body: FxStateView.empty(message: '请先选择一个账本后再记账'),
          );
        }
        return BlocProvider(
          create: (_) =>
              BillEditorBloc(bookId: bookId, groupId: groupId)
                ..add(BillEditorInitialized(editorArgs)),
          child: const BillEditorPage(),
        );
      },
    );
  });
}
