import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_permission.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/attachment_grid.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/category_split_section.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/editor_pickers.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/extras_section.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_validator.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_xfile_factory.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_action_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_date_picker.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_option_picker.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// BillEditor 记账表单页。
class BillEditorPage extends StatefulWidget {
  const BillEditorPage({super.key});

  @override
  State<BillEditorPage> createState() => _BillEditorPageState();
}

void _dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

class _BillEditorPageState extends State<BillEditorPage> {
  BillEditorState? _baseline;
  var _submitSuccess = false;

  bool _isDirty(BillEditorState state) {
    final baseline = _baseline;
    if (baseline == null) return false;

    return state.billType != baseline.billType ||
        state.transferAmount != baseline.transferAmount ||
        !_listEquals(state.categoryRows, baseline.categoryRows) ||
        state.accountId != baseline.accountId ||
        state.toAccountId != baseline.toAccountId ||
        state.payeeId != baseline.payeeId ||
        state.tradeTime != baseline.tradeTime ||
        !_listEquals(state.tagIds, baseline.tagIds) ||
        !_listEquals(state.memberIds, baseline.memberIds) ||
        state.orderId != baseline.orderId ||
        !_listEquals(state.extras, baseline.extras) ||
        !_attachmentsHaveSameIds(state.attachments, baseline.attachments) ||
        state.title != baseline.title ||
        state.titleTouched != baseline.titleTouched ||
        state.remark != baseline.remark ||
        state.confirm != baseline.confirm ||
        state.include != baseline.include;
  }

  bool _attachmentsHaveSameIds(
    List<BillAttachment> a,
    List<BillAttachment> b,
  ) => _listEquals(
    a.map((attachment) => attachment.id).toList(),
    b.map((attachment) => attachment.id).toList(),
  );

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _validationMessage(BuildContext context, BillValidationError e) {
    final s = S.of(context);
    switch (e) {
      case BillValidationError.transferAmountRequired:
        return s.billEditorValidateTransferAmount;
      case BillValidationError.transferFromRequired:
        return s.billEditorValidateTransferFrom;
      case BillValidationError.transferToRequired:
        return s.billEditorValidateTransferTo;
      case BillValidationError.transferSameAccount:
        return s.billEditorValidateTransferSame;
      case BillValidationError.categoryRequired:
        return s.billEditorValidateCategoryRequired;
      case BillValidationError.categorySelectRequired:
        return s.billEditorValidateCategorySelect;
      case BillValidationError.categoryAmountPositive:
        return s.billEditorValidateCategoryAmount;
      case BillValidationError.amountRequired:
        return s.billEditorValidateAmount;
      case BillValidationError.accountRequired:
        return s.billEditorValidateAccount;
      case BillValidationError.orderRequired:
        return s.billEditorValidateOrder;
      case BillValidationError.orderUnavailable:
        return s.billEditorValidateOrder;
      case BillValidationError.writeOffReasonRequired:
        return s.billEditorValidateWriteOffReason;
      case BillValidationError.titleRequired:
        return s.billEditorValidateTitle;
      case BillValidationError.extraCategoryRequired:
        return s.billEditorValidateExtraCategory;
      case BillValidationError.extraCategoryNotInSplit:
        return s.billEditorValidateExtraCategoryInSplit;
      case BillValidationError.transferExtraAccountSideInvalid:
        return s.billEditorValidateTransferExtraAccountSide;
    }
  }

  String _submitFailureMessage(BuildContext context, FxFailure? failure) {
    final s = S.of(context);
    return switch (failure?.kind) {
      FxFailureKind.network ||
      FxFailureKind.timeout => s.billEditorSubmitNetworkFailed,
      FxFailureKind.unauthorized ||
      FxFailureKind.forbidden => s.billEditorSubmitAuthFailed,
      FxFailureKind.persistence ||
      FxFailureKind.validation => s.billEditorAttachmentUnreadable,
      _ => s.profileSaveFailedRetry,
    };
  }

  Future<void> _confirmPop(BillEditorState state) async {
    _dismissKeyboard();
    if (_submitSuccess || !_isDirty(state)) {
      Navigator.of(context).pop();
      return;
    }

    final s = S.of(context);
    final confirmed = await FxConfirmSheet.show(
      context,
      title: s.billEditorDiscardTitle,
      message: s.billEditorDiscardMessage,
      confirmLabel: s.billEditorDiscardConfirm,
      cancelLabel: s.commonCancel,
      destructive: true,
      onConfirm: () async => true,
    );
    if (!mounted) return;
    if (confirmed == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillEditorBloc, BillEditorState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          _submitSuccess = true;
          BillMutations.bump();
          Navigator.of(context).pop(true);
        } else if (state.submitStatus == SubmitStatus.failure) {
          final group = context.read<SessionCubit>().state.currentGroup;
          final message = state.validationFailure != null
              ? _validationMessage(context, state.validationFailure!)
              : (!SessionPermission.canWrite(group)
                    ? S.of(context).permissionVisitorNoAccess
                    : _submitFailureMessage(context, state.submitFailure));
          FxFeedback.error(context, message: message);
        }
      },
      builder: (context, state) {
        if (state.status == EditorStatus.ready && _baseline == null) {
          _baseline = state;
        }
        final palette = FxPalette.of(context);
        return PopScope(
          canPop: _submitSuccess || !_isDirty(state),
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _confirmPop(state);
          },
          child: Scaffold(
            backgroundColor: palette.canvas,
            appBar: AppBar(
              backgroundColor: palette.surface,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              title: Text(
                state.mode == 'edit'
                    ? S.of(context).billEditorEditTitle
                    : S.of(context).billEditorNewTitle,
                style: FxTypography.title,
              ),
              leading: FxIconButton(
                icon: Icons.close_rounded,
                tooltip: S.of(context).commonCancel,
                color: palette.textPrimary,
                onPressed: () {
                  _dismissKeyboard();
                  Navigator.of(context).maybePop();
                },
              ),
            ),
            body: switch (state.status) {
              EditorStatus.loading => FxStateView.loading(),
              EditorStatus.error => FxStateView.error(
                message: state.loadError ?? S.of(context).profileLoadFailed,
                onRetry: () => context.read<BillEditorBloc>().add(
                  const BillEditorRetried(),
                ),
              ),
              EditorStatus.ready => _EditorBody(state: state),
            },
            bottomNavigationBar: state.status == EditorStatus.ready
                ? _SubmitBar(state: state)
                : null,
          ),
        );
      },
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final currency = _currency(state);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        FxSpacing.xxxl,
      ),
      children: [
        // 类型选择：先选单据组，再选组内动作，避免 9 个均分分段被挤压截断。
        Opacity(
          opacity: state.lockBillType ? 0.6 : 1,
          child: IgnorePointer(
            ignoring: state.lockBillType,
            child: _BillTypeSection(state: state),
          ),
        ),
        const SizedBox(height: FxSpacing.lg),

        // 核心字段共享一个连续表面，避免每个输入项都形成独立卡片。
        FxListSection(
          key: const ValueKey('bill-editor-core-section'),
          dividerIndent: FxSpacing.lg,
          children: [
            _TitleCard(state: state),
            _AmountArea(state: state, currency: currency),
            if (state.isOrderFlow && state.showCategorySplit)
              _OrderCategorySplitSection(state: state, currencyCode: currency)
            else if (state.showCategorySplit)
              CategorySplitSection(state: state, currencyCode: currency),
            if (state.isTransfer) ...[
              _TransferAccountRow(state: state, isOut: true),
              _TransferAccountRow(state: state, isOut: false),
            ] else if (state.showAccount)
              _AccountRow(state: state),
            if (state.isWriteOff)
              _PickerRow(
                label: S.of(context).billEditorAccount,
                value: S.of(context).billEditorWriteOffAccount,
                onTap: null,
              ),
            if (state.showPayee) _PayeeRow(state: state),
            if (state.showOrder) _OrderRow(state: state),
            _TradeTimeRow(state: state),
            _TagsRow(state: state),
            _MembersRow(state: state),
            _RemarkCard(state: state),
          ],
        ),
        const SizedBox(height: FxSpacing.lg),

        // 附加费用
        if (state.showExtras) ...[
          ExtrasSection(state: state, currencyCode: currency),
          const SizedBox(height: FxSpacing.lg),
        ],

        // 附件
        _AttachmentCard(state: state),
        const SizedBox(height: FxSpacing.lg),

        // 开关
        _TogglesCard(state: state),
      ],
    );
  }
}

/// 记账类型两级选择：第一级按业务分组（记账/债权单/债务单/费用报销单），
/// 第二级在组内选具体动作；分组变更时落到该组首个动作。
class _BillTypeSection extends StatelessWidget {
  const _BillTypeSection({required this.state});

  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final s = S.of(context);
    final group = _billTypeGroupOf(state.billType);
    return Column(
      children: [
        FxSegmented<_BillTypeGroup>(
          value: group,
          onChanged: (next) {
            _dismissKeyboard();
            if (next == group) return;
            bloc.add(BillTypeChanged(next.types.first));
          },
          segments: [
            FxSegment(_BillTypeGroup.classic, s.billGroupClassic),
            FxSegment(_BillTypeGroup.receivable, s.ordersTypeReceivable),
            FxSegment(_BillTypeGroup.payable, s.ordersTypePayable),
            FxSegment(_BillTypeGroup.reimbursement, s.ordersTypeReimbursement),
          ],
        ),
        const SizedBox(height: FxSpacing.sm),
        FxSegmented<FxBillType>(
          value: state.billType,
          onChanged: (type) {
            _dismissKeyboard();
            bloc.add(BillTypeChanged(type));
          },
          segments: group.types
              .map((t) => FxSegment(t, t.localizedLabel(context)))
              .toList(),
        ),
      ],
    );
  }
}

/// 账单类型的业务分组，与 9 个可选手选类型一一对应。
enum _BillTypeGroup {
  classic([FxBillType.expense, FxBillType.income, FxBillType.transfer]),
  receivable([FxBillType.loanOut, FxBillType.loanRecover]),
  payable([FxBillType.loanIn, FxBillType.loanRepay]),
  reimbursement([FxBillType.advance, FxBillType.reimburse]);

  const _BillTypeGroup(this.types);

  /// 组内动作，首项作为分组切换时的默认动作。
  final List<FxBillType> types;
}

_BillTypeGroup _billTypeGroupOf(FxBillType type) {
  for (final group in _BillTypeGroup.values) {
    if (group.types.contains(type)) return group;
  }
  // 余额调整等系统类型不可手选，兜底归入记账组。
  return _BillTypeGroup.classic;
}

String _currency(BillEditorState state) {
  for (final a in state.options.accounts) {
    if (a.accountId == state.accountId && a.currencyCode != null) {
      return a.currencyCode!;
    }
  }
  return '';
}

/// 附属 1/2 流水显示业务动作名，而不是笼统的支出/收入。
String _businessActionLabel(BuildContext context, BillEditorState state) {
  final s = S.of(context);
  return switch (state.orderComponent) {
    FinanceOrderComponent.interest =>
      state.isIncome ? s.orderActionInterestIn : s.orderActionInterestOut,
    FinanceOrderComponent.fee => s.orderActionFee,
    FinanceOrderComponent.writeOff => switch (state.orderTypeOfSelection) {
      FinanceOrderType.receivable => s.orderActionWriteOffReceivable,
      FinanceOrderType.payable => s.orderActionWriteOffPayable,
      FinanceOrderType.reimbursement ||
      null => s.orderActionWriteOffReimbursement,
    },
    FinanceOrderComponent.principal ||
    null => state.billType.localizedLabel(context),
  };
}

// ---------------- 金额区 ----------------

class _AmountArea extends StatelessWidget {
  const _AmountArea({required this.state, required this.currency});
  final BillEditorState state;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final tint = FxFinanceColors.of(context).forBillType(state.billTypeValue);

    if (state.isTransfer) {
      return Padding(
        padding: const EdgeInsets.all(FxSpacing.lg),
        child: AmountField(
          label: S.of(context).billEditorTransferAmount,
          value: state.transferAmount,
          currencyCode: currency,
          tint: tint,
          onChanged: (v) => bloc.add(TransferAmountChanged(v)),
        ),
      );
    }

    if (state.showSingleAmount) {
      return Padding(
        padding: const EdgeInsets.all(FxSpacing.lg),
        child: _OrderAmountField(
          label: _businessActionLabel(context, state),
          value: state.singleAmountCents,
          currencyCode: currency,
          tint: tint,
          onChanged: (cents) => bloc.add(SingleAmountChanged(cents)),
        ),
      );
    }

    // 支出/收入/垫付/报销：大数字来自分类拆分总额（只读展示）。
    return Padding(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _businessActionLabel(context, state),
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          FxMoneyText(
            amount: state.categoryTotal,
            currencyCode: currency,
            color: tint,
            fontSize: FxTypography.display.fontSize ?? 34,
            fontWeight: FxTypography.display.fontWeight ?? FontWeight.w700,
          ),
          const SizedBox(height: FxSpacing.xs),
          Text(
            S.of(context).billEditorAmountHint,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单据关联流水的分类拆分。金额输入直接转换为整数分。
class _OrderCategorySplitSection extends StatelessWidget {
  const _OrderCategorySplitSection({
    required this.state,
    required this.currencyCode,
  });

  final BillEditorState state;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    return Column(
      children: [
        for (var index = 0; index < state.categoryRows.length; index++)
          _OrderCategoryRow(
            row: state.categoryRows[index],
            currencyCode: currencyCode,
            canRemove: state.categoryRows.length > 1,
            onPickCategory: () async {
              _dismissKeyboard();
              final categories = state.usesIncomeAssociations
                  ? state.options.incomeCategories
                  : state.options.expenseCategories;
              final picked = await FxTreePicker.show<CategoryNode>(
                context,
                roots: categories,
                childrenOf: (node) => node.children,
                labelOf: (node) => node.categoryName ?? '',
                idOf: (node) => node.categoryId,
                initialSelected: state.categoryRows[index].categoryId == null
                    ? const {}
                    : {state.categoryRows[index].categoryId! as Object},
                leafOnly: true,
                initiallyCollapsed: true,
                title: S.of(context).billEditorSelectCategory,
              );
              if (!context.mounted || picked == null || picked.isEmpty) return;
              final category = picked.first;
              bloc.add(
                CategoryRowCategoryChanged(
                  state.categoryRows[index].rowId,
                  category.categoryId,
                  category.categoryName,
                ),
              );
            },
            onAmount: (cents) => bloc.add(
              OrderCategoryRowAmountChanged(
                state.categoryRows[index].rowId,
                cents,
              ),
            ),
            onRemove: () {
              _dismissKeyboard();
              bloc.add(CategoryRowRemoved(state.categoryRows[index].rowId));
            },
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.sm,
            FxSpacing.lg,
            FxSpacing.md,
          ),
          child: InkWell(
            onTap: () => bloc.add(const CategoryRowAdded()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: FxPalette.of(context).primary,
                  ),
                  const SizedBox(width: FxSpacing.xs),
                  Text(
                    S.of(context).billEditorAddCategory,
                    style: FxTypography.bodyStrong.copyWith(
                      color: FxPalette.of(context).primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderCategoryRow extends StatelessWidget {
  const _OrderCategoryRow({
    required this.row,
    required this.currencyCode,
    required this.canRemove,
    required this.onPickCategory,
    required this.onAmount,
    required this.onRemove,
  });

  final CategoryAmountRow row;
  final String currencyCode;
  final bool canRemove;
  final VoidCallback onPickCategory;
  final ValueChanged<int> onAmount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hasCategory = row.categoryName?.isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: onPickCategory,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FxSpacing.md,
                  vertical: FxSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Text(
                  hasCategory
                      ? row.categoryName!
                      : S.of(context).billEditorSelectCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FxTypography.body.copyWith(
                    color: hasCategory
                        ? palette.textPrimary
                        : palette.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            flex: 3,
            child: _OrderAmountField(
              key: ValueKey('order_cat_amount_${row.rowId}'),
              value: row.amountCents,
              currencyCode: currencyCode,
              large: false,
              onChanged: onAmount,
            ),
          ),
          if (canRemove)
            FxIconButton(
              icon: Icons.remove_circle_outline_rounded,
              tooltip: S.of(context).accountsDelete,
              color: palette.textTertiary,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

/// 新单据金额输入：字符串解析为整数分，不经过 double。
class _OrderAmountField extends StatefulWidget {
  const _OrderAmountField({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.currencyCode,
    this.tint,
    this.large = true,
  });

  final String? label;
  final int value;
  final ValueChanged<int> onChanged;
  final String? currencyCode;
  final Color? tint;
  final bool large;

  @override
  State<_OrderAmountField> createState() => _OrderAmountFieldState();
}

class _OrderAmountInputFormatter extends TextInputFormatter {
  static final _valid = RegExp(r'^\d*\.?\d{0,2}$');

  const _OrderAmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty || text == '.' || _valid.hasMatch(text)) return newValue;
    return oldValue;
  }
}

class _OrderAmountFieldState extends State<_OrderAmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(_OrderAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final current = _parseCents(_controller.text);
      if (current != widget.value) {
        _controller.text = _format(widget.value);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _format(int cents) =>
      cents == 0 ? '' : OrderMoney.fromCents(cents).toApiString();

  static int _parseCents(String text) {
    if (text.isEmpty) return 0;
    try {
      return OrderMoney.parseInput(text).cents;
    } on Object {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final color = widget.tint ?? palette.textPrimary;
    final fontSize = widget.large ? 34.0 : 20.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: FxTypography.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.sm),
        ],
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [const _OrderAmountInputFormatter()],
          style: FxTypography.money.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: '0',
            hintStyle: FxTypography.money.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: palette.textTertiary,
            ),
          ),
          onChanged: (text) => widget.onChanged(_parseCents(text)),
        ),
      ],
    );
  }
}

// ---------------- 明细行 ----------------

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final accounts = state.options.accounts.where((a) {
      if (state.usesIncomeAssociations) return a.canIncome;
      return a.canExpense;
    }).toList();

    return _PickerRow(
      label: S.of(context).billEditorAccount,
      value: state.accountName,
      placeholder: S.of(context).billEditorSelectAccountHint,
      onTap: () async {
        _dismissKeyboard();
        final picked = await showAccountOptionPicker(
          context,
          title: S.of(context).billEditorSelectAccount,
          accounts: accounts,
          selectedId: state.accountId,
        );
        if (!context.mounted || picked == null) return;
        bloc.add(AccountChanged(picked.accountId, picked.accountName));
      },
    );
  }
}

class _TransferAccountRow extends StatelessWidget {
  const _TransferAccountRow({required this.state, required this.isOut});
  final BillEditorState state;
  final bool isOut;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final accounts = state.options.accounts
        .where((a) => isOut ? a.canTransferOut : a.canTransferIn)
        .toList();
    final value = isOut ? state.accountName : state.toAccountName;
    final selectedId = isOut ? state.accountId : state.toAccountId;

    return _PickerRow(
      label: isOut
          ? S.of(context).billEditorTransferOutAccount
          : S.of(context).billEditorTransferInAccount,
      value: value,
      placeholder: isOut
          ? S.of(context).billEditorSelectTransferOutHint
          : S.of(context).billEditorSelectTransferInHint,
      onTap: () async {
        _dismissKeyboard();
        final picked = await showAccountOptionPicker(
          context,
          title: isOut
              ? S.of(context).billEditorSelectTransferOut
              : S.of(context).billEditorSelectTransferIn,
          accounts: accounts,
          selectedId: selectedId,
        );
        if (!context.mounted || picked == null) return;
        if (isOut) {
          bloc.add(AccountChanged(picked.accountId, picked.accountName));
        } else {
          bloc.add(ToAccountChanged(picked.accountId, picked.accountName));
        }
      },
    );
  }
}

class _PayeeRow extends StatelessWidget {
  const _PayeeRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final payees = state.options.payees.where((p) {
      if (state.usesIncomeAssociations) return p.canIncome;
      return p.canExpense;
    }).toList();

    return _PickerRow(
      label: S.of(context).billEditorPayee,
      value: state.payeeName,
      placeholder: S.of(context).billEditorOptional,
      onTap: () async {
        _dismissKeyboard();
        final picked = await showOptionPicker<PayeeOption>(
          context,
          title: S.of(context).billEditorSelectPayee,
          options: payees,
          labelOf: (p) => p.payeeName ?? '',
          selectedId: state.payeeId,
          idOf: (p) => p.payeeId,
          allowClear: true,
        );
        if (!context.mounted || picked.kind == FxSelectionKind.cancelled) {
          return;
        }
        final payee = picked.value;
        bloc.add(PayeeChanged(payee?.payeeId, payee?.payeeName));
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    return _PickerRow(
      label: S.of(context).billEditorOrder,
      value: state.orderTitle,
      placeholder: S.of(context).billEditorRequired,
      required: true,
      onTap: state.lockOrderContext
          ? null
          : () async {
              _dismissKeyboard();
              final picked = await showOptionPicker<OrderOption>(
                context,
                title: S.of(context).billEditorSelectOrder,
                options: state.options.orders
                    .where((order) => order.enabled)
                    .toList(),
                labelOf: (o) => [
                  o.title,
                  o.typeDesc,
                ].where((s) => s != null && s.isNotEmpty).join(' · '),
                selectedId: state.orderId,
                idOf: (o) => o.orderId,
              );
              if (!context.mounted || picked.kind != FxSelectionKind.selected) {
                return;
              }
              final order = picked.value!;
              bloc.add(OrderChanged(order.orderId, order.title));
            },
    );
  }
}

class _TradeTimeRow extends StatelessWidget {
  const _TradeTimeRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final text = BillService.dateTimeFormat.format(state.tradeTime);
    return _PickerRow(
      label: S.of(context).billEditorTime,
      value: text,
      onTap: () async {
        _dismissKeyboard();
        final picked = await showFxDateTimePicker(
          context,
          initial: state.tradeTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          title: S.of(context).billEditorTradeTime,
        );
        if (!context.mounted || picked == null) return;
        bloc.add(TradeTimeChanged(picked));
      },
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    // 按当前账单类型过滤标签树：保留可用节点及其祖先，维持树形层级。
    bool usable(TagNode t) {
      if (state.isTransfer) return t.canTransfer;
      if (state.usesIncomeAssociations) return t.canIncome;
      return t.canExpense;
    }

    List<TagNode> prune(List<TagNode> nodes) {
      final result = <TagNode>[];
      for (final n in nodes) {
        final children = prune(n.children);
        if (usable(n) || children.isNotEmpty) {
          result.add(
            TagNode(
              tagId: n.tagId,
              tagName: n.tagName,
              canExpense: n.canExpense,
              canIncome: n.canIncome,
              canTransfer: n.canTransfer,
              children: children,
            ),
          );
        }
      }
      return result;
    }

    final roots = prune(state.options.tags);

    return FxSelectRow(
      label: S.of(context).billEditorTags,
      value: state.tagNames.isEmpty ? null : state.tagNames.join('、'),
      placeholder: S.of(context).billEditorAddTags,
      onTap: () async {
        _dismissKeyboard();
        final selectableIds = <int>{};
        void collectSelectableIds(List<TagNode> nodes) {
          for (final node in nodes) {
            if (usable(node) && node.tagId != null) {
              selectableIds.add(node.tagId!);
            }
            collectSelectableIds(node.children);
          }
        }

        collectSelectableIds(roots);
        final result = await FxTreePicker.show<TagNode>(
          context,
          roots: roots,
          childrenOf: (t) => t.children,
          labelOf: (t) => t.tagName ?? '',
          idOf: (tag) => usable(tag) ? tag.tagId : null,
          initialSelected: state.tagIds
              .where(selectableIds.contains)
              .map((id) => id as Object)
              .toSet(),
          multiSelect: true,
          initiallyCollapsed: true,
          title: S.of(context).billEditorSelectTags,
        );
        if (!context.mounted || result == null) return;
        final selected = result.where(
          (tag) => usable(tag) && tag.tagId != null,
        );
        bloc.add(
          TagsChanged(
            selected.map((tag) => tag.tagId!).toList(),
            selected.map((tag) => tag.tagName ?? '').toList(),
          ),
        );
      },
    );
  }
}

class _MembersRow extends StatelessWidget {
  const _MembersRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final members = state.options.members
        .where((m) => m.memberId != null)
        .toList();
    return _PickerRow(
      label: S.of(context).billEditorMembers,
      value: state.memberNames.isEmpty ? null : state.memberNames.join('、'),
      placeholder: S.of(context).billEditorOptional,
      onTap: () async {
        _dismissKeyboard();
        final result = await showMultiSelect<MemberOption>(
          context,
          title: S.of(context).billEditorSelectMembers,
          options: members,
          labelOf: (m) => m.memberName ?? '',
          idOf: (m) => m.memberId!,
          selectedIds: state.memberIds,
        );
        if (!context.mounted || result == null) return;
        bloc.add(
          MembersChanged(
            result.map((member) => member.memberId!).toList(),
            result.map((member) => member.memberName ?? '').toList(),
          ),
        );
      },
    );
  }
}

/// 通用「标签 + 值 + 箭头」行。
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    this.value,
    this.placeholder,
    this.required = false,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String? placeholder;
  final bool required;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FxSelectRow(
      label: label,
      value: value,
      placeholder: placeholder ?? S.of(context).commonPleaseSelect,
      required: required,
      onTap: onTap,
    );
  }
}

// ---------------- 附件 ----------------

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    return FxCard(
      child: AttachmentGrid(
        files: state.attachments,
        enabled: state.submitStatus != SubmitStatus.submitting,
        onRemove: (i) => bloc.add(AttachmentRemoved(i)),
        onAdd: () => _showAttachmentSourceSheet(context, bloc),
      ),
    );
  }

  Future<void> _showAttachmentSourceSheet(
    BuildContext context,
    BillEditorBloc bloc,
  ) {
    _dismissKeyboard();
    final s = S.of(context);
    return FxActionSheet.show(
      context,
      title: s.billEditorAddAttachment,
      actions: [
        FxSheetAction(
          label: s.billEditorChoosePhoto,
          icon: Icons.photo_library_outlined,
          onPressed: () => _pickPhotos(context, bloc),
        ),
        FxSheetAction(
          label: s.billEditorChooseFile,
          icon: Icons.attach_file_rounded,
          onPressed: () => _pickFiles(context, bloc),
        ),
      ],
    );
  }

  Future<void> _pickPhotos(BuildContext context, BillEditorBloc bloc) async {
    try {
      _AttachmentPickerDiagnostics.start(source: 'photo');
      final files = await ImagePicker().pickMultiImage();
      if (files.isEmpty) {
        _AttachmentPickerDiagnostics.cancelledOrNoResult();
        return;
      }
      final attachments = <BillAttachment>[];
      var remainingBytes = BillAttachmentValidator.maxTotalBytes;
      for (var index = 0; index < files.length; index += 1) {
        final attachment = await billAttachmentFromXFile(
          files[index],
          selectionIndex: index,
          remainingBytes: remainingBytes,
        );
        if (attachment != null) {
          attachments.add(attachment);
          remainingBytes -= attachment.sizeBytes;
        }
      }
      if (!context.mounted) return;
      await _addAttachments(context, bloc, attachments, source: 'photo');
    } on PlatformException catch (error, stackTrace) {
      _showPlatformFailure(context, error, stackTrace);
    } on MissingPluginException catch (_, stackTrace) {
      _showPluginFailure(context, stackTrace);
    } on Object catch (error, stackTrace) {
      _showUnknownFailure(context, error, stackTrace);
    }
  }

  Future<void> _pickFiles(BuildContext context, BillEditorBloc bloc) async {
    try {
      _AttachmentPickerDiagnostics.start(source: 'file');
      final files = await file_selector.openFiles();
      if (files.isEmpty) {
        _AttachmentPickerDiagnostics.cancelledOrNoResult();
        return;
      }
      final attachments = <BillAttachment>[];
      var remainingBytes = BillAttachmentValidator.maxTotalBytes;
      for (var index = 0; index < files.length; index += 1) {
        final attachment = await billAttachmentFromXFile(
          files[index],
          selectionIndex: index,
          remainingBytes: remainingBytes,
        );
        if (attachment != null) {
          attachments.add(attachment);
          remainingBytes -= attachment.sizeBytes;
        }
      }
      if (!context.mounted) return;
      await _addAttachments(context, bloc, attachments, source: 'file');
    } on PlatformException catch (error, stackTrace) {
      _showPlatformFailure(context, error, stackTrace);
    } on MissingPluginException catch (_, stackTrace) {
      _showPluginFailure(context, stackTrace);
    } on Object catch (error, stackTrace) {
      _showUnknownFailure(context, error, stackTrace);
    }
  }

  Future<void> _addAttachments(
    BuildContext context,
    BillEditorBloc bloc,
    List<BillAttachment> attachments, {
    required String source,
  }) async {
    var rejected = attachments.isEmpty;
    final attachmentIds = state.attachments
        .map((attachment) => attachment.id)
        .toSet();
    final uniqueAttachments = attachments
        .where((attachment) => attachmentIds.add(attachment.id))
        .toList();
    final validator = const BillAttachmentValidator();
    final validAttachments = <BillAttachment>[];
    var acceptedSizeBytes = 0;
    try {
      for (final attachment in state.attachments) {
        acceptedSizeBytes += (await validator.inspect(attachment)).sizeBytes;
      }
      for (final attachment in uniqueAttachments) {
        try {
          final inspection = await validator.inspect(attachment);
          if (acceptedSizeBytes + inspection.sizeBytes >
              BillAttachmentValidator.maxTotalBytes) {
            rejected = true;
            continue;
          }
          acceptedSizeBytes += inspection.sizeBytes;
          validAttachments.add(attachment);
        } on BillAttachmentValidationException {
          rejected = true;
        }
      }
    } on BillAttachmentValidationException {
      rejected = true;
    }
    if (!context.mounted) return;
    if (validAttachments.isNotEmpty) {
      bloc.add(AttachmentsAdded(validAttachments));
    }
    _AttachmentPickerDiagnostics.validated(
      source: source,
      validFiles: validAttachments.length,
      rejected: rejected,
    );
    if (rejected) {
      FxFeedback.error(
        context,
        message: S.of(context).billEditorAttachmentInvalid,
      );
    }
  }

  void _showPlatformFailure(
    BuildContext context,
    PlatformException error,
    StackTrace stackTrace,
  ) {
    _AttachmentPickerDiagnostics.platformFailure(
      code: error.code,
      stackTrace: stackTrace,
    );
    if (!context.mounted) return;
    final message = error.code.startsWith('ENTITLEMENT_')
        ? S.of(context).billEditorAttachmentPermissionRequired
        : S.of(context).billEditorAttachmentPickFailed;
    FxFeedback.error(context, message: message);
  }

  void _showPluginFailure(BuildContext context, StackTrace stackTrace) {
    _AttachmentPickerDiagnostics.pluginFailure(stackTrace);
    if (!context.mounted) return;
    FxFeedback.error(
      context,
      message: S.of(context).billEditorAttachmentPluginUnavailable,
    );
  }

  void _showUnknownFailure(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _AttachmentPickerDiagnostics.unknownFailure(
      type: error.runtimeType,
      stackTrace: stackTrace,
    );
    if (!context.mounted) return;
    FxFeedback.error(
      context,
      message: S.of(context).billEditorAttachmentPickFailed,
    );
  }
}

class _AttachmentPickerDiagnostics {
  static const _tag = '[BillEditorAttachmentPicker]';

  static void start({required String source}) =>
      debugPrint('$_tag start source=$source');

  static void cancelledOrNoResult() =>
      debugPrint('$_tag cancelled-or-no-result');

  static void validated({
    required String source,
    required int validFiles,
    required bool rejected,
  }) {
    debugPrint(
      '$_tag validated source=$source '
      'validFiles=$validFiles rejected=$rejected',
    );
  }

  static void platformFailure({
    required String code,
    required StackTrace stackTrace,
  }) {
    _report('bill_attachment_pick_failed phase=picker code=$code', stackTrace);
  }

  static void pluginFailure(StackTrace stackTrace) {
    _report('bill_attachment_pick_failed phase=plugin', stackTrace);
  }

  static void unknownFailure({
    required Type type,
    required StackTrace stackTrace,
  }) {
    _report('bill_attachment_pick_failed phase=unknown type=$type', stackTrace);
  }

  static void _report(String message, StackTrace stackTrace) {
    debugPrint('$_tag $message');
    debugPrintStack(stackTrace: stackTrace);
  }
}

// ---------------- 标题 ----------------

class _TitleCard extends StatefulWidget {
  const _TitleCard({required this.state});
  final BillEditorState state;

  @override
  State<_TitleCard> createState() => _TitleCardState();
}

class _TitleCardState extends State<_TitleCard> {
  late final TextEditingController _title;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.state.title);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final bloc = context.read<BillEditorBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).billEditorTitle,
            style: FxTypography.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.xs),
          TextField(
            controller: _title,
            style: FxTypography.body,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.state.suggestedTitle.isEmpty
                  ? S.of(context).billEditorTitleHint
                  : S
                        .of(context)
                        .billEditorTitleDefault(widget.state.suggestedTitle),
              hintStyle: FxTypography.body.copyWith(
                color: palette.textTertiary,
              ),
            ),
            onChanged: (v) => bloc.add(TitleChanged(v)),
          ),
        ],
      ),
    );
  }
}

// ---------------- 备注 ----------------

class _RemarkCard extends StatefulWidget {
  const _RemarkCard({required this.state});
  final BillEditorState state;

  @override
  State<_RemarkCard> createState() => _RemarkCardState();
}

class _RemarkCardState extends State<_RemarkCard> {
  late final TextEditingController _remark;

  @override
  void initState() {
    super.initState();
    _remark = TextEditingController(text: widget.state.remark);
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final bloc = context.read<BillEditorBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).billEditorRemark,
            style: FxTypography.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.xs),
          TextField(
            controller: _remark,
            style: FxTypography.body,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: S.of(context).billEditorRemarkHint,
              hintStyle: FxTypography.body.copyWith(
                color: palette.textTertiary,
              ),
            ),
            onChanged: (v) => bloc.add(RemarkChanged(v)),
          ),
        ],
      ),
    );
  }
}

// ---------------- 开关 ----------------

class _TogglesCard extends StatelessWidget {
  const _TogglesCard({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final bloc = context.read<BillEditorBloc>();
    return FxCard(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeColor: palette.primary,
            title: Text(
              S.of(context).billEditorConfirmed,
              style: FxTypography.bodyStrong,
            ),
            subtitle: Text(
              S.of(context).billEditorConfirmedSubtitle,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
            value: state.confirm,
            onChanged: state.confirmLocked
                ? null
                : (v) => bloc.add(ConfirmToggled(v)),
          ),
          Divider(height: 1, color: palette.border),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeColor: palette.primary,
            title: Text(
              S.of(context).billEditorInclude,
              style: FxTypography.bodyStrong,
            ),
            subtitle: Text(
              S.of(context).billEditorIncludeSubtitle,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
            value: state.effectiveInclude,
            onChanged: state.includeLocked
                ? null
                : (v) => bloc.add(IncludeToggled(v)),
          ),
        ],
      ),
    );
  }
}

// ---------------- 底部提交栏 ----------------

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final submitting = state.submitStatus == SubmitStatus.submitting;
    final palette = FxPalette.of(context);
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.md,
            FxSpacing.lg,
            FxSpacing.md,
          ),
          child: FxButton(
            label: state.mode == 'edit'
                ? S.of(context).billEditorSaveEdit
                : S.of(context).billEditorSaveNew,
            expand: true,
            loading: submitting,
            onPressed: submitting
                ? null
                : () {
                    _dismissKeyboard();
                    bloc.add(const BillEditorSubmitted());
                  },
          ),
        ),
      ),
    );
  }
}
