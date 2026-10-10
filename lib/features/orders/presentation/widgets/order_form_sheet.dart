import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/features/payees/data/payee_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据新建/元数据编辑表单。
///
/// 新建支持三类单据；“下一步，记一笔”返回创建回执，由调用方打开预填编辑器。
/// 用户在第二步取消时，已创建的草稿 ID 原样保留，不做删除。
class OrderFormSheet extends StatefulWidget {
  final OrdersService service;
  final int bookId;
  final FinanceOrderDetail? order;
  final PayeeService? payeeService;
  final String Function()? requestIdFactory;

  const OrderFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    this.order,
    this.payeeService,
    this.requestIdFactory,
  });

  bool get isEdit => order != null;

  @override
  State<OrderFormSheet> createState() => OrderFormSheetState();
}

class OrderFormSheetState extends State<OrderFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _counterpartyCtrl;
  late final TextEditingController _dueDateCtrl;
  late final TextEditingController _remarkCtrl;
  late final PayeeService _payeeService;

  late FinanceOrderType _selectedType;
  int? _counterpartyId;
  List<FortunePayeeVo> _payees = const [];
  DateTime? _dueDate;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _selectedType = order?.type ?? FinanceOrderType.receivable;
    _titleCtrl = TextEditingController(text: order?.title ?? '');
    _counterpartyCtrl = TextEditingController(
      text: order?.counterpartyName ?? '',
    );
    _dueDate = order?.dueDate;
    _dueDateCtrl = TextEditingController(
      text: _dueDate == null ? '' : _formatDate(_dueDate!),
    );
    _remarkCtrl = TextEditingController(text: order?.remark ?? '');
    _payeeService = widget.payeeService ?? PayeeService();
    _loadPayees();
    _syncDefaultTitle();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _counterpartyCtrl.dispose();
    _dueDateCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  bool get _counterpartyLocked => widget.order?.canDelete == false;

  bool get isSubmitting => _submitting;

  Future<void> _submitAndClose({required bool continueFlow}) async {
    final result = await _submit();
    if (result != null && mounted) {
      Navigator.of(
        context,
      ).pop(OrderFormSheetResult(result: result, continueFlow: continueFlow));
    }
  }

  Future<FinanceOrderMutationResult?> submit({
    bool continueFlow = false,
    bool closeOnSuccess = false,
  }) => _submit(continueFlow: continueFlow, closeOnSuccess: closeOnSuccess);

  Future<FinanceOrderMutationResult?> _submit({
    bool continueFlow = false,
    bool closeOnSuccess = false,
  }) async {
    if (_submitting) return null;
    final title = _titleCtrl.text.trim();
    final counterparty = _counterpartyCtrl.text.trim();
    if (title.isEmpty || counterparty.isEmpty) {
      setState(
        () => _error = title.isEmpty
            ? S.of(context).ordersTitleRequired
            : S.of(context).ordersCounterpartyRequired,
      );
      return null;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = widget.order == null
          ? await widget.service.create(
              FinanceOrderCreateInput(
                bookId: widget.bookId,
                requestId: _requestId(),
                title: title,
                type: _selectedType,
                counterpartyId: _counterpartyId,
                counterpartyName: counterparty,
                dueDate: _dueDate,
                remark: _remarkCtrl.text.trim(),
              ),
            )
          : await widget.service.modify(
              FinanceOrderMetadataInput(
                bookId: widget.bookId,
                orderId: widget.order!.orderId!,
                requestId: _requestId(),
                expectedVersion: widget.order!.version ?? 0,
                title: title,
                type: widget.order!.type!,
                counterpartyId: _counterpartyLocked
                    ? widget.order!.counterpartyId
                    : _counterpartyId,
                counterpartyName: counterparty,
                dueDate: _dueDate,
                remark: _remarkCtrl.text.trim(),
              ),
            );
      if (closeOnSuccess && mounted) {
        Navigator.of(context).pop(result);
      }
      return result;
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = error is FxApiException
              ? error.message
              : error is FxFailure
              ? error.toString()
              : S.of(context).profileSaveFailedRetry;
        });
      }
      return null;
    }
  }

  Future<void> _loadPayees() async {
    try {
      final page = await _payeeService.getPage(
        bookId: widget.bookId,
        recycleBin: false,
      );
      if (mounted) setState(() => _payees = page.rows);
    } on Object {
      // 对象选择失败不阻塞手填名称；提交时由后端最终校验。
    }
  }

  Future<void> _pickCounterparty() async {
    final selected = await showModalBottomSheet<FortunePayeeVo>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final payee in _payees)
              ListTile(
                title: Text(payee.payeeName ?? ''),
                onTap: () => Navigator.of(context).pop(payee),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _counterpartyId = selected.payeeId;
      _counterpartyCtrl.text = selected.payeeName ?? '';
      _syncDefaultTitle();
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dueDate = picked;
      _dueDateCtrl.text = _formatDate(picked);
    });
  }

  void _clearDueDate() {
    setState(() {
      _dueDate = null;
      _dueDateCtrl.clear();
    });
  }

  /// 最近一次自动生成的标题。只要当前文本仍等于它（或为空），说明用户没有
  /// 手动改过标题，允许继续自动同步（切换类型 / 输入对方时都要刷新）；
  /// 一旦用户手改，文案与锚点脱钩，之后不再覆盖。
  String _lastAutoTitle = '';

  void _syncDefaultTitle() {
    if (widget.order != null) return;
    final current = _titleCtrl.text;
    if (current.isNotEmpty && current != _lastAutoTitle) return;
    final suffix = switch (_selectedType) {
      FinanceOrderType.receivable => ' · 债权',
      FinanceOrderType.payable => ' · 债务',
      FinanceOrderType.reimbursement => ' · 报销',
    };
    final counterparty = _counterpartyCtrl.text.trim();
    final next = counterparty.isEmpty ? suffix : '$counterparty · $suffix';
    if (next == current) return;
    _lastAutoTitle = next;
    _titleCtrl.text = next;
  }

  String _requestId() =>
      widget.requestIdFactory?.call() ?? _generateRequestId();

  static String _generateRequestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20, 32),
    ].join('-');
  }

  static String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
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
          _label(S.of(context).ordersType),
          if (widget.isEdit)
            FxChip(
              label: _typeLabel(_selectedType),
              selected: true,
              enabled: false,
              disabledOpacity: 1,
              onTap: () {},
            )
          else
            Wrap(
              spacing: FxSpacing.sm,
              runSpacing: FxSpacing.sm,
              children: [
                for (final type in FinanceOrderType.values)
                  FxChip(
                    label: _typeLabel(type),
                    selected: type == _selectedType,
                    onTap: () => setState(() {
                      _selectedType = type;
                      _syncDefaultTitle();
                    }),
                  ),
              ],
            ),
          if (widget.isEdit) ...[
            const SizedBox(height: FxSpacing.xs),
            Text(
              S.of(context).ordersTypeLockedReason,
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).ordersCounterparty),
          TextField(
            key: const ValueKey('order-counterparty-field'),
            controller: _counterpartyCtrl,
            enabled: !_counterpartyLocked,
            onChanged: (_) => _syncDefaultTitle(),
            decoration: _dec(
              context,
              S.of(context).ordersCounterpartyHint,
              suffix: IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: _counterpartyLocked ? null : _pickCounterparty,
              ),
            ),
          ),
          if (_counterpartyLocked) ...[
            const SizedBox(height: FxSpacing.xs),
            Text(
              S.of(context).ordersCounterpartyLockedReason,
              style: FxTypography.caption.copyWith(color: palette.warning),
            ),
          ],
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).ordersTitleOfType(_typeLabel(_selectedType))),
          TextField(
            controller: _titleCtrl,
            decoration: _dec(context, S.of(context).ordersTitleHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).ordersDueDateOptional),
          TextField(
            key: const ValueKey('order-due-date-field'),
            controller: _dueDateCtrl,
            readOnly: true,
            decoration: _dec(
              context,
              S.of(context).ordersDueDateHint,
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const ValueKey('order-due-date-clear'),
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: _clearDueDate,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    onPressed: _pickDueDate,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(S.of(context).ordersRemarkOptional),
          TextField(
            controller: _remarkCtrl,
            maxLines: 3,
            decoration: _dec(context, S.of(context).ordersRemarkHint),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.lg),
          if (widget.isEdit)
            FxButton(
              label: S.of(context).ordersSaveChanges,
              loading: _submitting,
              onPressed: () => _submitAndClose(continueFlow: false),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FxButton.tonal(
                  label: S.of(context).ordersSaveDraft,
                  onPressed: () => _submitAndClose(continueFlow: false),
                ),
                const SizedBox(height: FxSpacing.sm),
                FxButton(
                  label: S.of(context).ordersContinueToEntry,
                  loading: _submitting,
                  onPressed: () => _submitAndClose(continueFlow: true),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _typeLabel(FinanceOrderType type) => switch (type) {
    FinanceOrderType.receivable => S.of(context).ordersTypeReceivable,
    FinanceOrderType.payable => S.of(context).ordersTypePayable,
    FinanceOrderType.reimbursement => S.of(context).ordersTypeReimbursement,
  };

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  InputDecoration _dec(BuildContext context, String hint, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: FxPalette.of(context).surfaceMuted,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide.none,
        ),
      );
}

/// 表单关闭结果。continueFlow 表示调用方应打开预填记账编辑器。
class OrderFormSheetResult {
  final FinanceOrderMutationResult result;
  final bool continueFlow;

  const OrderFormSheetResult({
    required this.result,
    required this.continueFlow,
  });
}
