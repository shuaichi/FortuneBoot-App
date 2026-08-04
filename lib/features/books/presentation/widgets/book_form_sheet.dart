import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 账本新增/编辑表单：名称 / 默认币种 / 账本模板（新增可选）/ 排序 / 备注 / 启用。
class BookFormSheet extends StatefulWidget {
  final BooksService service;
  final int groupId;
  final String? defaultCurrency;
  final FortuneBookVo? book; // null=新增

  const BookFormSheet({
    super.key,
    required this.service,
    required this.groupId,
    this.defaultCurrency,
    this.book,
  });

  bool get isEdit => book != null;

  @override
  State<BookFormSheet> createState() => _BookFormSheetState();
}

class _BookFormSheetState extends State<BookFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _remarkCtrl;
  String? _currency;
  String? _bookTemplate;
  late bool _enable;

  List<OptionItem> _currencies = const [];
  List<OptionItem> _templates = const [];
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _nameCtrl = TextEditingController(text: b?.bookName ?? '');
    _sortCtrl = TextEditingController(
      text: b?.sort == null ? '' : '${b!.sort}',
    );
    _remarkCtrl = TextEditingController(text: b?.remark ?? '');
    _currency = b?.defaultCurrency ?? widget.defaultCurrency;
    _enable = b?.enable ?? true;
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        widget.service.getCurrencyTemplate(),
        if (!widget.isEdit) widget.service.getBookTemplate(),
      ]);
      if (mounted) {
        setState(() {
          _currencies = results[0];
          if (!widget.isEdit && results.length > 1) _templates = results[1];
          _currency ??= _currencies.isNotEmpty
              ? _currencies.first.value
              : 'CNY';
        });
      }
    } on Object {
      if (mounted) setState(() => _currency ??= 'CNY');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请输入账本名称');
      return;
    }
    if (_currency == null || _currency!.isEmpty) {
      setState(() => _error = '请选择默认币种');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'groupId': widget.groupId,
      'bookName': name,
      'defaultCurrency': _currency,
      'enable': _enable,
    };
    final sort = int.tryParse(_sortCtrl.text.trim());
    if (sort != null) body['sort'] = sort;
    final remark = _remarkCtrl.text.trim();
    if (remark.isNotEmpty) body['remark'] = remark;
    if (!widget.isEdit && _bookTemplate != null && _bookTemplate!.isNotEmpty) {
      body['bookTemplate'] = _bookTemplate;
    }
    try {
      if (widget.isEdit) {
        body['bookId'] = widget.book!.bookId;
        await widget.service.modifyBook(body);
      } else {
        await widget.service.addBook(body);
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
          _label('账本名称'),
          TextField(controller: _nameCtrl, decoration: _dec('如：日常开销')),
          const SizedBox(height: FxSpacing.md),
          _label('默认币种'),
          _chips(
            _currencies,
            _currency,
            (v) => setState(() => _currency = v),
            emptyCtrlText: _currency ?? 'CNY',
            onFreeText: (v) => _currency = v,
          ),
          if (!widget.isEdit && _templates.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.md),
            _label('账本模板（可选）'),
            _chips(
              _templates,
              _bookTemplate,
              (v) =>
                  setState(() => _bookTemplate = _bookTemplate == v ? null : v),
            ),
          ],
          const SizedBox(height: FxSpacing.md),
          _label('排序（可选）'),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('数值越小越靠前'),
          ),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              const Expanded(child: Text('启用', style: FxTypography.body)),
              Switch.adaptive(
                value: _enable,
                activeColor: FxPalette.of(context).primary,
                onChanged: (v) => setState(() => _enable = v),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          _label('备注（可选）'),
          TextField(controller: _remarkCtrl, decoration: _dec('备注')),
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
            label: widget.isEdit ? '保存修改' : '创建账本',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _chips(
    List<OptionItem> items,
    String? selected,
    ValueChanged<String> onTap, {
    String? emptyCtrlText,
    ValueChanged<String>? onFreeText,
  }) {
    final palette = FxPalette.of(context);
    if (items.isEmpty && onFreeText != null) {
      return TextField(
        controller: TextEditingController(text: emptyCtrlText),
        decoration: _dec('CNY'),
        onChanged: (v) => onFreeText(v.trim()),
      );
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: items.map((c) {
        final on = c.value == selected;
        return GestureDetector(
          onTap: () => onTap(c.value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.md,
              vertical: FxSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: on ? palette.primaryContainer : palette.surfaceMuted,
              borderRadius: FxRadius.pillBorder,
              border: Border.all(color: on ? palette.primary : palette.border),
            ),
            child: Text(
              c.label,
              style: FxTypography.label.copyWith(
                color: on ? palette.primary : palette.textSecondary,
                fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(text, style: FxTypography.label),
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
