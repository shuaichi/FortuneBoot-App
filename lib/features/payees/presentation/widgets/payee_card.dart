import 'package:flutter/material.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 交易对象列表行：图标 + 名称 + 收支能力 + ⋯ 菜单。
///
/// 排序等内部字段收进编辑表单；行本身不画卡片、不加阴影。
class PayeeCard extends StatelessWidget {
  final FortunePayeeVo payee;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  const PayeeCard({
    super.key,
    required this.payee,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final disabled = !payee.enable;

    Widget row = Padding(
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
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 19,
              color: disabled ? palette.textTertiary : palette.textSecondary,
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee.payeeName ?? S.of(context).payeesUnnamed,
                  style: FxTypography.bodyStrong.copyWith(
                    color: disabled
                        ? palette.textTertiary
                        : palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_capabilitySummary(context).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _capabilitySummary(context),
                    style: FxTypography.caption.copyWith(
                      color: palette.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: FxSpacing.xs),
          _menuButton(context),
        ],
      ),
    );

    if (disabled) row = Opacity(opacity: 0.55, child: row);

    return InkWell(
      onTap: onTap,
      onLongPress: onMenu,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: row,
      ),
    );
  }

  String _capabilitySummary(BuildContext context) {
    final labels = <String>[
      if (payee.canExpense) S.of(context).payeesCanExpenseShort,
      if (payee.canIncome) S.of(context).payeesCanIncomeShort,
    ];
    return labels.join(' · ');
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
