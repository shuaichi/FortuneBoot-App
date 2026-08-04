import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/features/tags/data/tag_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 标签新增/编辑表单。字段：名称 / 父级 / 排序 / 备注 / 启用
/// + 开关集合 canExpense/canIncome/canTransfer。
///
/// 编辑模式下开关通过 [onToggle] 即时 PATCH（乐观更新在 bloc 侧）；
/// 新增模式下开关随 add body 一起提交。
class TagFormSheet extends StatefulWidget {
  final TagService service;
  final int bookId;
  final FortuneTagVo? tag;
  final int? presetParentId;
  final List<FortuneTagVo> flatTags; // 展平的可选父级
  final void Function(TagToggleField field, bool value)? onToggle;

  const TagFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    required this.flatTags,
    this.tag,
    this.presetParentId,
    this.onToggle,
  });

  bool get isEdit => tag != null;

  @override
  State<TagFormSheet> createState() => _TagFormSheetState();
}

class _TagFormSheetState extends State<TagFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _remarkCtrl;

  int? _parentId;
  late bool _canExpense;
  late bool _canIncome;
  late bool _canTransfer;
  late bool _enable;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final t = widget.tag;
    _nameCtrl = TextEditingController(text: t?.tagName ?? '');
    _sortCtrl = TextEditingController(text: t?.sort?.toString() ?? '');
    _remarkCtrl = TextEditingController(text: t?.remark ?? '');
    _parentId = t?.parentId ?? widget.presetParentId;
    _canExpense = t?.canExpense ?? true;
    _canIncome = t?.canIncome ?? true;
    _canTransfer = t?.canTransfer ?? true;
    _enable = t?.enable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  /// 可选父级：排除自身及其所有后代，避免把父级设成自己的子孙形成环。
  List<FortuneTagVo> get _parentOptions {
    final selfId = widget.tag?.tagId;
    if (selfId == null) return widget.flatTags;
    final excluded = <int>{selfId};
    // 依据 parentId 关系在展平列表上迭代收集后代，直到无新增。
    bool added = true;
    while (added) {
      added = false;
      for (final t in widget.flatTags) {
        final id = t.tagId;
        if (id != null &&
            !excluded.contains(id) &&
            t.parentId != null &&
            excluded.contains(t.parentId)) {
          excluded.add(id);
          added = true;
        }
      }
    }
    return widget.flatTags
        .where((t) => t.tagId != null && !excluded.contains(t.tagId))
        .toList();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).tagsNameRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'bookId': widget.bookId,
      'tagName': _nameCtrl.text.trim(),
      'canExpense': _canExpense,
      'canIncome': _canIncome,
      'canTransfer': _canTransfer,
      'enable': _enable,
    };
    if (widget.isEdit) body['tagId'] = widget.tag!.tagId;
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
          ManageFieldLabel(S.of(context).tagsNameLabel),
          TextField(
            controller: _nameCtrl,
            decoration: manageInputDecoration(
              context,
              S.of(context).tagsNameHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).tagsParentLabel),
          _parentSelector(),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).tagsSortLabel),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: manageInputDecoration(
              context,
              S.of(context).tagsSortHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).tagsRemarkLabel),
          TextField(
            controller: _remarkCtrl,
            decoration: manageInputDecoration(
              context,
              S.of(context).tagsRemarkHint,
            ),
          ),
          const SizedBox(height: FxSpacing.lg),
          _switchRow(TagToggleField.canExpense, _canExpense, (v) {
            setState(() => _canExpense = v);
          }),
          _switchRow(TagToggleField.canIncome, _canIncome, (v) {
            setState(() => _canIncome = v);
          }),
          _switchRow(TagToggleField.canTransfer, _canTransfer, (v) {
            setState(() => _canTransfer = v);
          }),
          _switchRow(TagToggleField.enable, _enable, (v) {
            setState(() => _enable = v);
          }),
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
                ? S.of(context).tagsSaveEdit
                : S.of(context).tagsCreate,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    TagToggleField field,
    bool value,
    ValueChanged<bool> onLocal,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(field.label, style: FxTypography.body)),
          Switch.adaptive(
            value: value,
            activeColor: FxPalette.of(context).primary,
            onChanged: (v) {
              onLocal(v);
              if (widget.isEdit) widget.onToggle?.call(field, v);
            },
          ),
        ],
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
          value: options.any((o) => o.tagId == _parentId) ? _parentId : null,
          hint: Text(S.of(context).tagsParentNone),
          items: [
            DropdownMenuItem<int?>(
              child: Text(S.of(context).tagsParentNone),
            ),
            ...options.map(
              (o) => DropdownMenuItem<int?>(
                value: o.tagId,
                child: Text(o.tagName ?? S.of(context).tagsUnnamed),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _parentId = v),
        ),
      ),
    );
  }
}
