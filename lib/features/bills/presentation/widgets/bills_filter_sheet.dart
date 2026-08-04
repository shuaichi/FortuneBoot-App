import 'package:flutter/material.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 账单筛选表单（本轮：类型多选 / 金额区间 / 确认 / 统计）。
/// 分类/标签/账户/交易对象候选依赖未落地的管理模块 service，本轮留 TODO。
class BillsFilterSheet extends StatefulWidget {
  final BillsFilter initial;
  final ValueChanged<BillsFilter> onApply;

  const BillsFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<BillsFilterSheet> createState() => _BillsFilterSheetState();
}

class _BillsFilterSheetState extends State<BillsFilterSheet> {
  late Set<int> _billTypes;
  late bool? _confirm;
  late bool? _include;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _billTypes = {...widget.initial.billTypes};
    _confirm = widget.initial.confirm;
    _include = widget.initial.include;
    _minCtrl = TextEditingController(
      text: widget.initial.amountMin?.toString() ?? '',
    );
    _maxCtrl = TextEditingController(
      text: widget.initial.amountMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _billTypes = {};
      _confirm = null;
      _include = null;
      _minCtrl.clear();
      _maxCtrl.clear();
    });
  }

  void _apply() {
    // 显式重建以支持"清空"（copyWith 无法把值置空）；保留本轮不支持编辑的候选筛选。
    final resolved = BillsFilter(
      billTypes: _billTypes,
      confirm: _confirm,
      include: _include,
      amountMin: double.tryParse(_minCtrl.text.trim()),
      amountMax: double.tryParse(_maxCtrl.text.trim()),
      categoryIds: widget.initial.categoryIds,
      tagIds: widget.initial.tagIds,
      accountId: widget.initial.accountId,
      payeeId: widget.initial.payeeId,
    );
    widget.onApply(resolved);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('账单类型'),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: FxBillType.selectable.map((t) {
              final selected = _billTypes.contains(t.value);
              return FxTagChip(
                label: t.label,
                selected: selected,
                onTap: () => setState(() {
                  if (selected) {
                    _billTypes.remove(t.value);
                  } else {
                    _billTypes.add(t.value);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: FxSpacing.lg),
          _label('金额区间'),
          Row(
            children: [
              Expanded(child: _amountField(context, _minCtrl, '最小')),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: FxSpacing.sm),
                child: Text('—', style: FxTypography.label),
              ),
              Expanded(child: _amountField(context, _maxCtrl, '最大')),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          _label('确认状态'),
          _tristate(
            current: _confirm,
            trueLabel: '已确认',
            falseLabel: '未确认',
            onChanged: (v) => setState(() => _confirm = v),
          ),
          const SizedBox(height: FxSpacing.lg),
          _label('是否统计'),
          _tristate(
            current: _include,
            trueLabel: '计入统计',
            falseLabel: '不计入',
            onChanged: (v) => setState(() => _include = v),
          ),
          const SizedBox(height: FxSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FxButton.text(label: '重置', onPressed: _reset),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                flex: 2,
                child: FxButton(label: '应用', expand: true, onPressed: _apply),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.sm),
    child: Text(text, style: FxTypography.label),
  );

  Widget _amountField(
    BuildContext context,
    TextEditingController ctrl,
    String hint,
  ) {
    final palette = FxPalette.of(context);
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: FxTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: FxTypography.caption,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        filled: true,
        fillColor: palette.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 三态选择：不限 / true / false。
  Widget _tristate({
    required bool? current,
    required String trueLabel,
    required String falseLabel,
    required ValueChanged<bool?> onChanged,
  }) {
    return Wrap(
      spacing: FxSpacing.sm,
      children: [
        FxTagChip(
          label: '不限',
          selected: current == null,
          onTap: () => onChanged(null),
        ),
        FxTagChip(
          label: trueLabel,
          selected: current == true,
          onTap: () => onChanged(true),
        ),
        FxTagChip(
          label: falseLabel,
          selected: current == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}
