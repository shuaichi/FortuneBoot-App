import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_permission.dart';
import 'package:fortuneboot/core/session/widgets/session_switcher_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 范围说明层级。
enum SessionScopeLevel {
  /// 分组口径（账户、分组协作等）。
  group,

  /// 账本口径（账单、分类、单据等）。
  book,
}

/// 当前分组/账本的就地说明。
///
/// 只展示 [SessionState.currentGroup] / [SessionState.currentBook] 这一组
/// 已提交的实际范围；切换中的目标用 [SessionState.pendingGroup] 单独标注，
/// 不提前把旧账本内容换成新分组名称。
class SessionScopeStrip extends StatelessWidget {
  const SessionScopeStrip({
    super.key,
    required this.state,
    this.level = SessionScopeLevel.book,
    this.interactive = false,
    this.showTopInset = false,
    this.padding,
  });

  final SessionState state;
  final SessionScopeLevel level;

  /// 是否允许点击打开分组/账本切换。
  final bool interactive;

  /// 是否自行承担状态栏顶部安全区（主壳使用）。
  final bool showTopInset;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final groupName = _trimmed(state.currentGroup?.groupName);
    final bookName = _trimmed(state.currentBook?.bookName);
    final pendingName = _trimmed(state.pendingGroup?.groupName);
    final loading = state.status == SessionStatus.loading;
    final failed = state.status == SessionStatus.error;
    final readOnly = SessionPermission.isVisitor(state.currentGroup);
    final hasScope = level == SessionScopeLevel.group
        ? groupName != null
        : bookName != null;
    final semantic = _semanticLabel(
      s,
      groupName: groupName,
      bookName: bookName,
      pendingName: pendingName,
      readOnly: readOnly,
    );

    final row = Padding(
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            FxSpacing.xl,
            showTopInset
                ? MediaQuery.paddingOf(context).top + FxSpacing.sm
                : FxSpacing.sm,
            FxSpacing.md,
            FxSpacing.sm,
          ),
      child: Row(
        children: [
          Expanded(
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(
                    level == SessionScopeLevel.group
                        ? Icons.folder_outlined
                        : Icons.menu_book_outlined,
                    size: 18,
                    color: palette.textSecondary,
                  ),
                  const SizedBox(width: FxSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (loading && !hasScope)
                          Text(
                            s.navScopeLoading,
                            style: FxTypography.label.copyWith(
                              color: palette.textSecondary,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (level == SessionScopeLevel.book)
                                Text(
                                  groupName ?? s.navScopeNoGroup,
                                  style: FxTypography.caption.copyWith(
                                    color: palette.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                level == SessionScopeLevel.group
                                    ? groupName ?? s.navScopeNoGroup
                                    : bookName ?? s.navScopeNoBook,
                                style: FxTypography.label.copyWith(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        if (pendingName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            s.navScopeSwitching(pendingName),
                            style: FxTypography.caption.copyWith(
                              color: palette.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (loading && hasScope) ...[
                          const SizedBox(height: 2),
                          Text(
                            s.navScopeUpdating,
                            style: FxTypography.caption.copyWith(
                              color: palette.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (failed) ...[
                          const SizedBox(height: 2),
                          Text(
                            s.navScopeSwitchFailed,
                            style: FxTypography.caption.copyWith(
                              color: palette.danger,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (readOnly) ...[
                    const SizedBox(width: FxSpacing.xs),
                    _ReadOnlyBadge(label: s.navScopeReadOnly),
                  ],
                ],
              ),
            ),
          ),
          if (failed)
            IconButton(
              tooltip: s.commonRetry,
              onPressed: () => context.read<SessionCubit>().retryPendingScope(),
              icon: Icon(Icons.refresh_rounded, color: palette.textSecondary),
            )
          else if (interactive && !loading)
            ExcludeSemantics(
              child: Icon(
                Icons.expand_more_rounded,
                size: 22,
                color: palette.textSecondary,
              ),
            ),
        ],
      ),
    );

    final content = Semantics(
      container: true,
      button: interactive && !loading,
      label: semantic,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: FxSpacing.controlHeight),
        child: row,
      ),
    );

    return Material(
      color: palette.canvas,
      child: interactive && !loading
          ? InkWell(
              onTap: () => SessionSwitcherSheet.show(context),
              child: content,
            )
          : content,
    );
  }

  String _semanticLabel(
    S s, {
    required String? groupName,
    required String? bookName,
    required String? pendingName,
    required bool readOnly,
  }) {
    final scope = level == SessionScopeLevel.group
        ? s.navScopeCurrentGroupSemantics(groupName ?? s.navScopeNoGroup)
        : s.navScopeCurrentSemantics(
            groupName ?? s.navScopeNoGroup,
            bookName ?? s.navScopeNoBook,
          );
    final parts = <String>[
      scope,
      if (readOnly) s.navScopeReadOnlyHint,
      if (pendingName != null) s.navScopeSwitching(pendingName),
      if (state.status == SessionStatus.error) s.navScopeSwitchFailed,
      if (interactive && state.status != SessionStatus.loading)
        s.navScopeTapToSwitch,
    ];
    return parts.join('，');
  }

  static String? _trimmed(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class _ReadOnlyBadge extends StatelessWidget {
  const _ReadOnlyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.pillBorder,
        border: Border.all(color: palette.border),
      ),
      child: Text(
        label,
        style: FxTypography.caption.copyWith(color: palette.textSecondary),
      ),
    );
  }
}
