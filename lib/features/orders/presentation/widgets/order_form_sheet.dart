import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
  late FinanceOrderType _type;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _titleCtrl = TextEditingController(text: o?.title ?? '');
    _remarkCtrl = TextEditingController(text: o?.remark ?? '');
    _type = FinanceOrderType.values.firstWhere(
      (t) => t.value == o?.type,
      orElse: () => FinanceOrderType.advance,
    );
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
      setState(() => _error = '请输入单据标题');
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
          type: _type.value,
          remark: remark,
        );
      } else {
        await widget.service.add(
          bookId: widget.bookId,
          title: title,
          type: _type.value,
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
          _label('单据标题'),
          TextField(
            controller: _titleCtrl,
            decoration: _dec(context, '如：8月差旅垫付'),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('类型'),
          Wrap(
            spacing: FxSpacing.sm,
            children: FinanceOrderType.values.map((t) {
              final selected = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FxSpacing.md,
                    vertical: FxSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? palette.primaryContainer
                        : palette.surfaceMuted,
                    borderRadius: FxRadius.pillBorder,
                    border: Border.all(
                      color: selected ? palette.primary : palette.border,
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: FxTypography.label.copyWith(
                      color: selected ? palette.primary : palette.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: FxSpacing.xs),
            child: Text(
              'TODO(后端确认): 类型 int 值文档未定义，暂用 垫付1/报销2。',
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('备注（可选）'),
          TextField(controller: _remarkCtrl, decoration: _dec(context, '备注')),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit ? '保存修改' : '创建单据',
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
