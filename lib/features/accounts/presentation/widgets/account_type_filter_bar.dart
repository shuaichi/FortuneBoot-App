import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 净资产下方的账户类型筛选：现金 / 信用卡 / 资产 / 贷款。
///
/// [selectedType] 为 null 表示全部；再次点击已选项可取消筛选。
class AccountTypeFilterBar extends StatelessWidget {
  const AccountTypeFilterBar({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.counts = const {},
  });

  /// 当前选中的 [AccountTypeMeta.id]；null = 全部。
  final int? selectedType;
  final ValueChanged<int?> onChanged;

  /// 各类型账户数量（可选，用于角标）。
  final Map<int, int> counts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < AccountTypeMeta.ordered.length; i++) ...[
          if (i > 0) const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: _TypeButton(
              meta: AccountTypeMeta.ordered[i],
              selected: selectedType == AccountTypeMeta.ordered[i].id,
              count: counts[AccountTypeMeta.ordered[i].id] ?? 0,
              onTap: () {
                HapticFeedback.selectionClick();
                final id = AccountTypeMeta.ordered[i].id;
                onChanged(selectedType == id ? null : id);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.meta,
    required this.selected,
    required this.count,
    required this.onTap,
  });

  final AccountTypeMeta meta;
  final bool selected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final tint = meta.tint(context);
    final bg = selected ? tint.withValues(alpha: 0.14) : palette.surface;
    final border = selected
        ? tint.withValues(alpha: 0.55)
        : palette.border.withValues(alpha: 0.7);
    final fg = selected ? tint : palette.textSecondary;

    return Material(
      color: bg,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: FxRadius.tileBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.xs,
            vertical: FxSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: FxRadius.tileBorder,
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(meta.icon, size: 20, color: fg),
              const SizedBox(height: FxSpacing.xs),
              Text(
                meta.localizedName(context),
                style: FxTypography.caption.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (count > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: FxTypography.caption.copyWith(
                    color: fg.withValues(alpha: 0.85),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
