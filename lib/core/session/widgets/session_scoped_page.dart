import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_scope_strip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 为二级数据页提供“当前范围”说明，并在范围真正切换后重建页面数据。
///
/// 页面自身的 Bloc 往往在创建时捕获 groupId/bookId。这里用范围键重建子树，
/// 避免范围说明已更新、页面仍请求旧账本的情况；切换进行中保留旧内容并显示
/// 更新提示，直到 [SessionCubit] 原子提交新范围。
class SessionScopedPage extends StatelessWidget {
  const SessionScopedPage({
    super.key,
    required this.child,
    this.level = SessionScopeLevel.book,
  });

  final Widget child;
  final SessionScopeLevel level;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final scopeKey =
            '${state.currentGroupId ?? 'none'}:${state.currentBookId ?? 'none'}';
        return ColoredBox(
          color: FxPalette.of(context).canvas,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SessionScopeStrip(state: state, level: level),
                Expanded(
                  child: KeyedSubtree(
                    key: ValueKey<String>(scopeKey),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
