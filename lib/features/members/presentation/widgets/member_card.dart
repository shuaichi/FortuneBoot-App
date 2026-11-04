import 'package:flutter/material.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 成员列表行：头像 + 名称 + 启用开关 + ⋯ 菜单。
///
/// 行本身不画卡片、不加阴影，由外层 FxListSection 提供连续表面。
class MemberCard extends StatelessWidget {
  final FortuneMemberVo member;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  /// 启用/停用切换；为 null 时不展示开关（如回收站）。
  final ValueChanged<bool>? onToggleEnable;

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
    final disabled = !member.enable;

    final row = Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initial(context),
              style: FxTypography.bodyStrong.copyWith(
                color: disabled ? palette.textTertiary : palette.textPrimary,
              ),
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
          if (onToggleEnable != null)
            Semantics(
              label: member.enable
                  ? S.of(context).membersStatusEnabled
                  : S.of(context).membersStatusDisabled,
              child: Switch.adaptive(
                value: member.enable,
                activeThumbColor: palette.primary,
                onChanged: onToggleEnable,
              ),
            ),
          const SizedBox(width: FxSpacing.xs),
          _menuButton(context),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onMenu,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: row,
      ),
    );
  }

  String _initial(BuildContext context) {
    final name = member.memberName ?? '';
    if (name.trim().isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  Widget _menuButton(BuildContext context) {
    final palette = FxPalette.of(context);
    final tooltip = MaterialLocalizations.of(context).showMenuTooltip;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
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
    );
  }
}
