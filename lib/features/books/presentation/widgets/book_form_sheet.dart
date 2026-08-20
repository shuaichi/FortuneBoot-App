import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
      setState(() => _error = S.of(context).booksBookNameRequired);
      return;
    }
    if (_currency == null || _currency!.isEmpty) {
      setState(() => _error = S.of(context).booksCurrencyRequired);
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
          _label(S.of(context).booksBookName),
          TextField(
            controller: _nameCtrl,
            decoration: _dec(S.of(context).booksBookNameHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).booksDefaultCurrency),
          _chips(
            _currencies,
            _currency,
            (v) => setState(() => _currency = v),
            emptyCtrlText: _currency ?? 'CNY',
            onFreeText: (v) => _currency = v,
          ),
          if (!widget.isEdit && _templates.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).booksBookTemplateOptional),
            _chips(
              _templates,
              _bookTemplate,
              (v) =>
                  setState(() => _bookTemplate = _bookTemplate == v ? null : v),
            ),
          ],
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).booksSortOptional),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec(S.of(context).booksSortHint),
          ),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).booksEnabled,
                  style: FxTypography.body,
                ),
              ),
              Switch.adaptive(
                value: _enable,
                activeColor: FxPalette.of(context).primary,
                onChanged: (v) => setState(() => _enable = v),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          _label(S.of(context).booksRemarkOptional),
          TextField(
            controller: _remarkCtrl,
            decoration: _dec(S.of(context).booksRemarkHint),
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
                ? S.of(context).booksSaveChanges
                : S.of(context).booksCreateBook,
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
        return FxChip(
          label: c.label,
          selected: on,
          onTap: () => onTap(c.value),
        );
      }).toList(),
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
