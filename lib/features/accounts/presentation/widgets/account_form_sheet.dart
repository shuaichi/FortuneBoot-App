import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/account_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账户新增/编辑表单（在 FxSheet 内滚动展示）。
///
/// - 新增：填名称/类型/期初余额/币种/各 can*/计入净产/启用 + 信用卡/贷款额度等
///   → POST /add，成功 pop(true)。
/// - 编辑：开关集合（canExpense/canIncome/canTransferOut/canTransferIn/include/enable）
///   通过 [onToggle] 逐个即时 PATCH（乐观更新在 bloc 侧）；其余字段"保存"走 PUT /modify。
class AccountFormSheet extends StatefulWidget {
  final AccountService service;
  final int groupId;
  final String? defaultCurrency;
  final FortuneAccountVo? account; // null=新增
  final void Function(AccountToggleField field, bool value)? onToggle;

  const AccountFormSheet({
    super.key,
    required this.service,
    required this.groupId,
    this.defaultCurrency,
    this.account,
    this.onToggle,
  });

  bool get isEdit => account != null;

  @override
  State<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<AccountFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cardNoCtrl;
  late final TextEditingController _balanceCtrl;
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _creditLimitCtrl;
  late final TextEditingController _billDayCtrl;
  late final TextEditingController _repayDayCtrl;
  late final TextEditingController _aprCtrl;
  late final TextEditingController _remarkCtrl;

  late int _accountType;
  late bool _canExpense;
  late bool _canIncome;
  late bool _canTransferOut;
  late bool _canTransferIn;
  late bool _include;
  late bool _enable;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameCtrl = TextEditingController(text: a?.accountName ?? '');
    _cardNoCtrl = TextEditingController(text: a?.cardNo ?? '');
    _balanceCtrl = TextEditingController(
      text: a == null ? '' : a.balance.toStringAsFixed(2),
    );
    _currencyCtrl = TextEditingController(
      text: a?.currencyCode ?? widget.defaultCurrency ?? 'CNY',
    );
    _creditLimitCtrl = TextEditingController(
      text: a?.creditLimit == null ? '' : '${a!.creditLimit}',
    );
    _billDayCtrl = TextEditingController(text: a?.billDay ?? '');
    _repayDayCtrl = TextEditingController(text: a?.repayDay ?? '');
    _aprCtrl = TextEditingController(text: a?.apr == null ? '' : '${a!.apr}');
    _remarkCtrl = TextEditingController(text: a?.remark ?? '');

    _accountType = a?.accountType ?? 1;
    _canExpense = a?.canExpense ?? true;
    _canIncome = a?.canIncome ?? true;
    _canTransferOut = a?.canTransferOut ?? true;
    _canTransferIn = a?.canTransferIn ?? true;
    _include = a?.include ?? true;
    _enable = a?.enable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cardNoCtrl.dispose();
    _balanceCtrl.dispose();
    _currencyCtrl.dispose();
    _creditLimitCtrl.dispose();
    _billDayCtrl.dispose();
    _repayDayCtrl.dispose();
    _aprCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  bool get _isCredit => _accountType == 2;
  bool get _isLoan => _accountType == 4;

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'groupId': widget.groupId,
      'accountName': _nameCtrl.text.trim(),
      'accountType': _accountType,
      'currencyCode': _currencyCtrl.text.trim(),
    };
    // 编辑模式下 6 个开关只走独立 PATCH（onToggle），modify 不再携带它们，
    // 否则会把某个 PATCH 失败已被 bloc 回滚的值重新提交，造成真值来源冲突。
    if (!widget.isEdit) {
      body['canExpense'] = _canExpense;
      body['canIncome'] = _canIncome;
      body['canTransferOut'] = _canTransferOut;
      body['canTransferIn'] = _canTransferIn;
      body['include'] = _include;
      body['enable'] = _enable;
    }
    if (widget.isEdit) body['accountId'] = widget.account!.accountId;
    final cardNo = _cardNoCtrl.text.trim();
    if (cardNo.isNotEmpty) body['cardNo'] = cardNo;
    final balance = double.tryParse(_balanceCtrl.text.trim());
    if (balance != null) body['balance'] = balance;
    final remark = _remarkCtrl.text.trim();
    if (remark.isNotEmpty) body['remark'] = remark;

    if (_isCredit || _isLoan) {
      final limit = double.tryParse(_creditLimitCtrl.text.trim());
      if (limit != null) body['creditLimit'] = limit;
      final repay = _repayDayCtrl.text.trim();
      if (repay.isNotEmpty) body['repayDay'] = repay;
    }
    if (_isCredit) {
      final bill = _billDayCtrl.text.trim();
      if (bill.isNotEmpty) body['billDay'] = bill;
    }
    if (_isLoan) {
      final apr = double.tryParse(_aprCtrl.text.trim());
      if (apr != null) body['apr'] = apr;
    }
    return body;
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).accountsNameRequired);
      return;
    }
    if (_currencyCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).accountsCurrencyRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final body = _buildBody();
      if (widget.isEdit) {
        await widget.service.modifyAccount(body);
      } else {
        await widget.service.addAccount(body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(S.of(context).accountsFieldName),
          TextField(
            controller: _nameCtrl,
            decoration: _dec(S.of(context).accountsFieldNameHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).accountsFieldType),
          _typeSelector(),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label(
                      widget.isEdit
                          ? S.of(context).accountsFieldBalance
                          : S.of(context).accountsFieldInitialBalance,
                    ),
                    TextField(
                      controller: _balanceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: _dec('0.00'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label(S.of(context).accountsFieldCurrency),
                    TextField(
                      controller: _currencyCtrl,
                      decoration: _dec('CNY'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).accountsFieldCardNo),
          TextField(
            controller: _cardNoCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec(S.of(context).accountsFieldCardNoHint),
          ),
          if (_isCredit || _isLoan) ...[
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).accountsFieldCreditLimit),
            TextField(
              controller: _creditLimitCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _dec(S.of(context).accountsFieldCreditLimitHint),
            ),
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).accountsFieldRepayDay),
            TextField(
              controller: _repayDayCtrl,
              decoration: _dec('2026-08-15'),
            ),
          ],
          if (_isCredit) ...[
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).accountsFieldBillDay),
            TextField(controller: _billDayCtrl, decoration: _dec('2026-08-01')),
          ],
          if (_isLoan) ...[
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).accountsFieldApr),
            TextField(
              controller: _aprCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _dec(S.of(context).accountsFieldAprHint),
            ),
          ],
          const SizedBox(height: FxSpacing.lg),
          _switches(),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).accountsRemarkOptional),
          TextField(
            controller: _remarkCtrl,
            decoration: _dec(S.of(context).accountsRemarkHint),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).danger,
              ),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit
                ? S.of(context).accountsSaveChanges
                : S.of(context).accountsCreateAccount,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _typeSelector() {
    return Wrap(
      spacing: FxSpacing.sm,
      children: AccountTypeMeta.ordered.map((meta) {
        final selected = meta.id == _accountType;
        return FxChip(
          label: meta.localizedName(context),
          icon: meta.icon,
          selected: selected,
          onTap: () => setState(() => _accountType = meta.id),
        );
      }).toList(),
    );
  }

  Widget _switches() {
    return Column(
      children: [
        _switchRow(AccountToggleField.canExpense, _canExpense, (v) {
          setState(() => _canExpense = v);
        }),
        _switchRow(AccountToggleField.canIncome, _canIncome, (v) {
          setState(() => _canIncome = v);
        }),
        _switchRow(AccountToggleField.canTransferOut, _canTransferOut, (v) {
          setState(() => _canTransferOut = v);
        }),
        _switchRow(AccountToggleField.canTransferIn, _canTransferIn, (v) {
          setState(() => _canTransferIn = v);
        }),
        _switchRow(AccountToggleField.include, _include, (v) {
          setState(() => _include = v);
        }),
        _switchRow(AccountToggleField.enable, _enable, (v) {
          setState(() => _enable = v);
        }),
      ],
    );
  }

  Widget _switchRow(
    AccountToggleField field,
    bool value,
    ValueChanged<bool> onLocal,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(_toggleLabel(field), style: FxTypography.body)),
          Switch.adaptive(
            value: value,
            activeColor: FxPalette.of(context).primary,
            onChanged: (v) {
              onLocal(v);
              // 编辑模式：即时 PATCH（乐观更新在 bloc 侧）。
              if (widget.isEdit) widget.onToggle?.call(field, v);
            },
          ),
        ],
      ),
    );
  }

  String _toggleLabel(AccountToggleField field) {
    final s = S.of(context);
    switch (field) {
      case AccountToggleField.canExpense:
        return s.accountsToggleCanExpense;
      case AccountToggleField.canIncome:
        return s.accountsToggleCanIncome;
      case AccountToggleField.canTransferOut:
        return s.accountsToggleCanTransferOut;
      case AccountToggleField.canTransferIn:
        return s.accountsToggleCanTransferIn;
      case AccountToggleField.include:
        return s.accountsToggleInclude;
      case AccountToggleField.enable:
        return s.accountsToggleEnable;
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: FxPalette.of(context).surfaceMuted,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FxSpacing.md,
      vertical: FxSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: FxRadius.tileBorder,
      borderSide: BorderSide.none,
    ),
  );
}
