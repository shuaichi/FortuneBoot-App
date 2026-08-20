import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/attachment_grid.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/category_split_section.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/editor_pickers.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/extras_section.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_date_picker.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// BillEditor 记账表单页。
class BillEditorPage extends StatelessWidget {
  const BillEditorPage({super.key});

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
      case BillValidationError.accountRequired:
        return s.billEditorValidateAccount;
      case BillValidationError.orderRequired:
        return s.billEditorValidateOrder;
      case BillValidationError.titleRequired:
        return s.billEditorValidateTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillEditorBloc, BillEditorState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          BillMutations.bump();
          Navigator.of(context).pop(true);
        } else if (state.submitStatus == SubmitStatus.failure) {
          final message = state.validationFailure != null
              ? _validationMessage(context, state.validationFailure!)
              : state.submitError ?? S.of(context).profileSaveFailedRetry;
          FxFeedback.error(context, message: message);
        }
      },
      builder: (context, state) {
        final palette = FxPalette.of(context);
        return Scaffold(
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
            leading: IconButton(
              tooltip: S.of(context).commonCancel,
              icon: Icon(Icons.close_rounded, color: palette.textPrimary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: switch (state.status) {
            EditorStatus.loading => FxStateView.loading(),
            EditorStatus.error => FxStateView.error(
              message: state.loadError ?? S.of(context).profileLoadFailed,
              onRetry: () =>
                  context.read<BillEditorBloc>().add(const BillEditorRetried()),
            ),
            EditorStatus.ready => _EditorBody(state: state),
          },
          bottomNavigationBar: state.status == EditorStatus.ready
              ? _SubmitBar(state: state)
              : null,
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
    final bloc = context.read<BillEditorBloc>();
    final currency = _currency(state);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        FxSpacing.xxxl,
      ),
      children: [
        // 类型分段
        Opacity(
          opacity: state.lockBillType ? 0.6 : 1,
          child: IgnorePointer(
            ignoring: state.lockBillType,
            child: FxSegmented<FxBillType>(
              value: state.billType,
              onChanged: (t) => bloc.add(BillTypeChanged(t)),
              segments: FxBillType.selectable
                  .map((t) => FxSegment(t, t.localizedLabel(context)))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: FxSpacing.lg),

        // 标题（置于金额上方，便于先命名再记金额）
        _TitleCard(state: state),
        const SizedBox(height: FxSpacing.lg),

        // 金额区
        _AmountArea(state: state, currency: currency),
        const SizedBox(height: FxSpacing.lg),

        // 分类拆分（非转账）
        if (state.usesCategorySplit) ...[
          CategorySplitSection(state: state, currencyCode: currency),
          const SizedBox(height: FxSpacing.lg),
        ],

        // 明细卡
        FxCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (state.showSingleAccount)
                _AccountRow(state: state)
              else ...[
                _TransferAccountRow(state: state, isOut: true),
                _divider(context),
                _TransferAccountRow(state: state, isOut: false),
              ],
              if (state.showPayee) ...[
                _divider(context),
                _PayeeRow(state: state),
              ],
              if (state.showOrder) ...[
                _divider(context),
                _OrderRow(state: state),
              ],
              _divider(context),
              _TradeTimeRow(state: state),
              _divider(context),
              _TagsRow(state: state),
              _divider(context),
              _MembersRow(state: state),
            ],
          ),
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

        // 备注
        _RemarkCard(state: state),
        const SizedBox(height: FxSpacing.lg),

        // 开关
        _TogglesCard(state: state),
      ],
    );
  }
}

String _currency(BillEditorState state) {
  for (final a in state.options.accounts) {
    if (a.accountId == state.accountId && a.currencyCode != null) {
      return a.currencyCode!;
    }
  }
  return '';
}

Widget _divider(BuildContext context) =>
    Divider(height: 1, thickness: 1, color: FxPalette.of(context).border);

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
      return FxCard(
        child: AmountField(
          label: S.of(context).billEditorTransferAmount,
          value: state.transferAmount,
          currencyCode: currency,
          tint: tint,
          onChanged: (v) => bloc.add(TransferAmountChanged(v)),
        ),
      );
    }

    // 支出/收入/垫付/报销：大数字来自分类拆分总额（只读展示）。
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S
                .of(context)
                .billEditorAmountOf(state.billType.localizedLabel(context)),
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          Text(
            '${currency.isEmpty ? '' : '$currency '}${state.categoryTotal.toStringAsFixed(2)}',
            style: FxTypography.display.copyWith(color: tint),
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

// ---------------- 明细行 ----------------

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    final accounts = state.options.accounts.where((a) {
      if (state.isIncome) return a.canIncome;
      return a.canExpense;
    }).toList();

    return _PickerRow(
      label: S.of(context).billEditorAccount,
      value: state.accountName,
      placeholder: S.of(context).billEditorSelectAccountHint,
      onTap: () async {
        final picked = await showOptionPicker<AccountOption>(
          context,
          title: S.of(context).billEditorSelectAccount,
          options: accounts,
          labelOf: (a) => a.accountName ?? '',
          selectedId: state.accountId,
          idOf: (a) => a.accountId,
        );
        if (picked != null) {
          bloc.add(AccountChanged(picked.accountId, picked.accountName));
        }
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
        final picked = await showOptionPicker<AccountOption>(
          context,
          title: isOut
              ? S.of(context).billEditorSelectTransferOut
              : S.of(context).billEditorSelectTransferIn,
          options: accounts,
          labelOf: (a) => a.accountName ?? '',
          selectedId: selectedId,
          idOf: (a) => a.accountId,
        );
        if (picked != null) {
          if (isOut) {
            bloc.add(AccountChanged(picked.accountId, picked.accountName));
          } else {
            bloc.add(ToAccountChanged(picked.accountId, picked.accountName));
          }
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
      if (state.isIncome) return p.canIncome;
      return p.canExpense;
    }).toList();

    return _PickerRow(
      label: S.of(context).billEditorPayee,
      value: state.payeeName,
      placeholder: S.of(context).billEditorOptional,
      onTap: () async {
        final picked = await showOptionPicker<PayeeOption>(
          context,
          title: S.of(context).billEditorSelectPayee,
          options: payees,
          labelOf: (p) => p.payeeName ?? '',
          selectedId: state.payeeId,
          idOf: (p) => p.payeeId,
          allowClear: true,
        );
        bloc.add(PayeeChanged(picked?.payeeId, picked?.payeeName));
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
      onTap: () async {
        final picked = await showOptionPicker<OrderOption>(
          context,
          title: S.of(context).billEditorSelectOrder,
          options: state.options.orders,
          labelOf: (o) => [
            o.title,
            o.typeDesc,
          ].where((s) => s != null && s.isNotEmpty).join(' · '),
          selectedId: state.orderId,
          idOf: (o) => o.orderId,
        );
        if (picked != null) {
          bloc.add(OrderChanged(picked.orderId, picked.title));
        }
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
        final picked = await showFxDateTimePicker(
          context,
          initial: state.tradeTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          title: S.of(context).billEditorTradeTime,
        );
        if (picked != null) {
          bloc.add(TradeTimeChanged(picked));
        }
      },
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.state});
  final BillEditorState state;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final bloc = context.read<BillEditorBloc>();
    // 按当前账单类型过滤标签树：保留可用节点及其祖先，维持树形层级。
    bool usable(TagNode t) {
      if (state.isTransfer) return t.canTransfer;
      if (state.isIncome) return t.canIncome;
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

    return InkWell(
      onTap: () async {
        final result = await FxTreePicker.show<TagNode>(
          context,
          roots: roots,
          childrenOf: (t) => t.children,
          labelOf: (t) => t.tagName ?? '',
          idOf: (t) => t.tagId,
          initialSelected: state.tagIds.map((e) => e as Object).toSet(),
          multiSelect: true,
          initiallyCollapsed: true,
          title: S.of(context).billEditorSelectTags,
        );
        if (result != null) {
          bloc.add(
            TagsChanged(
              result.map((t) => t.tagId!).toList(),
              result.map((t) => t.tagName ?? '').toList(),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.lg,
          vertical: FxSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(
                S.of(context).billEditorTags,
                style: FxTypography.label.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: state.tagNames.isEmpty
                  ? Text(
                      S.of(context).billEditorAddTags,
                      style: FxTypography.body.copyWith(
                        color: palette.textTertiary,
                      ),
                    )
                  : Wrap(
                      spacing: FxSpacing.sm,
                      runSpacing: FxSpacing.sm,
                      children: state.tagNames
                          .map((n) => FxTagChip(label: n, selected: true))
                          .toList(),
                    ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.textTertiary),
          ],
        ),
      ),
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
        final result = await showMultiSelect<MemberOption>(
          context,
          title: S.of(context).billEditorSelectMembers,
          options: members,
          labelOf: (m) => m.memberName ?? '',
          idOf: (m) => m.memberId!,
          selectedIds: state.memberIds,
        );
        if (result != null) {
          bloc.add(
            MembersChanged(
              result.map((m) => m.memberId!).toList(),
              result.map((m) => m.memberName ?? '').toList(),
            ),
          );
        }
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hasValue = value != null && value!.isNotEmpty;
    final placeholderText = placeholder ?? S.of(context).commonPleaseSelect;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.lg,
          vertical: FxSpacing.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Row(
                children: [
                  Text(
                    label,
                    style: FxTypography.label.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  if (required)
                    Text(
                      ' *',
                      style: FxTypography.label.copyWith(color: palette.danger),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                hasValue ? value! : placeholderText,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FxTypography.body.copyWith(
                  color: hasValue ? palette.textPrimary : palette.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: FxSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: palette.textTertiary),
          ],
        ),
      ),
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
        onAdd: () async {
          try {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.any,
            );
            if (result == null || !context.mounted) return;
            final files = result.paths
                .whereType<String>()
                .map(File.new)
                .where((file) => file.existsSync())
                .toList();
            if (files.isNotEmpty) {
              bloc.add(AttachmentsAdded(files));
            }
          } on Object {
            if (context.mounted) {
              FxFeedback.error(
                context,
                message: S.of(context).profileSaveFailedRetry,
              );
            }
          }
        },
      ),
    );
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
    return FxCard(
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
              hintText: widget.state.firstCategoryName.isEmpty
                  ? S.of(context).billEditorTitleHint
                  : S
                        .of(context)
                        .billEditorTitleDefault(widget.state.firstCategoryName),
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
    return FxCard(
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
            onChanged: (v) => bloc.add(ConfirmToggled(v)),
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
            value: state.include,
            onChanged: (v) => bloc.add(IncludeToggled(v)),
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
    return Container(
      color: FxPalette.of(context).surface,
      padding: EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        FxSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: FxButton(
        label: state.mode == 'edit'
            ? S.of(context).billEditorSaveEdit
            : S.of(context).billEditorSaveNew,
        expand: true,
        loading: submitting,
        onPressed: submitting
            ? null
            : () => bloc.add(const BillEditorSubmitted()),
      ),
    );
  }
}
