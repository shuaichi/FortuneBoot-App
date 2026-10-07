import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/account_service.dart';
import 'package:fortuneboot/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_card.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_form_sheet.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_menu.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_type_filter_bar.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/balance_adjust_sheet.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/net_worth_card.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/recycle_bin_sheet.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账户管理 + 净资产页（独立页，Routes.accounts）。
///
/// 顶部：返回 + 新增账户 + 回收站入口。粘顶净资产总览大卡。
/// 账户按 accountType 分组（现金1 → 信用卡2 → 资产3 → 贷款4），每组标题 + 小计。
class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AccountService _service = AccountService();

  /// 净资产下方类型筛选；null = 显示全部。
  int? _filterType;

  AccountsBloc get _bloc => context.read<AccountsBloc>();

  @override
  void initState() {
    super.initState();
    BillMutations.revision.addListener(_onExternalMutation);
  }

  @override
  void dispose() {
    BillMutations.revision.removeListener(_onExternalMutation);
    super.dispose();
  }

  /// 账单变更（记账/编辑/删除/余额调整）会改变账户余额与净资产，需重拉。
  void _onExternalMutation() {
    if (mounted) _bloc.add(const AccountsMutated());
  }

  void _showToast(String message, {FxFeedbackTone tone = FxFeedbackTone.info}) {
    FxFeedback.show(context, message: message, tone: tone);
  }

  int? get _groupId => context.read<SessionCubit>().state.currentGroupId;
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;
  String? get _currency => context.read<SessionCubit>().state.defaultCurrency;

  Future<void> _refreshAccounts() {
    final completer = Completer<void>();
    _bloc.add(AccountsLoaded(completer: completer));
    return completer.future;
  }

  Future<void> _openForm({FortuneAccountVo? account}) async {
    final groupId = _groupId;
    if (groupId == null) {
      _showToast(
        S.of(context).accountsSelectBookGroup,
        tone: FxFeedbackTone.warning,
      );
      return;
    }
    final formKey = GlobalKey<AccountFormSheetState>();
    final changed = await FxSheet.show<bool>(
      context,
      title: account == null
          ? S.of(context).accountsAddTitle
          : S.of(context).accountsEditTitle,
      expand: true,
      submitLabel: account == null
          ? S.of(context).accountsCreateAccount
          : S.of(context).accountsSaveChanges,
      onSubmit: () => formKey.currentState?.submit(),
      child: AccountFormSheet(
        key: formKey,
        service: _service,
        groupId: groupId,
        defaultCurrency: _currency,
        account: account,
        onToggle: account == null
            ? null
            : (field, value) => _bloc.add(
                AccountToggleChanged(
                  account: account,
                  field: field,
                  value: value,
                ),
              ),
      ),
    );
    if (changed == true && mounted) _bloc.add(const AccountsMutated());
  }

  Future<void> _openAdjust(FortuneAccountVo account) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(
        S.of(context).accountsSelectBookForAdjust,
        tone: FxFeedbackTone.warning,
      );
      return;
    }
    final ok = await FxSheet.show<bool>(
      context,
      title: S.of(context).accountsAdjustTitle(account.accountName ?? ''),
      child: BalanceAdjustSheet(
        service: _service,
        account: account,
        bookId: bookId,
      ),
    );
    if (ok == true && mounted) {
      _bloc.add(const AccountsMutated());
      // 余额调整会在后端生成一笔调整账单，通知看板/账单流刷新。
      BillMutations.bump();
      _showToast(
        S.of(context).accountsBalanceAdjusted,
        tone: FxFeedbackTone.success,
      );
    }
  }

  Future<void> _openRecycleBin() async {
    final groupId = _groupId;
    if (groupId == null) {
      _showToast(
        S.of(context).accountsSelectBookGroup,
        tone: FxFeedbackTone.warning,
      );
      return;
    }
    await FxSheet.show<void>(
      context,
      title: S.of(context).accountsRecycleBin,
      child: RecycleBinSheet(service: _service, groupId: groupId),
    );
    if (mounted) _bloc.add(const AccountsMutated());
  }

  Future<void> _openMenu(FortuneAccountVo account) async {
    HapticFeedback.selectionClick();
    final action = await showAccountMenu(context, canAdjust: _bookId != null);
    if (action == null || !mounted) return;
    switch (action) {
      case AccountMenuAction.edit:
        await _openForm(account: account);
      case AccountMenuAction.adjustBalance:
        await _openAdjust(account);
      case AccountMenuAction.moveToRecycleBin:
        await _moveToRecycleBin(account);
      case AccountMenuAction.remove:
        await _remove(account);
    }
  }

  Future<void> _moveToRecycleBin(FortuneAccountVo account) async {
    final groupId = _groupId;
    if (groupId == null || account.accountId == null) return;
    final ok = await confirmDangerAction(
      context,
      title: S.of(context).accountsMoveToRecycleBinTitle,
      message: S
          .of(context)
          .accountsMoveToRecycleBinConfirm(
            account.accountName ?? S.of(context).accountsDefaultName,
          ),
      confirmLabel: S.of(context).accountsMoveIn,
    );
    if (ok != true) return;
    try {
      await _service.moveToRecycleBin(
        groupId: groupId,
        accountId: account.accountId!,
      );
      if (mounted) _bloc.add(const AccountsMutated());
    } on Object catch (e) {
      _showToast(
        e is FxApiException ? e.message : e.toString(),
        tone: FxFeedbackTone.error,
      );
    }
  }

  Future<void> _remove(FortuneAccountVo account) async {
    final groupId = _groupId;
    if (groupId == null || account.accountId == null) return;
    final ok = await confirmDangerAction(
      context,
      title: S.of(context).accountsDeletePermanently,
      message: S
          .of(context)
          .accountsDeleteConfirm(
            account.accountName ?? S.of(context).accountsDefaultName,
          ),
      confirmLabel: S.of(context).accountsDelete,
    );
    if (ok != true) return;
    try {
      await _service.remove(groupId: groupId, accountId: account.accountId!);
      if (mounted) _bloc.add(const AccountsMutated());
    } on Object catch (e) {
      _showToast(
        e is FxApiException ? e.message : e.toString(),
        tone: FxFeedbackTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = context.select<SessionCubit, int?>(
      (c) => c.state.currentGroupId,
    );

    return _GroupSync(
      groupId: groupId,
      child: Scaffold(
        backgroundColor: FxPalette.of(context).canvas,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<AccountsBloc, AccountsState>(
            listenWhen: (prev, curr) =>
                curr.toastMessage != null &&
                prev.toastMessage != curr.toastMessage,
            listener: (context, state) {
              final msg = state.toastMessage;
              if (msg != null) _showToast(msg);
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state, groupId)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: S.of(context).accountsTitle,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(S.of(context).accountsTitle, style: FxTypography.title),
          ),
          FxIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: S.of(context).accountsRecycleBin,
            onPressed: _openRecycleBin,
          ),
          const SizedBox(width: FxSpacing.xs),
          FxIconButton(
            icon: Icons.add_rounded,
            tooltip: S.of(context).accountsAddTitle,
            onPressed: () => _openForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AccountsState state, int? groupId) {
    if (groupId == null) {
      return FxStateView.empty(message: S.of(context).accountsSelectBookGroup);
    }
    switch (state.status) {
      case AccountsStatus.initial:
      case AccountsStatus.loading:
        return FxStateView.loading();
      case AccountsStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const AccountsLoaded()),
        );
      case AccountsStatus.empty:
        return RefreshIndicator(
          onRefresh: _refreshAccounts,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(FxSpacing.lg),
                child: Column(
                  children: [
                    NetWorthCard(
                      assets: state.assets,
                      currencyCode: state.currencyCode,
                    ),
                    const SizedBox(height: FxSpacing.md),
                    AccountTypeFilterBar(
                      selectedType: _filterType,
                      onChanged: (type) => setState(() => _filterType = type),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                    FxSheet.mediumHeightFactor,
                child: FxStateView.empty(
                  message: S.of(context).accountsEmptyHint,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
        );
      case AccountsStatus.loaded:
        return _buildList(state);
    }
  }

  Widget _buildList(AccountsState state) {
    final counts = <int, int>{};
    for (final a in state.accounts) {
      final id = AccountTypeMeta.of(a.accountType).id;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final groups = _filterType == null
        ? state.groups
        : state.groups.where((g) => g.meta.id == _filterType).toList();

    return RefreshIndicator(
      onRefresh: _refreshAccounts,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.xs,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: Column(
                children: [
                  NetWorthCard(
                    assets: state.assets,
                    currencyCode: state.currencyCode,
                  ),
                  const SizedBox(height: FxSpacing.md),
                  AccountTypeFilterBar(
                    selectedType: _filterType,
                    counts: counts,
                    onChanged: (type) => setState(() => _filterType = type),
                  ),
                ],
              ),
            ),
          ),
          if (groups.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: FxStateView.empty(
                message: S.of(context).accountsEmptyHint,
                icon: Icons.account_balance_wallet_outlined,
              ),
            )
          else
            for (final group in groups) ...[
              SliverToBoxAdapter(
                child: _groupHeader(group, state.currencyCode),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final account = group.accounts[i];
                  return AccountCard(
                    account: account,
                    currencyCode: state.currencyCode,
                    onTap: () => _openForm(account: account),
                    onMenu: () => _openMenu(account),
                    onAdjustBalance: () => _openAdjust(account),
                  );
                }, childCount: group.accounts.length),
              ),
            ],
          const SliverToBoxAdapter(child: SizedBox(height: FxSpacing.xxxl)),
        ],
      ),
    );
  }

  Widget _groupHeader(AccountGroup group, String? currencyCode) {
    final palette = FxPalette.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        FxSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: group.meta.tint(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: Text(
              group.meta.localizedName(context),
              style: FxTypography.label.copyWith(color: palette.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: FxMoneyText(
                  amount: group.subtotal,
                  currencyCode: currencyCode,
                  fontSize: 13,
                  colorBySign: group.meta.isLiability,
                  color: group.meta.isLiability ? null : palette.textPrimary,
                  masked: hideAmounts,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 把 SessionCubit 的 groupId 变化派发给 AccountsBloc（切分组重拉）。
class _GroupSync extends StatefulWidget {
  final int? groupId;
  final Widget child;
  const _GroupSync({required this.groupId, required this.child});

  @override
  State<_GroupSync> createState() => _GroupSyncState();
}

class _GroupSyncState extends State<_GroupSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountsBloc>().add(AccountsGroupChanged(widget.groupId));
    });
  }

  @override
  void didUpdateWidget(_GroupSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      context.read<AccountsBloc>().add(AccountsGroupChanged(widget.groupId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
