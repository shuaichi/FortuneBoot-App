import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/cron_builder.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/features/recurring/data/template_options_service.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/cron_schedule_editor.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_option_picker.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
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
  int? _toAccountId;
  final Set<int> _tagIds = {};

  // 选项 / 状态
  List<RecoveryStrategyOption> _strategies = const [];
  TemplateOptions _options = const TemplateOptions();
  bool _loadingOptions = true;
  String? _optionsError;

  // cron 在保存前进行服务端校验。
  bool? _cronValid;

  CronSpec _cronSpec = const CronSpec();
  bool _legacyScheduleConverted = false;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    final tpl = r?.billRequest ?? const {};
    _nameCtrl = TextEditingController(text: r?.ruleName ?? '');
    _cronCtrl = TextEditingController(text: r?.cronExpression ?? '');
    // 旧的高级调度统一转换为默认可视规则，并在页面中明确提示。
    final parsed = CronBuilder.tryParse(r?.cronExpression);
    if (parsed != null) {
      _cronSpec = parsed;
      _cronCtrl.text = CronBuilder.build(parsed);
    } else if ((r?.cronExpression ?? '').trim().isNotEmpty) {
      _legacyScheduleConverted = true;
      _cronCtrl.text = CronBuilder.build(_cronSpec);
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
    if (!FxBillType.recurringSelectable.contains(_billType)) {
      // 历史规则可能是垫付/报销，周期已不再支持，回退为支出便于重存。
      _billType = FxBillType.expense;
    }
    _amountCtrl = TextEditingController(text: _initialAmount(tpl));
    _titleCtrl = TextEditingController(text: tpl['title']?.toString() ?? '');
    _accountId = FxApi.asId(tpl['accountId']);
    _toAccountId = FxApi.asId(tpl['toAccountId']);
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
    final tags = tpl['tagIdList'] ?? tpl['tagIds'] ?? tpl['tagList'];
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

  List<SimpleOption> get _currentCategories => _billType == FxBillType.income
      ? _options.incomeCategories
      : _options.expenseCategories;

  bool get _isTransfer => _billType == FxBillType.transfer;

  /// 构造 FortuneBillAddCommand，字段对齐 Web / 普通记账，避免到点执行 NPE。
  Map<String, dynamic> _buildBillRequest() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final title = _titleCtrl.text.trim();
    final fallbackTitle = _nameCtrl.text.trim();
    final req = <String, dynamic>{
      'bookId': widget.bookId,
      'billType': _billType.value,
      // 后端策略会拆箱 confirm；Web 固定传 true。缺省 null 会在执行时 NPE。
      'confirm': true,
      'include': true,
      // 标题不能为空；未填时用规则名兜底（与 Web 必填语义一致）。
      'title': title.isNotEmpty ? title : fallbackTitle,
      'accountId': _accountId,
    };
    if (_isTransfer) {
      // 转账：金额在顶层，分类为空数组；转出 accountId + 转入 toAccountId。
      req['amount'] = amount;
      req['toAccountId'] = _toAccountId;
      req['categoryAmountPair'] = const <Map<String, dynamic>>[];
    } else {
      req['categoryAmountPair'] = [
        {'categoryId': _categoryId, 'amount': amount},
      ];
    }
    if (_tagIds.isNotEmpty) req['tagIdList'] = _tagIds.toList();
    return req;
  }

  Future<bool> _validateCronForSubmit() async {
    final cron = _cronCtrl.text.trim();
    if (cron.isEmpty) return false;
    setState(() {
      _cronValid = null;
    });
    try {
      final ok = await _service.checkCronExpression(cron);
      if (!mounted) return false;
      setState(() {
        _cronValid = ok;
      });
      return ok;
    } on Object {
      if (mounted) {
        setState(() {
          _cronValid = false;
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
    if (_isTransfer) {
      if (_accountId == null) {
        setState(() => _error = S.of(context).billEditorValidateTransferFrom);
        return;
      }
      if (_toAccountId == null) {
        setState(() => _error = S.of(context).billEditorValidateTransferTo);
        return;
      }
      if (_accountId == _toAccountId) {
        setState(() => _error = S.of(context).billEditorValidateTransferSame);
        return;
      }
    } else {
      if (_accountId == null) {
        setState(() => _error = S.of(context).recurringAccountRequired);
        return;
      }
      if (_categoryId == null) {
        setState(() => _error = S.of(context).recurringCategoryRequired);
        return;
      }
    }
    if (_titleCtrl.text.trim().isEmpty && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).recurringBillTitleRequired);
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
      // Web 传数字；后端 Integer，字符串数字也可反序列化，统一成 int 更稳。
      body['recoveryStrategy'] =
          int.tryParse(_recoveryStrategy!) ?? _recoveryStrategy;
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
          if (!_isTransfer) ...[
            const SizedBox(height: FxSpacing.md),
            FxSelectRow(
              label: S.of(context).recurringCategory,
              value: _optionName(_currentCategories, _categoryId),
              placeholder: S.of(context).commonPleaseSelect,
              padding: EdgeInsets.zero,
              onTap: () => _pickCategory(context),
              onClear: _categoryId == null
                  ? null
                  : () => setState(() => _categoryId = null),
            ),
            const SizedBox(height: FxSpacing.xs),
            FxSelectRow(
              label: S.of(context).recurringAccount,
              value: _optionName(_options.accounts, _accountId),
              placeholder: S.of(context).commonPleaseSelect,
              padding: EdgeInsets.zero,
              onTap: () => _pickAccount(context, transferIn: false),
              onClear: _accountId == null
                  ? null
                  : () => setState(() => _accountId = null),
            ),
          ] else ...[
            const SizedBox(height: FxSpacing.md),
            FxSelectRow(
              label: S.of(context).billEditorTransferOutAccount,
              value: _optionName(_options.accounts, _accountId),
              placeholder: S.of(context).commonPleaseSelect,
              padding: EdgeInsets.zero,
              onTap: () => _pickAccount(context, transferIn: false),
              onClear: _accountId == null
                  ? null
                  : () => setState(() => _accountId = null),
            ),
            const SizedBox(height: FxSpacing.xs),
            FxSelectRow(
              label: S.of(context).billEditorTransferInAccount,
              value: _optionName(_options.accounts, _toAccountId),
              placeholder: S.of(context).commonPleaseSelect,
              padding: EdgeInsets.zero,
              onTap: () => _pickAccount(context, transferIn: true),
              onClear: _toAccountId == null
                  ? null
                  : () => setState(() => _toAccountId = null),
            ),
          ],
          if (_options.tags.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.xs),
            FxSelectRow(
              label: S.of(context).recurringTagsOptional,
              value: _tagNamesSummary,
              placeholder: S.of(context).billEditorAddTags,
              padding: EdgeInsets.zero,
              onTap: () => _pickTags(context),
              onClear: _tagIds.isEmpty
                  ? null
                  : () => setState(() => _tagIds.clear()),
            ),
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

  Widget _cronField(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(context, S.of(context).recurringSchedule),
        const SizedBox(height: FxSpacing.sm),
        if (_legacyScheduleConverted) ...[
          Text(
            S.of(context).recurringLegacyVisualNotice,
            style: FxTypography.caption.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.xs),
        ],
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
    return FxSegmented<FxBillType>(
      value: _billType,
      onChanged: (t) {
        setState(() {
          _billType = t;
          _categoryId = null; // 类型变化清空分类。
          if (t != FxBillType.transfer) {
            _toAccountId = null;
          }
        });
      },
      segments: [
        for (final type in FxBillType.recurringSelectable)
          FxSegment(type, type.localizedLabel(context)),
      ],
    );
  }

  String? _optionName(List<SimpleOption> options, int? id) {
    if (id == null) return null;
    for (final option in options) {
      if (option.id == id) return option.name;
    }
    return null;
  }

  String? get _tagNamesSummary {
    if (_tagIds.isEmpty) return null;
    final names = _options.tags
        .where((option) => option.id != null && _tagIds.contains(option.id))
        .map((option) => option.name)
        .toList();
    return names.isEmpty ? null : names.join('、');
  }

  Future<void> _pickCategory(BuildContext context) async {
    final picked = await showFxOptionPicker<SimpleOption>(
      context,
      title: S.of(context).billEditorSelectCategory,
      options: _currentCategories,
      labelOf: (option) => option.name,
      idOf: (option) => option.id,
      selectedId: _categoryId,
      emptyText: S.of(context).recurringNoOptions,
    );
    if (!mounted || picked?.id == null) return;
    setState(() => _categoryId = picked!.id);
  }

  Future<void> _pickAccount(
    BuildContext context, {
    required bool transferIn,
  }) async {
    final picked = await showFxOptionPicker<SimpleOption>(
      context,
      title: S.of(context).billEditorSelectAccountHint,
      options: _options.accounts,
      labelOf: (option) => option.name,
      idOf: (option) => option.id,
      selectedId: transferIn ? _toAccountId : _accountId,
      emptyText: S.of(context).recurringNoOptions,
    );
    if (!mounted || picked?.id == null) return;
    final id = picked!.id!;
    setState(() {
      if (transferIn) {
        _toAccountId = id;
        if (_accountId == id) _accountId = null;
      } else {
        _accountId = id;
        if (_toAccountId == id) _toAccountId = null;
      }
    });
  }

  Future<void> _pickTags(BuildContext context) async {
    final picked = await showFxMultiOptionPicker<SimpleOption>(
      context,
      title: S.of(context).billEditorSelectTags,
      options: _options.tags.where((option) => option.id != null).toList(),
      labelOf: (option) => option.name,
      idOf: (option) => option.id,
      selectedIds: _tagIds,
      emptyText: S.of(context).recurringNoOptions,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _tagIds
        ..clear()
        ..addAll(picked.map((option) => option.id!).whereType<int>());
    });
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return FxChip(label: label, selected: selected, onTap: onTap);
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
