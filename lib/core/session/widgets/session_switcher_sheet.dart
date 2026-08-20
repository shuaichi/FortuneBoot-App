import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 统一的分组 / 账本切换 sheet：分组用横向 pill，账本用卡片（含币种、当前/默认标识）。
///
/// 全局共用，取代 Dashboard / Profile 各自内联实现。
class SessionSwitcherSheet extends StatelessWidget {
  final SessionCubit cubit;
  const SessionSwitcherSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<SessionCubit>();
    return FxSheet.show<void>(
      context,
      title: S.of(context).booksManageTitle,
      scrollable: true,
      maxHeightFactor: FxSheet.detailHeightFactor,
      child: SessionSwitcherSheet(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return BlocBuilder<SessionCubit, SessionState>(
      bloc: cubit,
      builder: (context, state) {
        final loading = state.status == SessionStatus.loading;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            0,
            FxSpacing.lg,
            FxSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).booksTabGroups,
                style: FxTypography.label.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: FxSpacing.sm),
              if (state.groups.isEmpty)
                _empty(palette, S.of(context).booksEmptyGroups)
              else
                Wrap(
                  spacing: FxSpacing.sm,
                  runSpacing: FxSpacing.sm,
                  children: [
                    for (final g in state.groups)
                      _GroupPill(
                        group: g,
                        selected: g.groupId == state.currentGroupId,
                        onTap: loading ? null : () => cubit.switchGroup(g),
                      ),
                  ],
                ),
              const SizedBox(height: FxSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).booksTabBooks,
                    style: FxTypography.label.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: FxSpacing.sm),
              if (state.status == SessionStatus.error)
                FxStateView.error(
                  message: S.of(context).dashboardLoadFailed,
                  retryLabel: S.of(context).commonRetry,
                  onRetry: () {
                    final target =
                        state.currentGroup ??
                        (state.groups.isNotEmpty ? state.groups.first : null);
                    if (target != null) {
                      cubit.switchGroup(target);
                    } else {
                      cubit.load();
                    }
                  },
                )
              else if (state.books.isEmpty && !loading)
                _empty(palette, S.of(context).booksGroupNoBooks)
              else
                ...state.books.map(
                  (b) => _BookCard(
                    book: b,
                    selected: b.bookId == state.currentBookId,
                    isDefault: b.bookId == state.currentGroup?.defaultBookId,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      cubit.switchBook(b);
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
              const SizedBox(height: FxSpacing.md),
              InkWell(
                borderRadius: FxRadius.tileBorder,
                onTap: () {
                  Navigator.of(context).maybePop();
                  AppRouter.push<void>(context, Routes.books);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FxSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        size: 18,
                        color: palette.primary,
                      ),
                      const SizedBox(width: FxSpacing.sm),
                      Text(
                        S.of(context).booksManageTitle,
                        style: FxTypography.bodyStrong.copyWith(
                          color: palette.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(FxPalette palette, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: FxSpacing.md),
    child: Text(
      text,
      style: FxTypography.caption.copyWith(color: palette.textTertiary),
    ),
  );
}

class _GroupPill extends StatelessWidget {
  final FortuneGroupVo group;
  final bool selected;
  final VoidCallback? onTap;
  const _GroupPill({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? palette.primary : palette.surfaceMuted,
          borderRadius: FxRadius.pillBorder,
          border: Border.all(
            color: selected ? palette.primary : palette.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_rounded,
              size: 16,
              color: selected ? palette.onPrimary : palette.textSecondary,
            ),
            const SizedBox(width: FxSpacing.xs),
            Text(
              group.groupName ?? '未命名分组',
              style: FxTypography.caption.copyWith(
                color: selected ? palette.onPrimary : palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final FortuneBookVo book;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;
  const _BookCard({
    required this.book,
    required this.selected,
    required this.isDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.sm),
      child: Material(
        color: selected ? palette.primaryContainer : palette.surfaceMuted,
        borderRadius: FxRadius.cardBorder,
        child: InkWell(
          borderRadius: FxRadius.cardBorder,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.lg,
              vertical: FxSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: FxRadius.cardBorder,
              border: Border.all(
                color: selected ? palette.primary : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: selected ? palette.primary : palette.textSecondary,
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.bookName ?? '未命名账本',
                        style: FxTypography.bodyStrong.copyWith(
                          color: selected
                              ? palette.primary
                              : palette.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (book.defaultCurrency?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          book.defaultCurrency!,
                          style: FxTypography.caption.copyWith(
                            color: palette.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isDefault) _badge(palette, '默认'),
                if (selected) ...[
                  const SizedBox(width: FxSpacing.sm),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: palette.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(FxPalette palette, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: palette.info.withValues(alpha: 0.14),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(
        text,
        style: FxTypography.caption.copyWith(color: palette.info),
      ),
    );
  }
}
