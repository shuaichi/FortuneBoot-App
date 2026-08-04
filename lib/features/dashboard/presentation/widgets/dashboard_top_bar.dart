import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_switcher_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 看板粘顶栏：左侧 分组·账本 切换器（点击弹 FxSheet），右侧头像（点击可空）。
class DashboardTopBar extends StatelessWidget {
  final VoidCallback? onAvatarTap;
  const DashboardTopBar({super.key, this.onAvatarTap});

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
                          style: FxTypography.caption.copyWith(
                            color: FxPalette.of(context).textTertiary,
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
                                style: FxTypography.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
              decoration: BoxDecoration(
                color: palette.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: palette.primary,
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
    SessionSwitcherSheet.show(context);
  }
}
