import 'package:flutter/material.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 成员卡：悬浮卡片风格。头像徽章 + 名称/停用置灰 + 启用切换按钮 + ⋯ 菜单。
class MemberCard extends StatelessWidget {
  final FortuneMemberVo member;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  /// 点击启用/停用按钮；为 null 时不展示可点切换（如回收站）。
  final VoidCallback? onToggleEnable;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
    required this.onMenu,
    this.onToggleEnable,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final disabled = !member.enable;
    final tint = disabled ? palette.textTertiary : finance.income;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onMenu,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(FxSpacing.md),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: FxRadius.cardBorder,
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initial(context),
                style: FxTypography.bodyStrong.copyWith(color: tint),
              ),
            ),
            const SizedBox(width: FxSpacing.md),
            Expanded(
              child: Text(
                member.memberName ?? S.of(context).membersUnnamed,
                style: FxTypography.bodyStrong.copyWith(
                  color: disabled ? palette.textTertiary : palette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _enableButton(context, member.enable),
            const SizedBox(width: FxSpacing.sm),
            Semantics(
              button: true,
              label: MaterialLocalizations.of(context).showMenuTooltip,
              child: Tooltip(
                message: MaterialLocalizations.of(context).showMenuTooltip,
                child: InkResponse(
                  radius: 24,
                  onTap: onMenu,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initial(BuildContext context) {
    final name = member.memberName ?? '';
    if (name.trim().isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  Widget _enableButton(BuildContext context, bool enable) {
    final palette = FxPalette.of(context);
    final color = enable ? palette.success : palette.textTertiary;
    final label = enable
        ? S.of(context).membersStatusEnabled
        : S.of(context).membersStatusDisabled;
    final child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: FxSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: FxTypography.caption.copyWith(color: color),
      ),
    );
    if (onToggleEnable == null) return child;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleEnable,
          borderRadius: FxRadius.pillBorder,
          child: child,
        ),
      ),
    );
  }
}
