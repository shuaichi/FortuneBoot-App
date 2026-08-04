import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 看板粘顶栏：左侧 分组·账本 切换器（点击弹 FxSheet），右侧头像（点击可空）。
class DashboardTopBar extends StatelessWidget {
  final VoidCallback? onAvatarTap;
  const DashboardTopBar({super.key, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final groupName = session.currentGroup?.groupName ?? '选择分组';
    final bookName = session.currentBook?.bookName ?? '选择账本';

    return Container(
      color: FxColors.canvas,
      padding: EdgeInsets.only(
        left: FxSpacing.lg,
        right: FxSpacing.lg,
        top: MediaQuery.of(context).padding.top + FxSpacing.sm,
        bottom: FxSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openSwitcher(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          groupName,
                          style: FxTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                bookName,
                                style: FxTypography.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.expand_more_rounded,
                              size: 22,
                              color: FxColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: FxColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: FxColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSwitcher(BuildContext context) {
    HapticFeedback.selectionClick();
    final cubit = context.read<SessionCubit>();
    FxSheet.show<void>(
      context,
      title: '切换分组 / 账本',
      child: _SwitcherBody(cubit: cubit),
    );
  }
}

class _SwitcherBody extends StatelessWidget {
  final SessionCubit cubit;
  const _SwitcherBody({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      bloc: cubit,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            0,
            FxSpacing.lg,
            FxSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('分组'),
              ...state.groups.map(
                (g) => _tile(
                  label: g.groupName ?? '未命名分组',
                  selected: g.groupId == state.currentGroupId,
                  onTap: () => cubit.switchGroup(g),
                ),
              ),
              const SizedBox(height: FxSpacing.lg),
              _sectionLabel('账本'),
              if (state.books.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: FxSpacing.md),
                  child: Text('该分组暂无账本', style: FxTypography.caption),
                )
              else
                ...state.books.map(
                  (b) => _tile(
                    label: b.bookName ?? '未命名账本',
                    selected: b.bookId == state.currentBookId,
                    onTap: () {
                      cubit.switchBook(b);
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.sm),
    child: Text(text, style: FxTypography.label),
  );

  Widget _tile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.sm),
      child: Material(
        color: selected ? FxColors.primaryContainer : FxColors.surfaceMuted,
        borderRadius: FxRadius.cardBorder,
        child: InkWell(
          borderRadius: FxRadius.cardBorder,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.lg,
              vertical: FxSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: FxTypography.bodyStrong.copyWith(
                      color: selected ? FxColors.primary : FxColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: FxColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
