import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/features/payees/data/payee_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 交易对象新增/编辑表单。字段：名称 / 排序 / 备注 / 启用
/// + 开关 canExpense/canIncome。编辑模式开关即时 PATCH（乐观更新在 bloc）。
class PayeeFormSheet extends StatefulWidget {
  final PayeeService service;
  final int bookId;
  final FortunePayeeVo? payee;
  final void Function(PayeeToggleField field, bool value)? onToggle;

  const PayeeFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    this.payee,
    this.onToggle,
  });

  bool get isEdit => payee != null;

  @override
  State<PayeeFormSheet> createState() => _PayeeFormSheetState();
}

class _PayeeFormSheetState extends State<PayeeFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _remarkCtrl;

  late bool _canExpense;
  late bool _canIncome;
  late bool _enable;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.payee;
    _nameCtrl = TextEditingController(text: p?.payeeName ?? '');
    _sortCtrl = TextEditingController(text: p?.sort?.toString() ?? '');
    _remarkCtrl = TextEditingController(text: p?.remark ?? '');
    _canExpense = p?.canExpense ?? true;
    _canIncome = p?.canIncome ?? true;
    _enable = p?.enable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入交易对象名称');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'bookId': widget.bookId,
      'payeeName': _nameCtrl.text.trim(),
      'canExpense': _canExpense,
      'canIncome': _canIncome,
      'enable': _enable,
    };
    if (widget.isEdit) body['payeeId'] = widget.payee!.payeeId;
    final sort = int.tryParse(_sortCtrl.text.trim());
    if (sort != null) body['sort'] = sort;
    final remark = _remarkCtrl.text.trim();
    if (remark.isNotEmpty) body['remark'] = remark;

    try {
      if (widget.isEdit) {
        await widget.service.modify(body);
      } else {
        await widget.service.add(body);
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
    final palette = FxPalette.of(context);
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
          const ManageFieldLabel('交易对象名称'),
          TextField(
            controller: _nameCtrl,
            decoration: manageInputDecoration(context, '如：肯德基'),
          ),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('排序（可选）'),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: manageInputDecoration(context, '数字越小越靠前'),
          ),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('备注（可选）'),
          TextField(
            controller: _remarkCtrl,
            decoration: manageInputDecoration(context, '备注'),
          ),
          const SizedBox(height: FxSpacing.lg),
          _switchRow(context, PayeeToggleField.canExpense, _canExpense, (v) {
            setState(() => _canExpense = v);
          }),
          _switchRow(context, PayeeToggleField.canIncome, _canIncome, (v) {
            setState(() => _canIncome = v);
          }),
          _switchRow(context, PayeeToggleField.enable, _enable, (v) {
            setState(() => _enable = v);
          }),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit ? '保存修改' : '创建交易对象',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    BuildContext context,
    PayeeToggleField field,
    bool value,
    ValueChanged<bool> onLocal,
  ) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(field.label, style: FxTypography.body)),
          Switch.adaptive(
            value: value,
            activeColor: palette.primary,
            onChanged: (v) {
              onLocal(v);
              if (widget.isEdit) widget.onToggle?.call(field, v);
            },
          ),
        ],
      ),
    );
  }
}
