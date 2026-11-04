import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/bills/data/bills_filter_options_service.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';
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
  State<BillsFilterSheet> createState() => BillsFilterSheetState();
}

class BillsFilterSheetState extends State<BillsFilterSheet> {
  late final BillsFilterOptionsService _optionsService;
  late Set<int> _billTypes;
  late Set<int> _categoryIds;
  late Set<int> _tagIds;
  late Set<int> _memberIds;
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
    _memberIds = {...?widget.initial.memberIds};
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
      _memberIds = {};
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
        memberIds: _memberIds.isEmpty ? null : _memberIds.toList(),
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
    return Padding(
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
        ],
      ),
    );
  }

  /// 由固定操作区触发，避免重置按钮随长表单滚出屏幕。
  void reset() => _reset();

  /// 由固定操作区触发；校验失败时保持弹层并显示字段错误。
  void apply() => _apply();

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
            _compactTreeField(
              roots: options.categoryTrees,
              selectedIds: _categoryIds,
              title: S.of(context).billEditorSelectCategory,
              leafOnly: true,
            ),
            const SizedBox(height: FxSpacing.sm),
            _label(S.of(context).billsTags),
            _compactTreeField(
              roots: options.tagTrees,
              selectedIds: _tagIds,
              title: S.of(context).billEditorSelectTags,
              leafOnly: false,
            ),
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).billsTransferOutAccount),
            _singleOption(options.accounts, _accountId, (value) {
              setState(() => _accountId = value);
            }),
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).billsPayee),
            _singleOption(options.payees, _payeeId, (value) {
              setState(() => _payeeId = value);
            }),
            const SizedBox(height: FxSpacing.md),
            _label(S.of(context).billsMembers),
            _compactTreeField(
              roots: [
                for (final m in options.members)
                  BillsFilterTreeNode(id: m.id, label: m.label),
              ],
              selectedIds: _memberIds,
              title: S.of(context).billEditorSelectMembers,
              leafOnly: false,
            ),
          ],
        );
      },
    );
  }

  Widget _compactTreeField({
    required List<BillsFilterTreeNode> roots,
    required Set<int> selectedIds,
    required String title,
    required bool leafOnly,
  }) {
    final palette = FxPalette.of(context);
    if (roots.isEmpty) {
      return Text(
        S.of(context).billsFilterAny,
        style: FxTypography.caption.copyWith(color: palette.textTertiary),
      );
    }
    final flat = BillsFilterOptions.flatten(roots);
    final selected = flat.where((o) => selectedIds.contains(o.id)).toList();
    final summary = selected.isEmpty
        ? S.of(context).billsFilterAny
        : selected.map((o) => o.label).join('、');

    return Material(
      color: palette.surfaceMuted,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: () => _openTreePicker(
          roots: roots,
          selectedIds: selectedIds,
          title: title,
          leafOnly: leafOnly,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FxTypography.body.copyWith(
                    color: selected.isEmpty
                        ? palette.textTertiary
                        : palette.textPrimary,
                  ),
                ),
              ),
              if (selected.isNotEmpty) ...[
                Text(
                  '${selected.length}',
                  style: FxTypography.caption.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
              ],
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTreePicker({
    required List<BillsFilterTreeNode> roots,
    required Set<int> selectedIds,
    required String title,
    required bool leafOnly,
  }) async {
    final result = await FxTreePicker.show<BillsFilterTreeNode>(
      context,
      roots: roots,
      childrenOf: (n) => n.children,
      labelOf: (n) => n.label,
      idOf: (n) => n.id,
      initialSelected: selectedIds.map((id) => id as Object).toSet(),
      multiSelect: true,
      leafOnly: leafOnly,
      initiallyCollapsed: true,
      title: title,
    );
    if (result == null || !mounted) return;
    setState(() {
      selectedIds
        ..clear()
        ..addAll(result.map((n) => n.id).whereType<int>());
    });
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
