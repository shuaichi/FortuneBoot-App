import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/bank_icon.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_progress_bar.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账户卡：账户名 + 卡号末四位 + 类型图标 + 余额 + 信用卡额度/账单日/还款日
/// + 可支收转4状态点 + 计入净产标记 + 停用置灰。
class AccountCard extends StatelessWidget {
  final FortuneAccountVo account;
  final String? currencyCode;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final VoidCallback? onAdjustBalance;

  const AccountCard({
    super.key,
    required this.account,
    this.currencyCode,
    this.onTap,
    this.onMenu,
    this.onAdjustBalance,
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

    Widget card = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.xs,
      ),
      padding: const EdgeInsets.all(FxSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(context, meta),
          const SizedBox(height: FxSpacing.sm),
          _balanceBlock(context, code, hideAmounts),
          const SizedBox(height: FxSpacing.md),
          if (meta.isLiability && (account.creditLimit ?? 0) > 0)
            _creditSection(context, code, hideAmounts),
          if (meta.isLiability) _creditDatesRow(context),
          if (disabled) ...[
            _disabledChip(context),
            const SizedBox(height: FxSpacing.sm),
          ],
          _footerRow(context),
        ],
      ),
    );

    if (disabled) {
      card = Opacity(opacity: 0.5, child: card);
    }

    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onMenu,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }

  Widget _headerRow(BuildContext context, AccountTypeMeta meta) {
    final palette = FxPalette.of(context);
    return Row(
      children: [
        BankIcon.fromAccount(account: account),
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
                      style: FxTypography.bodyStrong,
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
              ),
            ],
          ),
        ),
        const SizedBox(width: FxSpacing.sm),
        if (onMenu != null) _menuButton(context),
      ],
    );
  }

  Widget _balanceBlock(BuildContext context, String? code, bool hideAmounts) {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _AdaptiveMoney(
          amount: account.displayBalance,
          currencyCode: code,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          colorBySign: account.isLiability,
          masked: hideAmounts,
        ),
        if (account.include)
          _metaChip(context, S.of(context).accountsIncludedInNetWorth),
      ],
    );
  }

  Widget _menuButton(BuildContext context) {
    final palette = FxPalette.of(context);
    final tooltip =
        '${S.of(context).accountsEditTitle} '
        '${account.accountName ?? S.of(context).accountsUnnamed}';
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

  /// 信用卡/贷款额度进度：已用 = max(0, -balance)，占额度比例。
  Widget _creditSection(BuildContext context, String? code, bool hideAmounts) {
    final palette = FxPalette.of(context);
    final expense = FxFinanceColors.of(context).expense;
    final limit = account.creditLimit ?? 0;
    final used = account.usedCreditAmount;
    final ratio = limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: FxSpacing.xs,
            runSpacing: FxSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                S.of(context).accountsCreditLimit,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              FxMoneyText(
                amount: limit,
                currencyCode: code,
                fontSize: 12,
                color: palette.textSecondary,
                masked: hideAmounts,
              ),
              Text(
                S.of(context).accountsUsed,
                style: FxTypography.caption.copyWith(
                  color: palette.textTertiary,
                ),
              ),
              FxMoneyText(
                amount: used,
                currencyCode: code,
                fontSize: 12,
                color: expense,
                masked: hideAmounts,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.xs),
          FxProgressBar(value: ratio, color: expense, height: 6),
        ],
      ),
    );
  }

  /// 账单日/还款日/利率 chip。独立于额度渲染——信用卡未设额度时也应显示日期。
  Widget _creditDatesRow(BuildContext context) {
    final chips = <Widget>[
      if (account.billDay != null)
        _metaChip(context, S.of(context).accountsBillDayChip(account.billDay!)),
      if (account.repayDay != null)
        _metaChip(
          context,
          S.of(context).accountsRepayDayChip(account.repayDay!),
        ),
      if (account.apr != null)
        _metaChip(context, S.of(context).accountsAprChip('${account.apr}')),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: Wrap(
        spacing: FxSpacing.sm,
        runSpacing: FxSpacing.xs,
        children: chips,
      ),
    );
  }

  Widget _disabledChip(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      label: S.of(context).booksDisabled,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: palette.warning.withValues(alpha: 0.12),
          borderRadius: FxRadius.pillBorder,
        ),
        child: Text(
          '${S.of(context).booksDisabled} ·',
          style: FxTypography.caption.copyWith(
            color: palette.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _metaChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: FxPalette.of(context).surfaceMuted,
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(
        text,
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      ),
    );
  }

  Widget _footerRow(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return Wrap(
      spacing: FxSpacing.md,
      runSpacing: FxSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _statusDot(
          context,
          S.of(context).accountsDotExpense,
          account.canExpense,
          finance.expense,
        ),
        _statusDot(
          context,
          S.of(context).accountsDotIncome,
          account.canIncome,
          finance.income,
        ),
        _statusDot(
          context,
          S.of(context).accountsDotTransferOut,
          account.canTransferOut,
          finance.transfer,
        ),
        _statusDot(
          context,
          S.of(context).accountsDotTransferIn,
          account.canTransferIn,
          finance.transfer,
        ),
        if (onAdjustBalance != null)
          Semantics(
            button: true,
            child: InkWell(
              onTap: onAdjustBalance,
              borderRadius: FxRadius.pillBorder,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: FxSpacing.md),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.primaryContainer,
                  borderRadius: FxRadius.pillBorder,
                ),
                child: Text(
                  S.of(context).accountsAdjustBalance,
                  style: FxTypography.caption.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusDot(BuildContext context, String label, bool on, Color color) {
    final palette = FxPalette.of(context);
    return Semantics(
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: on ? color : palette.border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: FxTypography.caption.copyWith(
              color: on ? palette.textSecondary : palette.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveMoney extends StatelessWidget {
  const _AdaptiveMoney({
    required this.amount,
    required this.currencyCode,
    required this.fontSize,
    required this.masked,
    this.fontWeight = FontWeight.w600,
    this.colorBySign = false,
  });

  final double amount;
  final String? currencyCode;
  final double fontSize;
  final bool masked;
  final FontWeight fontWeight;
  final bool colorBySign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: fontSize,
              fontWeight: fontWeight,
              colorBySign: colorBySign,
              masked: masked,
            ),
          ),
        );
      },
    );
  }
}
