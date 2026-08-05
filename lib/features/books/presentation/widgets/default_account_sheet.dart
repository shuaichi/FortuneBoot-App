import 'package:flutter/material.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class DefaultAccountSheet extends StatefulWidget {
  const DefaultAccountSheet({
    super.key,
    required this.kind,
    required this.accounts,
    this.selectedAccountId,
  });

  final DefaultAccountKind kind;
  final List<AccountOptionVo> accounts;
  final int? selectedAccountId;

  @override
  State<DefaultAccountSheet> createState() => _DefaultAccountSheetState();
}

class _DefaultAccountSheetState extends State<DefaultAccountSheet> {
  late int? _selectedId = widget.selectedAccountId;

  @override
  Widget build(BuildContext context) {
    if (widget.accounts.isEmpty) {
      return FxStateView.empty(
        message: '本分组暂无启用账户\n可先保存账本，稍后在账户管理中设置默认账户',
        icon: Icons.account_balance_wallet_outlined,
      );
    }
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.kind.label, style: FxTypography.title),
          const SizedBox(height: FxSpacing.md),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final account = widget.accounts[index];
                final enabled = account.canUseFor(widget.kind);
                return RadioListTile<int?>(
                  value: account.accountId,
                  groupValue: _selectedId,
                  onChanged: enabled
                      ? (value) => setState(() => _selectedId = value)
                      : null,
                  title: Text(account.name),
                  subtitle: Text(
                    enabled
                        ? account.currency ?? 'CNY'
                        : '该账户不支持${widget.kind.label.replaceFirst('默认', '')}',
                    style: FxTypography.caption.copyWith(
                      color: enabled ? palette.textSecondary : palette.warning,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => Divider(color: palette.border),
              itemCount: widget.accounts.length,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          FxButton.tonal(
            label: '清除选择',
            expand: true,
            onPressed: () => setState(() => _selectedId = null),
          ),
          const SizedBox(height: FxSpacing.sm),
          FxButton(
            label: '确认',
            expand: true,
            onPressed: () => Navigator.of(context).pop(_selectedId),
          ),
        ],
      ),
    );
  }
}
