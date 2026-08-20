import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/features/recurring/data/cron_builder.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/features/recurring/data/template_options_service.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/cron_schedule_editor.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 周期记账规则编辑页（Routes.recurringEditor）。
///
/// 规则字段 + 精简账单模板（类型/金额/分类/账户/标签）。提交时把模板构造成
/// FortuneBillAddCommand JSON 对象放进 billRequest 字段。cron 输入时实时校验。
class RecurringEditorPage extends StatefulWidget {
  final int bookId;
  final int groupId;
  final RecurringRuleVo? rule; // null=新增

  const RecurringEditorPage({
    super.key,
    required this.bookId,
    required this.groupId,
    this.rule,
  });

  bool get isEdit => rule != null;

  @override
  State<RecurringEditorPage> createState() => _RecurringEditorPageState();
}

class _RecurringEditorPageState extends State<RecurringEditorPage> {
  final RecurringService _service = RecurringService();
  final TemplateOptionsService _optionsService = TemplateOptionsService();

  // 规则字段
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cronCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _remarkCtrl;
  late bool _enable;
  String? _recoveryStrategy;

  // 账单模板字段
  late FxBillType _billType;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _titleCtrl;
  int? _categoryId;
  int? _accountId;
  final Set<int> _tagIds = {};

  // 选项 / 状态
  List<RecoveryStrategyOption> _strategies = const [];
  TemplateOptions _options = const TemplateOptions();
  bool _loadingOptions = true;
  String? _optionsError;

  // cron 校验（自定义模式）
  Timer? _cronDebounce;
  bool? _cronValid;
  bool _cronChecking = false;

  /// cron 编辑模式：false=可视化下拉选择；true=自定义手写。
  bool _cronAdvanced = false;
  CronSpec _cronSpec = const CronSpec();

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    final tpl = r?.billRequest ?? const {};
    _nameCtrl = TextEditingController(text: r?.ruleName ?? '');
    _cronCtrl = TextEditingController(text: r?.cronExpression ?? '');
    // 尝试把已有 cron 反解析为可视化规格；能解析走可视化，否则走自定义手写。
    final parsed = CronBuilder.tryParse(r?.cronExpression);
    if (parsed != null) {
      _cronSpec = parsed;
      _cronAdvanced = false;
      _cronCtrl.text = CronBuilder.build(parsed);
    } else if ((r?.cronExpression ?? '').trim().isNotEmpty) {
      _cronAdvanced = true;
    } else {
      // 新建：默认可视化，并用默认规格生成初始 cron。
      _cronCtrl.text = CronBuilder.build(_cronSpec);
    }
    _startCtrl = TextEditingController(text: r?.startDate ?? '');
    _endCtrl = TextEditingController(text: r?.endDate ?? '');
    _maxCtrl = TextEditingController(
      text: r?.maxExecutions == null ? '' : '${r!.maxExecutions}',
    );
    _remarkCtrl = TextEditingController(text: r?.remark ?? '');
    _enable = r?.enable ?? true;
    _recoveryStrategy = r?.recoveryStrategy;

    _billType =
        FxBillType.fromValue(FxApi.asId(tpl['billType'])) ?? FxBillType.expense;
    _amountCtrl = TextEditingController(text: _initialAmount(tpl));
    _titleCtrl = TextEditingController(text: tpl['title']?.toString() ?? '');
    _accountId = FxApi.asId(tpl['accountId']);
    _categoryId = _initialCategory(tpl);
    _initialTags(tpl);

    _loadOptions();
  }

  String _initialAmount(Map<String, dynamic> tpl) {
    final pairs = tpl['categoryAmountPair'];
    if (pairs is List && pairs.isNotEmpty && pairs.first is Map) {
      final amount = FxApi.asDouble((pairs.first as Map)['amount']);
      if (amount != null) return amount.toStringAsFixed(2);
    }
    final amount = FxApi.asDouble(tpl['amount']);
    return amount == null ? '' : amount.toStringAsFixed(2);
  }

  int? _initialCategory(Map<String, dynamic> tpl) {
    final pairs = tpl['categoryAmountPair'];
    if (pairs is List && pairs.isNotEmpty && pairs.first is Map) {
      return FxApi.asId((pairs.first as Map)['categoryId']);
    }
    return null;
  }

  void _initialTags(Map<String, dynamic> tpl) {
    final tags = tpl['tagIds'] ?? tpl['tagList'];
    if (tags is List) {
      for (final t in tags) {
        final id = t is Map ? FxApi.asId(t['tagId']) : FxApi.asId(t);
        if (id != null) _tagIds.add(id);
      }
    }
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });
    try {
      final results = await Future.wait([
        _service.getRecoveryStrategy(),
        _optionsService.loadAll(bookId: widget.bookId, groupId: widget.groupId),
      ]);
      if (mounted) {
        setState(() {
          _strategies = results[0] as List<RecoveryStrategyOption>;
          _options = results[1] as TemplateOptions;
          _recoveryStrategy ??= _strategies.isNotEmpty
              ? _strategies.first.value
              : null;
          _loadingOptions = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
          _optionsError = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _cronDebounce?.cancel();
    _nameCtrl.dispose();
    _cronCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _maxCtrl.dispose();
    _remarkCtrl.dispose();
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  // ---- cron 实时校验 ----

  int _cronValidationRevision = 0;

  void _onCronChanged(String value) {
    _cronDebounce?.cancel();
    setState(() {
      _cronValid = null;
      _cronChecking = false;
    });
    final cron = value.trim();
    final validationRevision = ++_cronValidationRevision;
    if (cron.isEmpty) return;
    _cronDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || validationRevision != _cronValidationRevision) return;
      setState(() => _cronChecking = true);
      try {
        final ok = await _service.checkCronExpression(cron);
        if (!mounted || validationRevision != _cronValidationRevision) return;
        setState(() {
          _cronValid = _cronCtrl.text.trim() == cron ? ok : null;
          _cronChecking = false;
        });
      } on Object {
        if (!mounted || validationRevision != _cronValidationRevision) return;
        setState(() {
          _cronValid = false;
          _cronChecking = false;
        });
      }
    });
  }

  List<SimpleOption> get _currentCategories => _billType == FxBillType.income
      ? _options.incomeCategories
      : _options.expenseCategories;

  /// 构造 FortuneBillAddCommand 对象作为 billRequest。
  Map<String, dynamic> _buildBillRequest() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final req = <String, dynamic>{
      'bookId': widget.bookId,
      'billType': _billType.value,
      if (_titleCtrl.text.trim().isNotEmpty) 'title': _titleCtrl.text.trim(),
      if (_accountId != null) 'accountId': _accountId,
      'categoryAmountPair': [
        {if (_categoryId != null) 'categoryId': _categoryId, 'amount': amount},
      ],
      if (_tagIds.isNotEmpty) 'tagIds': _tagIds.toList(),
    };
    return req;
  }

  Future<bool> _validateCronForSubmit() async {
    final cron = _cronCtrl.text.trim();
    if (cron.isEmpty) return false;
    _cronDebounce?.cancel();
    setState(() {
      _cronChecking = true;
      _cronValid = null;
    });
    try {
      final ok = await _service.checkCronExpression(cron);
      if (!mounted) return false;
      setState(() {
        _cronValid = ok;
        _cronChecking = false;
      });
      return ok;
    } on Object {
      if (mounted) {
        setState(() {
          _cronValid = false;
          _cronChecking = false;
        });
      }
      return false;
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).recurringRuleNameRequired);
      return;
    }
    if (_cronCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).recurringCronRequired);
      return;
    }
    if (_cronValid != true) {
      final ok = await _validateCronForSubmit();
      if (!mounted) return;
      if (!ok) {
        setState(() => _error = S.of(context).recurringCronInvalidFix);
        return;
      }
    }
    if (double.tryParse(_amountCtrl.text.trim()) == null) {
      setState(() => _error = S.of(context).recurringAmountRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    final body = <String, dynamic>{
      'bookId': widget.bookId,
      'ruleName': _nameCtrl.text.trim(),
      'cronExpression': _cronCtrl.text.trim(),
      'enable': _enable,
      'billRequest': _buildBillRequest(),
    };
    if (_startCtrl.text.trim().isNotEmpty) {
      body['startDate'] = _startCtrl.text.trim();
    }
    if (_endCtrl.text.trim().isNotEmpty) {
      body['endDate'] = _endCtrl.text.trim();
    }
    final max = int.tryParse(_maxCtrl.text.trim());
    if (max != null) body['maxExecutions'] = max;
    if (_recoveryStrategy != null && _recoveryStrategy!.isNotEmpty) {
      body['recoveryStrategy'] = _recoveryStrategy;
    }
    if (_remarkCtrl.text.trim().isNotEmpty) {
      body['remark'] = _remarkCtrl.text.trim();
    }

    try {
      if (widget.isEdit) {
        body['ruleId'] = widget.rule!.ruleId;
        await _service.modifyRule(body);
      } else {
        await _service.addRule(body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e is FxApiException
              ? e.message
              : S.of(context).profileSaveFailedRetry;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxPalette.of(context).canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            color: palette.textPrimary,
          ),
          Expanded(
            child: Text(
              widget.isEdit
                  ? S.of(context).recurringEditRule
                  : S.of(context).recurringAddRule,
              style: FxTypography.title,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final palette = FxPalette.of(context);
    if (_loadingOptions) return FxStateView.loading();
    if (_optionsError != null) {
      return FxStateView.error(
        message: _optionsError,
        retryLabel: S.of(context).commonRetry,
        onRetry: _loadOptions,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(S.of(context).recurringSectionRule),
          _label(context, S.of(context).recurringRuleName),
          TextField(
            controller: _nameCtrl,
            decoration: _dec(context, S.of(context).recurringRuleNameHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _cronField(context),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label(context, S.of(context).recurringStartDateOptional),
                    TextField(
                      controller: _startCtrl,
                      decoration: _dec(context, 'yyyy-MM-dd'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label(context, S.of(context).recurringEndDateOptional),
                    TextField(
                      controller: _endCtrl,
                      decoration: _dec(context, 'yyyy-MM-dd'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          _label(context, S.of(context).recurringMaxExecutionsOptional),
          TextField(
            controller: _maxCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec(context, S.of(context).recurringMaxExecutionsHint),
          ),
          if (_strategies.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.md),
            _label(context, S.of(context).recurringRecoveryStrategy),
            _strategyPicker(context),
          ],
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).recurringEnabled,
                  style: FxTypography.body,
                ),
              ),
              Switch.adaptive(
                value: _enable,
                activeColor: palette.primary,
                onChanged: (v) => setState(() => _enable = v),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          _sectionTitle(S.of(context).recurringSectionTemplate),
          _label(context, S.of(context).recurringType),
          _typeSelector(context),
          const SizedBox(height: FxSpacing.md),
          _label(context, S.of(context).recurringTitleOptional),
          TextField(
            controller: _titleCtrl,
            decoration: _dec(context, S.of(context).recurringBillTitleHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(context, S.of(context).recurringAmount),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec(context, '0.00'),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(context, S.of(context).recurringCategory),
          _optionChips(
            context,
            _currentCategories,
            _categoryId,
            (id) => setState(() => _categoryId = _categoryId == id ? null : id),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(context, S.of(context).recurringAccount),
          _optionChips(
            context,
            _options.accounts,
            _accountId,
            (id) => setState(() => _accountId = _accountId == id ? null : id),
          ),
          if (_options.tags.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.md),
            _label(context, S.of(context).recurringTagsOptional),
            _tagChips(context),
          ],
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.md),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit
                ? S.of(context).recurringSaveChanges
                : S.of(context).recurringCreateRule,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCronMode() async {
    if (!_cronAdvanced) {
      setState(() => _cronAdvanced = true);
      return;
    }

    final parsed = CronBuilder.tryParse(_cronCtrl.text);
    if (parsed == null) {
      final confirmed = await DestructiveConfirmSheet.show(
        context,
        title: S.of(context).recurringDiscardCustomCronTitle,
        message: S.of(context).recurringDiscardCustomCronMessage,
        subMessage: S.of(context).recurringDiscardCustomCronWarning,
        confirmLabel: S.of(context).recurringUseVisual,
        cancelLabel: S.of(context).commonCancel,
      );
      if (!confirmed || !mounted) return;
    }

    _cronDebounce?.cancel();
    _cronValidationRevision++;
    setState(() {
      _cronAdvanced = false;
      if (parsed != null) _cronSpec = parsed;
      _cronCtrl.text = CronBuilder.build(_cronSpec);
      _cronValid = null;
      _cronChecking = false;
    });
  }

  Widget _cronField(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _label(context, S.of(context).recurringSchedule),
            const Spacer(),
            GestureDetector(
              onTap: _toggleCronMode,
              child: Text(
                _cronAdvanced
                    ? S.of(context).recurringUseVisual
                    : S.of(context).recurringUseAdvanced,
                style: FxTypography.label.copyWith(color: palette.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.sm),
        if (_cronAdvanced) ...[
          TextField(
            controller: _cronCtrl,
            style: FxTypography.body.copyWith(
              fontFamily: FxTypography.monoFamily,
            ),
            decoration: _dec(
              context,
              S.of(context).recurringCronHint,
            ).copyWith(suffixIcon: _cronSuffix(context)),
            onChanged: _onCronChanged,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).recurringAdvancedCronHint,
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
          _cronHint(context),
        ] else
          CronScheduleEditor(
            spec: _cronSpec,
            onChanged: (spec) {
              setState(() {
                _cronSpec = spec;
                _cronCtrl.text = CronBuilder.build(spec);
                _cronValid = null;
              });
            },
          ),
      ],
    );
  }

  Widget? _cronSuffix(BuildContext context) {
    if (_cronChecking) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_cronValid == true) {
      return Icon(
        Icons.check_circle_rounded,
        color: FxPalette.of(context).success,
      );
    }
    if (_cronValid == false) {
      return Icon(Icons.error_rounded, color: FxPalette.of(context).danger);
    }
    return null;
  }

  Widget _cronHint(BuildContext context) {
    if (_cronValid == false) {
      return Padding(
        padding: const EdgeInsets.only(top: FxSpacing.xs),
        child: Text(
          S.of(context).recurringCronInvalid,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).danger,
          ),
        ),
      );
    }
    if (_cronValid == true) {
      return Padding(
        padding: const EdgeInsets.only(top: FxSpacing.xs),
        child: Text(
          S.of(context).recurringCronValid,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).success,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _strategyPicker(BuildContext context) {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: _strategies.map((s) {
        final selected = s.value == _recoveryStrategy;
        return _chip(
          context,
          s.label,
          selected,
          () => setState(() => _recoveryStrategy = s.value),
        );
      }).toList(),
    );
  }

  Widget _typeSelector(BuildContext context) {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: FxBillType.selectable.map((t) {
        final selected = t == _billType;
        return _chip(context, t.localizedLabel(context), selected, () {
          setState(() {
            _billType = t;
            _categoryId = null; // 类型变化清空分类。
          });
        });
      }).toList(),
    );
  }

  Widget _optionChips(
    BuildContext context,
    List<SimpleOption> items,
    int? selectedId,
    ValueChanged<int> onTap,
  ) {
    if (items.isEmpty) {
      return Text(
        S.of(context).recurringNoOptions,
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      );
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: items.map((o) {
        final selected = o.id == selectedId;
        return _chip(context, o.name, selected, () {
          if (o.id != null) onTap(o.id!);
        });
      }).toList(),
    );
  }

  Widget _tagChips(BuildContext context) {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: _options.tags.map((o) {
        final selected = o.id != null && _tagIds.contains(o.id);
        return _chip(context, o.name, selected, () {
          if (o.id == null) return;
          setState(() {
            if (_tagIds.contains(o.id)) {
              _tagIds.remove(o.id);
            } else {
              _tagIds.add(o.id!);
            }
          });
        }, multiSelect: true);
      }).toList(),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap, {
    bool multiSelect = false,
  }) {
    return FxChip(
      label: label,
      selected: selected,
      multiSelect: multiSelect,
      onTap: onTap,
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.sm),
    child: Text(text, style: FxTypography.bodyStrong),
  );

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
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
