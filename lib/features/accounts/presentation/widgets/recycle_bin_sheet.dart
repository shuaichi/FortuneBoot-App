import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/account_service.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_menu.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
      title: '彻底删除',
      message: '确定彻底删除「${a.accountName ?? '该账户'}」吗？此操作不可撤销。',
      confirmLabel: '删除',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e is FxApiException ? e.message : e.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return FxStateView.loading();
    if (_error != null) {
      return FxStateView.error(message: _error, onRetry: _load);
    }
    if (_accounts.isEmpty) {
      return FxStateView.empty(
        message: '回收站为空',
        icon: Icons.delete_outline_rounded,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
      itemCount: _accounts.length,
      itemBuilder: (context, i) => _tile(_accounts[i]),
    );
  }

  Widget _tile(FortuneAccountVo a) {
    final meta = AccountTypeMeta.of(a.accountType);
    return Container(
      margin: const EdgeInsets.only(bottom: FxSpacing.sm),
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: FxColors.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: Row(
        children: [
          Icon(meta.icon, color: meta.tint, size: 20),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.accountName ?? '未命名账户',
                  style: FxTypography.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FxMoneyText(
                  amount: a.displayBalance,
                  currencyCode: a.currencyCode,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: FxColors.textSecondary,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _putBack(a),
            child: const Text('移出'),
          ),
          IconButton(
            onPressed: () => _remove(a),
            icon: const Icon(
              Icons.delete_forever_rounded,
              color: FxColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
