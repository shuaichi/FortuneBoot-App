import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/features/recurring/data/template_options_service.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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

  // cron 校验
  Timer? _cronDebounce;
  bool? _cronValid;
  bool _cronChecking = false;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    final tpl = r?.billRequest ?? const {};
    _nameCtrl = TextEditingController(text: r?.ruleName ?? '');
    _cronCtrl = TextEditingController(text: r?.cronExpression ?? '');
    _startCtrl = TextEditingController(text: r?.startDate ?? '');
    _endCtrl = TextEditingController(text: r?.endDate ?? '');
    _maxCtrl =
        TextEditingController(text: r?.maxExecutions == null ? '' : '${r!.maxExecutions}');
    _remarkCtrl = TextEditingController(text: r?.remark ?? '');
    _enable = r?.enable ?? true;
    _recoveryStrategy = r?.recoveryStrategy;

    _billType = FxBillType.fromValue(FxApi.asId(tpl['billType'])) ??
        FxBillType.expense;
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
          _recoveryStrategy ??=
              _strategies.isNotEmpty ? _strategies.first.value : null;
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

  void _onCronChanged(String value) {
    _cronDebounce?.cancel();
    setState(() {
      _cronValid = null;
      _cronChecking = false;
    });
    final cron = value.trim();
    if (cron.isEmpty) return;
    _cronDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _cronChecking = true);
      try {
        final ok = await _service.checkCronExpression(cron);
        if (mounted && _cronCtrl.text.trim() == cron) {
          setState(() {
            _cronValid = ok;
            _cronChecking = false;
          });
        }
      } on Object {
        if (mounted) {
          setState(() {
            _cronValid = false;
            _cronChecking = false;
          });
        }
      }
    });
  }

  List<SimpleOption> get _currentCategories =>
      _billType == FxBillType.income
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
        {
          if (_categoryId != null) 'categoryId': _categoryId,
          'amount': amount,
        },
      ],
      if (_tagIds.isNotEmpty) 'tagIds': _tagIds.toList(),
    };
    return req;
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入规则名称');
      return;
    }
    if (_cronCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入 cron 表达式');
      return;
    }
    if (_cronValid == false) {
      setState(() => _error = 'cron 表达式无效，请修正');
      return;
    }
    if (double.tryParse(_amountCtrl.text.trim()) == null) {
      setState(() => _error = '请输入有效的模板金额');
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
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: () => Navigator.of(context).maybePop(),
            radius: 22,
            child: const Padding(
              padding: EdgeInsets.all(FxSpacing.xs),
              child: Icon(Icons.chevron_left_rounded,
                  size: 26, color: FxColors.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              widget.isEdit ? '编辑周期规则' : '新增周期规则',
              style: FxTypography.title,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingOptions) return FxStateView.loading();
    if (_optionsError != null) {
      return FxStateView.error(message: _optionsError, onRetry: _loadOptions);
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
          _sectionTitle('规则设置'),
          _label('规则名称'),
          TextField(controller: _nameCtrl, decoration: _dec('如：每月房租')),
          const SizedBox(height: FxSpacing.md),
          _label('cron 表达式'),
          TextField(
            controller: _cronCtrl,
            decoration: _dec('如：0 0 1 * * ?').copyWith(
              suffixIcon: _cronSuffix(),
            ),
            onChanged: _onCronChanged,
          ),
          _cronHint(),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('开始日期（可选）'),
                    TextField(
                      controller: _startCtrl,
                      decoration: _dec('yyyy-MM-dd'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('结束日期（可选）'),
                    TextField(
                      controller: _endCtrl,
                      decoration: _dec('yyyy-MM-dd'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          _label('最大执行次数（可选）'),
          TextField(
            controller: _maxCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('留空为不限'),
          ),
          if (_strategies.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.md),
            _label('补偿策略'),
            _strategyPicker(),
          ],
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              const Expanded(child: Text('启用', style: FxTypography.body)),
              Switch.adaptive(
                value: _enable,
                activeColor: FxColors.primary,
                onChanged: (v) => setState(() => _enable = v),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          _sectionTitle('账单模板'),
          _label('类型'),
          _typeSelector(),
          const SizedBox(height: FxSpacing.md),
          _label('标题（可选）'),
          TextField(controller: _titleCtrl, decoration: _dec('账单标题')),
          const SizedBox(height: FxSpacing.md),
          _label('金额'),
          TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('0.00'),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('分类'),
          _optionChips(
            _currentCategories,
            _categoryId,
            (id) => setState(() => _categoryId = _categoryId == id ? null : id),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('账户'),
          _optionChips(
            _options.accounts,
            _accountId,
            (id) => setState(() => _accountId = _accountId == id ? null : id),
          ),
          if (_options.tags.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.md),
            _label('标签（可多选，可选）'),
            _tagChips(),
          ],
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.md),
            Text(_error!,
                style: FxTypography.caption.copyWith(color: FxColors.danger)),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit ? '保存修改' : '创建规则',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget? _cronSuffix() {
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
      return const Icon(Icons.check_circle_rounded, color: FxColors.success);
    }
    if (_cronValid == false) {
      return const Icon(Icons.error_rounded, color: FxColors.danger);
    }
    return null;
  }

  Widget _cronHint() {
    if (_cronValid == false) {
      return Padding(
        padding: const EdgeInsets.only(top: FxSpacing.xs),
        child: Text(
          'cron 表达式无效',
          style: FxTypography.caption.copyWith(color: FxColors.danger),
        ),
      );
    }
    if (_cronValid == true) {
      return Padding(
        padding: const EdgeInsets.only(top: FxSpacing.xs),
        child: Text(
          'cron 表达式有效',
          style: FxTypography.caption.copyWith(color: FxColors.success),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _strategyPicker() {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: _strategies.map((s) {
        final selected = s.value == _recoveryStrategy;
        return _chip(
          s.label,
          selected,
          () => setState(() => _recoveryStrategy = s.value),
        );
      }).toList(),
    );
  }

  Widget _typeSelector() {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: FxBillType.selectable.map((t) {
        final selected = t == _billType;
        return _chip(t.label, selected, () {
          setState(() {
            _billType = t;
            _categoryId = null; // 类型变化清空分类。
          });
        });
      }).toList(),
    );
  }

  Widget _optionChips(
    List<SimpleOption> items,
    int? selectedId,
    ValueChanged<int> onTap,
  ) {
    if (items.isEmpty) {
      return const Text('暂无可选项', style: FxTypography.caption);
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: items.map((o) {
        final selected = o.id == selectedId;
        return _chip(
          o.name,
          selected,
          () {
            if (o.id != null) onTap(o.id!);
          },
        );
      }).toList(),
    );
  }

  Widget _tagChips() {
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: _options.tags.map((o) {
        final selected = o.id != null && _tagIds.contains(o.id);
        return _chip(
          o.name,
          selected,
          () {
            if (o.id == null) return;
            setState(() {
              if (_tagIds.contains(o.id)) {
                _tagIds.remove(o.id);
              } else {
                _tagIds.add(o.id!);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? FxColors.primaryContainer : FxColors.surfaceMuted,
          borderRadius: FxRadius.pillBorder,
          border: Border.all(
            color: selected ? FxColors.primary : FxColors.border,
          ),
        ),
        child: Text(
          label,
          style: FxTypography.label.copyWith(
            color: selected ? FxColors.primary : FxColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: FxSpacing.sm),
        child: Text(text, style: FxTypography.bodyStrong),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: FxSpacing.xs),
        child: Text(text, style: FxTypography.label),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: FxColors.surfaceMuted,
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
