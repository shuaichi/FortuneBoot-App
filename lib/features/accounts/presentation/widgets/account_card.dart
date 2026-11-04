import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/bank_icon.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账户列表行：账户名 / 类型 / 余额 / 溢出菜单。
///
/// 行本身不画卡片、不加阴影，由外层 FxListSection 提供连续表面；
/// 调整余额等低频操作收进 ⋯ 菜单，避免每行出现大按钮与状态彩点。
class AccountCard extends StatelessWidget {
  final FortuneAccountVo account;
  final String? currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;

  const AccountCard({
    super.key,
    required this.account,
    this.currencyCode,
    this.onTap,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final meta = AccountTypeMeta.of(account.accountType);
    final disabled = !account.enable;
    final code = account.currencyCode ?? currencyCode;
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    final balanceColor = meta.isLiability ? palette.danger : palette.success;

    Widget row = Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.sm,
        FxSpacing.md,
      ),
      child: Row(
        children: [
          BankIcon.fromAccount(account: account, size: 36, iconSize: 18),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        account.accountName ?? S.of(context).accountsUnnamed,
                        style: FxTypography.bodyStrong.copyWith(
                          color: disabled
                              ? palette.textTertiary
                              : palette.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (account.lastFour != null) ...[
                      const SizedBox(width: FxSpacing.sm),
                      Text(
                        '···${account.lastFour}',
                        style: FxTypography.caption.copyWith(
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  meta.localizedName(context),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 132),
            child: FxMoneyText(
              amount: account.displayBalance,
              currencyCode: code,
              fontWeight: FontWeight.w700,
              color: disabled ? palette.textTertiary : balanceColor,
              masked: hideAmounts,
              compactWhenNeeded: true,
            ),
          ),
          if (onMenu != null) _menuButton(context),
        ],
      ),
    );

    if (disabled) row = Opacity(opacity: 0.55, child: row);

    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: account.accountName ?? S.of(context).accountsUnnamed,
      child: InkWell(
        onTap: onTap,
        onLongPress: onMenu,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: row,
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    final palette = FxPalette.of(context);
    final tooltip = S.of(context).commonMoreActions;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onMenu,
          radius: 24,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.more_horiz_rounded, color: palette.textTertiary),
          ),
        ),
      ),
    );
  }
}
