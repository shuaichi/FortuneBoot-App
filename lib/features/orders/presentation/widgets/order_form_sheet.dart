import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据新增/编辑表单（标题 / 类型 / 备注）。
class OrderFormSheet extends StatefulWidget {
  final OrdersService service;
  final int bookId;
  final FortuneFinanceOrderVo? order; // null=新增

  const OrderFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    this.order,
  });

  bool get isEdit => order != null;

  @override
  State<OrderFormSheet> createState() => _OrderFormSheetState();
}

class _OrderFormSheetState extends State<OrderFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _remarkCtrl;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _titleCtrl = TextEditingController(text: o?.title ?? '');
    _remarkCtrl = TextEditingController(text: o?.remark ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = S.of(context).ordersTitleRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final remark = _remarkCtrl.text.trim();
      if (widget.isEdit) {
        await widget.service.modify(
          bookId: widget.bookId,
          orderId: widget.order!.orderId!,
          title: title,
          type: FinanceOrderType.reimbursement.value,
          remark: remark,
        );
      } else {
        await widget.service.add(
          bookId: widget.bookId,
          title: title,
          type: FinanceOrderType.reimbursement.value,
          remark: remark,
        );
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
          _label(S.of(context).ordersOrderTitle),
          TextField(
            controller: _titleCtrl,
            decoration: _dec(context, S.of(context).ordersTitleHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).ordersType),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.md,
              vertical: FxSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: palette.primaryContainer,
              borderRadius: FxRadius.pillBorder,
              border: Border.all(color: palette.primary),
            ),
            child: Text(
              S.of(context).ordersTypeReimbursement,
              style: FxTypography.label.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).ordersRemarkOptional),
          TextField(
            controller: _remarkCtrl,
            decoration: _dec(context, S.of(context).ordersRemarkHint),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit
                ? S.of(context).ordersSaveChanges
                : S.of(context).ordersCreateOrder,
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
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  InputDecoration _dec(BuildContext context, String hint) => InputDecoration(
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
