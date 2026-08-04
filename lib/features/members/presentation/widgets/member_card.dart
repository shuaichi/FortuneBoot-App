import 'package:flutter/material.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 成员列表项：头像图标 + 名称 + 启用状态 + 排序 + ⋯ 菜单。
class MemberCard extends StatelessWidget {
  final FortuneMemberVo member;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Material(
      color: palette.surface,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: member.enable ? palette.primary : palette.textTertiary,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Text(
                  member.memberName ?? S.of(context).membersUnnamed,
                  style: FxTypography.bodyStrong.copyWith(
                    color: member.enable
                        ? palette.textPrimary
                        : palette.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _statusChip(context, member.enable),
              const SizedBox(width: FxSpacing.sm),
              InkResponse(
                radius: 18,
                onTap: onMenu,
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, bool enable) {
    final palette = FxPalette.of(context);
    final color = enable ? palette.success : palette.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(
        enable
            ? S.of(context).membersStatusEnabled
            : S.of(context).membersStatusDisabled,
        style: FxTypography.caption.copyWith(color: color),
      ),
    );
  }
}
