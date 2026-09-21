import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/bills/data/bills_filter_options_service.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 账单筛选表单。
class BillsFilterSheet extends StatefulWidget {
  const BillsFilterSheet({
    super.key,
    required this.initial,
    required this.bookId,
    required this.groupId,
    required this.onApply,
    this.optionsService,
  });

  final BillsFilter initial;
  final int? bookId;
  final int? groupId;
  final ValueChanged<BillsFilter> onApply;
  final BillsFilterOptionsService? optionsService;

  @override
  State<BillsFilterSheet> createState() => _BillsFilterSheetState();
}

class _BillsFilterSheetState extends State<BillsFilterSheet> {
  late final BillsFilterOptionsService _optionsService;
  late Set<int> _billTypes;
  late Set<int> _categoryIds;
  late Set<int> _tagIds;
  late bool? _confirm;
  late bool? _include;
  late int? _accountId;
  late int? _payeeId;
  late BillDateRange? _dateRange;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  Future<BillsFilterOptions>? _optionsFuture;
  String? _minError;
  String? _maxError;

  @override
  void initState() {
    super.initState();
    _optionsService = widget.optionsService ?? BillsFilterOptionsService();
    _billTypes = {...widget.initial.billTypes};
    _categoryIds = {...?widget.initial.categoryIds};
    _tagIds = {...?widget.initial.tagIds};
    _confirm = widget.initial.confirm;
    _include = widget.initial.include;
    _accountId = widget.initial.accountId;
    _payeeId = widget.initial.payeeId;
    _dateRange = widget.initial.dateRange;
    _titleCtrl = TextEditingController(text: widget.initial.title ?? '');
    _minCtrl = TextEditingController(
      text: widget.initial.amountMin?.toString() ?? '',
    );
    _maxCtrl = TextEditingController(
      text: widget.initial.amountMax?.toString() ?? '',
    );
    _loadOptions();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _loadOptions() {
    final bookId = widget.bookId;
    final groupId = widget.groupId;
    if (bookId == null || groupId == null) return;
    _optionsFuture = _optionsService.load(bookId: bookId, groupId: groupId);
  }

  void _reset() {
    setState(() {
      _billTypes = {};
      _categoryIds = {};
      _tagIds = {};
      _confirm = null;
      _include = null;
      _accountId = null;
      _payeeId = null;
      _dateRange = null;
      _minError = null;
      _maxError = null;
      _titleCtrl.clear();
      _minCtrl.clear();
      _maxCtrl.clear();
    });
  }

  double? _amountOf(TextEditingController controller, bool isMin) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || !value.isFinite) {
      if (isMin) {
        _minError = S.of(context).billsFilterAmountRange;
      } else {
        _maxError = S.of(context).billsFilterAmountRange;
      }
      return null;
    }
    return value;
  }

  void _apply() {
    setState(() {
      _minError = null;
      _maxError = null;
    });
    final min = _amountOf(_minCtrl, true);
    final max = _amountOf(_maxCtrl, false);
    if (_minError != null || _maxError != null) {
      setState(() {});
      return;
    }
    if (min != null && max != null && min > max) {
      setState(() {
        _minError = S.of(context).billsFilterAmountRange;
        _maxError = S.of(context).billsFilterAmountRange;
      });
      return;
    }
    widget.onApply(
      BillsFilter(
        billTypes: _billTypes,
        amountMin: min,
        amountMax: max,
        confirm: _confirm,
        include: _include,
        categoryIds: _categoryIds.isEmpty ? null : _categoryIds.toList(),
        tagIds: _tagIds.isEmpty ? null : _tagIds.toList(),
        accountId: _accountId,
        payeeId: _payeeId,
        dateRange: _dateRange,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final initial = _dateRange;
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initial == null
          ? null
          : DateTimeRange(start: initial.start, end: initial.end),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _dateRange = BillDateRange(start: selected.start, end: selected.end);
    });
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
          _label(S.of(context).billsFilterByTitle),
          _titleField(),
          const SizedBox(height: FxSpacing.lg),
          _label(S.of(context).billsFilterBillType),
          _typeChoices(),
          const SizedBox(height: FxSpacing.lg),
          _label(S.of(context).billsFilterAmountRange),
          _amountRange(),
          const SizedBox(height: FxSpacing.lg),
          _label(S.of(context).billsBillingCycle('')),
          _dateRangeControl(),
          const SizedBox(height: FxSpacing.lg),
          _label(S.of(context).billsFilterConfirmStatus),
          _tristate(
            current: _confirm,
            trueLabel: S.of(context).billsFilterConfirmed,
            falseLabel: S.of(context).billsFilterUnconfirmed,
            onChanged: (value) => setState(() => _confirm = value),
          ),
          const SizedBox(height: FxSpacing.lg),
          _label(S.of(context).billsFilterIncludeStatus),
          _tristate(
            current: _include,
            trueLabel: S.of(context).billsFilterIncluded,
            falseLabel: S.of(context).billsFilterExcluded,
            onChanged: (value) => setState(() => _include = value),
          ),
          const SizedBox(height: FxSpacing.lg),
          _optionsControls(),
          const SizedBox(height: FxSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FxButton.text(
                  label: S.of(context).billsReset,
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                flex: 2,
                child: FxButton(
                  label: S.of(context).billsApply,
                  expand: true,
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeChoices() {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: FxBillType.selectable.map((type) {
        final selected = _billTypes.contains(type.value);
        return Semantics(
          button: true,
          selected: selected,
          label: type.localizedLabel(context),
          child: FxTagChip(
            label: type.localizedLabel(context),
            selected: selected,
            onTap: () => setState(() {
              if (selected) {
                _billTypes.remove(type.value);
              } else {
                _billTypes.add(type.value);
              }
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _amountRange() {
    return Row(
      children: [
        Expanded(
          child: _amountField(
            _minCtrl,
            S.of(context).billsFilterMin,
            _minError,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FxSpacing.sm),
          child: Text('—', style: FxTypography.label),
        ),
        Expanded(
          child: _amountField(
            _maxCtrl,
            S.of(context).billsFilterMax,
            _maxError,
          ),
        ),
      ],
    );
  }

  Widget _dateRangeControl() {
    final range = _dateRange;
    final locale = Localizations.localeOf(context).toString();
    final value = range == null
        ? S.of(context).billsFilterAny
        : '${DateFormat.yMMMd(locale).format(range.start)} – '
              '${DateFormat.yMMMd(locale).format(range.end)}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _selectDateRange,
            child: Text(value),
          ),
        ),
        if (range != null)
          IconButton(
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            onPressed: () => setState(() => _dateRange = null),
            icon: const Icon(Icons.clear_rounded),
          ),
      ],
    );
  }

  Widget _optionsControls() {
    if (_optionsFuture == null) return const SizedBox.shrink();
    return FutureBuilder<BillsFilterOptions>(
      future: _optionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Row(
            children: [
              Expanded(child: Text(S.of(context).dashboardLoadFailed)),
              TextButton(
                onPressed: () => setState(_loadOptions),
                child: Text(S.of(context).commonRetry),
              ),
            ],
          );
        }
        final options = snapshot.data;
        if (options == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(S.of(context).billsCategoryDetail),
            _multiOptions(options.categories, _categoryIds),
            const SizedBox(height: FxSpacing.lg),
            _label(S.of(context).billsTags),
            _multiOptions(options.tags, _tagIds),
            const SizedBox(height: FxSpacing.lg),
            _label(S.of(context).billsTransferOutAccount),
            _singleOption(options.accounts, _accountId, (value) {
              setState(() => _accountId = value);
            }),
            const SizedBox(height: FxSpacing.lg),
            _label(S.of(context).billsPayee),
            _singleOption(options.payees, _payeeId, (value) {
              setState(() => _payeeId = value);
            }),
          ],
        );
      },
    );
  }

  Widget _multiOptions(List<BillsFilterOption> options, Set<int> selectedIds) {
    if (options.isEmpty) {
      return Text(
        S.of(context).billsFilterAny,
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      );
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: options.map((option) {
        final selected = selectedIds.contains(option.id);
        return Semantics(
          button: true,
          selected: selected,
          label: option.label,
          child: FxTagChip(
            label: option.label,
            selected: selected,
            onTap: () => setState(() {
              if (selected) {
                selectedIds.remove(option.id);
              } else {
                selectedIds.add(option.id);
              }
            }),
          ),
        );
      }).toList(),
    );
  }

  Widget _singleOption(
    List<BillsFilterOption> options,
    int? selected,
    ValueChanged<int?> onChanged,
  ) {
    return DropdownButtonFormField<int?>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: FxPalette.of(context).surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(S.of(context).billsFilterAny),
        ),
        ...options.map(
          (option) => DropdownMenuItem<int?>(
            value: option.id,
            child: Text(option.label, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.sm),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  Widget _titleField() {
    return TextField(
      controller: _titleCtrl,
      style: FxTypography.body,
      decoration: InputDecoration(
        hintText: S.of(context).billsFilterTitleHint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        filled: true,
        fillColor: FxPalette.of(context).surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _amountField(
    TextEditingController controller,
    String hint,
    String? errorText,
  ) {
    final palette = FxPalette.of(context);
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: FxTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: FxTypography.caption.copyWith(color: palette.textTertiary),
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

  Widget _tristate({
    required bool? current,
    required String trueLabel,
    required String falseLabel,
    required ValueChanged<bool?> onChanged,
  }) {
    return Wrap(
      spacing: FxSpacing.sm,
      children: [
        _triChip(
          label: S.of(context).billsFilterAny,
          selected: current == null,
          onTap: () => onChanged(null),
        ),
        _triChip(
          label: trueLabel,
          selected: current == true,
          onTap: () => onChanged(true),
        ),
        _triChip(
          label: falseLabel,
          selected: current == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }

  Widget _triChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: FxTagChip(label: label, selected: selected, onTap: onTap),
    );
  }
}
