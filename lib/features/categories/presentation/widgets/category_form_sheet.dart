import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/features/categories/data/category_service.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
      setState(() => _error = S.of(context).categoriesNameRequired);
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
          ManageFieldLabel(S.of(context).categoriesNameLabel),
          TextField(
            controller: _nameCtrl,
            decoration: manageInputDecoration(
              context,
              S.of(context).categoriesNameHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).categoriesTypeLabel),
          _typeSelector(),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).categoriesParentLabel),
          _parentSelector(),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).categoriesSortLabel),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: manageInputDecoration(
              context,
              S.of(context).categoriesSortHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).categoriesRemarkLabel),
          TextField(
            controller: _remarkCtrl,
            decoration: manageInputDecoration(
              context,
              S.of(context).categoriesRemarkHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageSwitchRow(
            label: S.of(context).categoriesEnable,
            value: _enable,
            onChanged: (v) => setState(() => _enable = v),
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
                ? S.of(context).categoriesSaveEdit
                : S.of(context).categoriesCreate,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _typeSelector() {
    final finance = FxFinanceColors.of(context);
    return Wrap(
      spacing: FxSpacing.sm,
      children: [
        _chip(S.of(context).categoriesTypeExpense, 1, finance.expense),
        _chip(S.of(context).categoriesTypeIncome, 2, finance.income),
      ],
    );
  }

  Widget _chip(String label, int type, Color tint) {
    final palette = FxPalette.of(context);
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
            color: selected
                ? tint.withValues(alpha: 0.12)
                : palette.surfaceMuted,
            borderRadius: FxRadius.pillBorder,
            border: Border.all(color: selected ? tint : palette.border),
          ),
          child: Text(
            label,
            style: FxTypography.label.copyWith(
              color: selected ? tint : palette.textSecondary,
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
        color: FxPalette.of(context).surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: options.any((o) => o.categoryId == _parentId)
              ? _parentId
              : null,
          hint: Text(S.of(context).categoriesParentNone),
          items: [
            DropdownMenuItem<int?>(
              child: Text(S.of(context).categoriesParentNone),
            ),
            ...options.map(
              (o) => DropdownMenuItem<int?>(
                value: o.categoryId,
                child: Text(o.categoryName ?? S.of(context).categoriesUnnamed),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _parentId = v),
        ),
      ),
    );
  }
}
