import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/account_service.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_menu.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/bank_icon.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 回收站：列出 recycleBin=true 的账户，可 putBack / remove。
/// 有任一变更时 pop(true) 让页面刷新主列表。
class RecycleBinSheet extends StatefulWidget {
  final AccountService service;
  final int groupId;

  const RecycleBinSheet({
    super.key,
    required this.service,
    required this.groupId,
  });

  @override
  State<RecycleBinSheet> createState() => _RecycleBinSheetState();
}

class _RecycleBinSheetState extends State<RecycleBinSheet> {
  bool _loading = true;
  String? _error;
  List<FortuneAccountVo> _accounts = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await widget.service.getAllAccounts(
        widget.groupId,
        recycleBin: true,
      );
      if (mounted) {
        setState(() {
          _accounts = rows;
          _loading = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  Future<void> _putBack(FortuneAccountVo a) async {
    if (a.accountId == null) return;
    try {
      await widget.service.putBack(
        groupId: widget.groupId,
        accountId: a.accountId!,
      );
      await _load();
    } on Object catch (e) {
      _showError(e);
    }
  }

  Future<void> _remove(FortuneAccountVo a) async {
    if (a.accountId == null) return;
    final ok = await confirmDangerAction(
      context,
      title: S.of(context).accountsDeletePermanently,
      message: S
          .of(context)
          .accountsDeleteConfirm(
            a.accountName ?? S.of(context).accountsDefaultName,
          ),
      confirmLabel: S.of(context).accountsDelete,
    );
    if (ok != true) return;
    try {
      await widget.service.remove(
        groupId: widget.groupId,
        accountId: a.accountId!,
      );
      await _load();
    } on Object catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    FxFeedback.error(
      context,
      message: e is FxApiException ? e.message : e.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_loading) return FxStateView.loading();
    if (_error != null) {
      return FxStateView.error(message: _error, onRetry: _load);
    }
    if (_accounts.isEmpty) {
      return FxStateView.empty(
        message: S.of(context).accountsRecycleBinEmpty,
        icon: Icons.delete_outline_rounded,
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
      itemCount: _accounts.length,
      itemBuilder: (context, i) => _tile(context, _accounts[i]),
    );
  }

  Widget _tile(BuildContext context, FortuneAccountVo a) {
    final palette = FxPalette.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    return Container(
      margin: const EdgeInsets.only(bottom: FxSpacing.sm),
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: Row(
        children: [
          BankIcon.fromAccount(account: a, size: 36, iconSize: 18),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.accountName ?? S.of(context).accountsUnnamed,
                  style: FxTypography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FxMoneyText(
                  amount: a.displayBalance,
                  currencyCode: a.currencyCode,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: palette.textSecondary,
                  masked: hideAmounts,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _putBack(a),
            child: Text(S.of(context).accountsRestore),
          ),
          FxIconButton(
            icon: Icons.delete_forever_rounded,
            tooltip: S.of(context).accountsDelete,
            color: palette.danger,
            onPressed: () => _remove(a),
          ),
        ],
      ),
    );
  }
}
