import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 分组新增/编辑表单：名称 / 默认币种（getCurrencyTemplate 下拉）/ 备注 / 启用。
class GroupFormSheet extends StatefulWidget {
  final BooksService service;
  final FortuneGroupVo? group; // null=新增

  const GroupFormSheet({super.key, required this.service, this.group});

  bool get isEdit => group != null;

  @override
  State<GroupFormSheet> createState() => GroupFormSheetState();
}

class GroupFormSheetState extends State<GroupFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _remarkCtrl;
  String? _currency;
  late bool _enable;

  List<OptionItem> _currencies = const [];
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final g = widget.group;
    _nameCtrl = TextEditingController(text: g?.groupName ?? '');
    _remarkCtrl = TextEditingController(text: g?.remark ?? '');
    _currency = g?.defaultCurrency;
    _enable = g?.enable ?? true;
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      final list = await widget.service.getCurrencyTemplate();
      if (mounted) {
        setState(() {
          _currencies = list;
          _currency ??= list.isNotEmpty ? list.first.value : 'CNY';
        });
      }
    } on Object {
      if (mounted) setState(() => _currency ??= 'CNY');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  String get submitLabel => widget.isEdit
      ? S.of(context).booksSaveChanges
      : S.of(context).booksCreateGroup;

  bool get isSubmitting => _submitting;

  Future<void> submit() {
    if (_submitting) return Future<void>.value();
    return _submit();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = S.of(context).booksGroupNameRequired);
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
      'groupName': name,
      'defaultCurrency': _currency,
      'enable': _enable,
    };
    final remark = _remarkCtrl.text.trim();
    if (remark.isNotEmpty) body['remark'] = remark;
    try {
      if (widget.isEdit) {
        body['groupId'] = widget.group!.groupId;
        await widget.service.modifyGroup(body);
      } else {
        await widget.service.addGroup(body);
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
          _label(S.of(context).booksGroupName),
          TextField(
            controller: _nameCtrl,
            decoration: _dec(S.of(context).booksGroupNameHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).booksDefaultCurrency),
          _currencyPicker(),
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
        ],
      ),
    );
  }

  Widget _currencyPicker() {
    if (_currencies.isEmpty) {
      return TextField(
        controller: TextEditingController(text: _currency ?? 'CNY'),
        decoration: _dec('CNY'),
        onChanged: (v) => _currency = v.trim(),
      );
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: _currencies.map((c) {
        final selected = c.value == _currency;
        return FxChip(
          label: c.label,
          selected: selected,
          onTap: () => setState(() => _currency = c.value),
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
