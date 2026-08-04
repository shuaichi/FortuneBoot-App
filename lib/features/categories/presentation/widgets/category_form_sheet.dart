import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/features/categories/data/category_service.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 分类新增/编辑表单。字段：名称 / 类型（支出/收入）/ 父级 / 排序 / 备注 / 启用。
class CategoryFormSheet extends StatefulWidget {
  final CategoryService service;
  final int bookId;
  final FortuneCategoryVo? category; // null=新增
  final int? presetType; // 新增时预选类型
  final int? presetParentId; // 新增子分类时预选父级
  final List<FortuneCategoryVo> tree; // 用于父级选择（同类型根节点）

  const CategoryFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    required this.tree,
    this.category,
    this.presetType,
    this.presetParentId,
  });

  bool get isEdit => category != null;

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _remarkCtrl;

  late int _categoryType;
  int? _parentId;
  late bool _enable;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameCtrl = TextEditingController(text: c?.categoryName ?? '');
    _sortCtrl = TextEditingController(text: c?.sort?.toString() ?? '');
    _remarkCtrl = TextEditingController(text: c?.remark ?? '');
    _categoryType = c?.categoryType ?? widget.presetType ?? 1;
    _parentId = c?.parentId ?? widget.presetParentId;
    _enable = c?.enable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  /// 同类型的根节点作为可选父级（排除自身）。
  List<FortuneCategoryVo> get _parentOptions => widget.tree
      .where(
        (c) =>
            (c.categoryType ?? 1) == _categoryType &&
            c.categoryId != widget.category?.categoryId,
      )
      .toList();

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入分类名称');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'bookId': widget.bookId,
      'categoryName': _nameCtrl.text.trim(),
      'categoryType': _categoryType,
      'enable': _enable,
    };
    if (widget.isEdit) body['categoryId'] = widget.category!.categoryId;
    if (_parentId != null) body['parentId'] = _parentId;
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
          const ManageFieldLabel('分类名称'),
          TextField(
            controller: _nameCtrl,
            decoration: manageInputDecoration('如：餐饮'),
          ),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('分类类型'),
          _typeSelector(),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('父级分类（可选）'),
          _parentSelector(),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('排序（可选）'),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: manageInputDecoration('数字越小越靠前'),
          ),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('备注（可选）'),
          TextField(
            controller: _remarkCtrl,
            decoration: manageInputDecoration('备注'),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageSwitchRow(
            label: '启用',
            value: _enable,
            onChanged: (v) => setState(() => _enable = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: FxColors.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit ? '保存修改' : '创建分类',
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
      children: [
        _chip('支出', 1, FxColors.expense),
        _chip('收入', 2, FxColors.income),
      ],
    );
  }

  Widget _chip(String label, int type, Color tint) {
    final selected = _categoryType == type;
    return GestureDetector(
      onTap: widget.isEdit
          ? null
          : () => setState(() {
              _categoryType = type;
              _parentId = null; // 类型变了父级失效
            }),
      child: Opacity(
        opacity: widget.isEdit && !selected ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? tint.withValues(alpha: 0.12) : FxColors.surfaceMuted,
            borderRadius: FxRadius.pillBorder,
            border: Border.all(color: selected ? tint : FxColors.border),
          ),
          child: Text(
            label,
            style: FxTypography.label.copyWith(
              color: selected ? tint : FxColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _parentSelector() {
    final options = _parentOptions;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.md),
      decoration: BoxDecoration(
        color: FxColors.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: options.any((o) => o.categoryId == _parentId)
              ? _parentId
              : null,
          hint: const Text('无（顶级分类）'),
          items: [
            const DropdownMenuItem<int?>(child: Text('无（顶级分类）')),
            ...options.map(
              (o) => DropdownMenuItem<int?>(
                value: o.categoryId,
                child: Text(o.categoryName ?? '未命名'),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _parentId = v),
        ),
      ),
    );
  }
}
