import 'package:flutter/material.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
    return Material(
      color: FxColors.surface,
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
                decoration: const BoxDecoration(
                  color: FxColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: member.enable
                      ? FxColors.primary
                      : FxColors.textTertiary,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Text(
                  member.memberName ?? '未命名',
                  style: FxTypography.bodyStrong.copyWith(
                    color: member.enable
                        ? FxColors.textPrimary
                        : FxColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _statusChip(member.enable),
              const SizedBox(width: FxSpacing.sm),
              InkResponse(
                radius: 18,
                onTap: onMenu,
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: FxColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool enable) {
    final color = enable ? FxColors.success : FxColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(
        enable ? '启用' : '停用',
        style: FxTypography.caption.copyWith(color: color),
      ),
    );
  }
}
