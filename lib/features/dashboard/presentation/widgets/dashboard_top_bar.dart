import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_switcher_sheet.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_pressable.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 看板粘顶栏：左侧 分组·账本 切换器（点击弹 FxSheet），右侧布局编辑 / 金额显隐 / 头像。
class DashboardTopBar extends StatelessWidget {
  final VoidCallback? onAvatarTap;
  final bool editingLayout;
  final VoidCallback? onEditLayoutToggle;

  const DashboardTopBar({
    super.key,
    this.onAvatarTap,
    this.editingLayout = false,
    this.onEditLayoutToggle,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final palette = FxPalette.of(context);
    final groupName =
        session.currentGroup?.groupName ?? S.of(context).dashboardSelectGroup;
    final bookName =
        session.currentBook?.bookName ?? S.of(context).dashboardSelectBook;

    return Container(
      color: palette.canvas,
      padding: EdgeInsets.only(
        left: FxSpacing.lg,
        right: FxSpacing.lg,
        top: MediaQuery.of(context).padding.top + FxSpacing.sm,
        bottom: FxSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FxPressable(
                semanticLabel: '$groupName，$bookName',
                onPressed: editingLayout ? null : () => _openSwitcher(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: FxSpacing.sm,
                  vertical: FxSpacing.xs,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        groupName,
                        style: FxTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              bookName,
                              style: FxTypography.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!editingLayout)
                            Icon(
                              Icons.expand_more_rounded,
                              size: 22,
                              color: palette.textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          if (onEditLayoutToggle != null) ...[
            _LayoutEditAction(
              editing: editingLayout,
              onPressed: onEditLayoutToggle!,
            ),
            const SizedBox(width: FxSpacing.xs),
          ],
          if (!editingLayout) ...[
            const _AmountVisibilityAction(),
            const SizedBox(width: FxSpacing.xs),
            _AvatarAction(onTap: onAvatarTap),
          ],
        ],
      ),
    );
  }

  void _openSwitcher(BuildContext context) {
    HapticFeedback.selectionClick();
    SessionSwitcherSheet.show(context);
  }
}

class _LayoutEditAction extends StatelessWidget {
  const _LayoutEditAction({required this.editing, required this.onPressed});

  final bool editing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FxIconButton(
      icon: editing ? Icons.check_rounded : Icons.dashboard_customize_rounded,
      tooltip: editing
          ? S.of(context).dashboardDoneEditing
          : S.of(context).dashboardEditLayout,
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
    );
  }
}

class _AmountVisibilityAction extends StatelessWidget {
  const _AmountVisibilityAction();

  @override
  Widget build(BuildContext context) {
    final hidden = context.select<PreferencesCubit, bool>(
      (cubit) => cubit.state.dashboard.hideAmounts,
    );
    final tooltip = hidden
        ? S.of(context).commonShowAmounts
        : S.of(context).commonHideAmounts;

    return FxIconButton(
      icon: hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      tooltip: tooltip,
      onPressed: () => _toggle(context, hidden),
    );
  }

  Future<void> _toggle(BuildContext context, bool hidden) async {
    HapticFeedback.selectionClick();
    final saved = await context.read<PreferencesCubit>().setHideAmounts(
      !hidden,
    );
    if (!saved && context.mounted) {
      FxFeedback.error(context, message: S.of(context).profileSaveFailedRetry);
    }
  }
}

class _AvatarAction extends StatelessWidget {
  const _AvatarAction({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final avatar = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: palette.primary, size: 22),
    );
    if (onTap == null) {
      return ExcludeSemantics(child: avatar);
    }
    return Semantics(
      button: true,
      child: Tooltip(
        message: S.of(context).dashboardSelectGroup,
        child: InkResponse(onTap: onTap, radius: 24, child: avatar),
      ),
    );
  }
}
