import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/account_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

/// 余额调整表单：输入调整后金额 + 时间 + 标题 + 备注 → PATCH balanceAdjust。
/// 成功后 pop(true)。需 bookId（页面在打开前已校验非空）。
class BalanceAdjustSheet extends StatefulWidget {
  final AccountService service;
  final FortuneAccountVo account;
  final int bookId;

  const BalanceAdjustSheet({
    super.key,
    required this.service,
    required this.account,
    required this.bookId,
  });

  @override
  State<BalanceAdjustSheet> createState() => _BalanceAdjustSheetState();
}

class _BalanceAdjustSheetState extends State<BalanceAdjustSheet> {
  late final TextEditingController _amountCtrl = TextEditingController(
    text: widget.account.balance.toStringAsFixed(2),
  );
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();
  DateTime _tradeTime = DateTime.now();
  bool _submitting = false;
  String? _error;

  static final DateFormat _display = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tradeTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tradeTime),
    );
    if (!mounted) return;
    setState(() {
      _tradeTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _tradeTime.hour,
        time?.minute ?? _tradeTime.minute,
      );
    });
  }

  Future<void> _submit() async {
    final balance = double.tryParse(_amountCtrl.text.trim());
    if (balance == null) {
      setState(() => _error = '请输入有效金额');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.service.balanceAdjust(
        bookId: widget.bookId,
        accountId: widget.account.accountId!,
        balance: balance,
        tradeTime: _tradeTime,
        title: _titleCtrl.text,
        remark: _remarkCtrl.text,
      );
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '当前余额 ${widget.account.balance.toStringAsFixed(2)}',
            style: FxTypography.caption,
          ),
          const SizedBox(height: FxSpacing.md),
          _label('调整后金额'),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: _decoration('调整后的实际金额'),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('发生时间'),
          InkWell(
            borderRadius: FxRadius.tileBorder,
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FxSpacing.md,
                vertical: FxSpacing.md,
              ),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: FxRadius.tileBorder,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: palette.textSecondary,
                  ),
                  const SizedBox(width: FxSpacing.sm),
                  Text(_display.format(_tradeTime), style: FxTypography.body),
                ],
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('标题（可选）'),
          TextField(controller: _titleCtrl, decoration: _decoration('余额调整')),
          const SizedBox(height: FxSpacing.md),
          _label('备注（可选）'),
          TextField(controller: _remarkCtrl, decoration: _decoration('备注')),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: '确认调整',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(text, style: FxTypography.label),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: FxPalette.of(context).surfaceMuted,
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
