import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

/// BillEditor 记账表单页。
class BillEditorPage extends StatelessWidget {
  const BillEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillEditorBloc, BillEditorState>(
      listenWhen: (a, b) => a.submitStatus != b.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          BillMutations.bump();
          Navigator.of(context).pop(true);
        } else if (state.submitStatus == SubmitStatus.failure &&
            state.submitError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.submitError!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: FxColors.canvas,
          appBar: AppBar(
            backgroundColor: FxColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            title: Text(
              state.mode == 'edit' ? '编辑账单' : '记一笔',
              style: FxTypography.title,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: FxColors.textPrimary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: switch (state.status) {
            EditorStatus.loading => FxStateView.loading(),
            EditorStatus.error => FxStateView.error(
                message: state.loadError,
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
                  .map((t) => FxSegment(t, t.label))
                  .toList(),
            ),
          ),
        ),
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
                _divider(),
                _TransferAccountRow(state: state, isOut: false),
              ],
              if (state.showPayee) ...[_divider(), _PayeeRow(state: state)],
              if (state.showOrder) ...[_divider(), _OrderRow(state: state)],
              _divider(),
              _TradeTimeRow(state: state),
              _divider(),
              _TagsRow(state: state),
              _divider(),
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

        // 标题 + 备注
        _TitleRemarkCard(state: state),
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

Widget _divider() => const Divider(height: 1, thickness: 1, color: FxColors.border);

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
          label: '转账金额',
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
          Text('${state.billType.label}金额', style: FxTypography.label),
          const SizedBox(height: FxSpacing.sm),
          Text(
            '${currency.isEmpty ? '' : '$currency '}${state.categoryTotal.toStringAsFixed(2)}',
            style: FxTypography.display.copyWith(color: tint),
          ),
          const SizedBox(height: FxSpacing.xs),
          const Text('金额按下方分类拆分累加', style: FxTypography.caption),
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
      label: '账户',
      value: state.accountName,
      placeholder: '请选择账户',
      onTap: () async {
        final picked = await showOptionPicker<AccountOption>(
          context,
          title: '选择账户',
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
      label: isOut ? '转出账户' : '转入账户',
      value: value,
      placeholder: isOut ? '请选择转出账户' : '请选择转入账户',
      onTap: () async {
        final picked = await showOptionPicker<AccountOption>(
          context,
          title: isOut ? '选择转出账户' : '选择转入账户',
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
      label: '交易对象',
      value: state.payeeName,
      placeholder: '可选',
      onTap: () async {
        final picked = await showOptionPicker<PayeeOption>(
          context,
          title: '选择交易对象',
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
      label: '关联单据',
      value: state.orderTitle,
      placeholder: '必选',
      required: true,
      onTap: () async {
        final picked = await showOptionPicker<OrderOption>(
          context,
          title: '选择使用中单据',
          options: state.options.orders,
          labelOf: (o) => [o.title, o.typeDesc]
              .where((s) => s != null && s.isNotEmpty)
              .join(' · '),
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
      label: '时间',
      value: text,
      onTap: () async {
        final picked = await showOmniDateTimePicker(
          context: context,
          initialDate: state.tradeTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          is24HourMode: true,
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
    final bloc = context.read<BillEditorBloc>();
    // 按类型过滤可用标签，扁平展开。
    final flat = <TagNode>[];
    for (final root in state.options.tags) {
      flat.addAll(root.flattenAll());
    }
    final usable = flat.where((t) {
      if (t.tagId == null) return false;
      if (state.isTransfer) return t.canTransfer;
      if (state.isIncome) return t.canIncome;
      return t.canExpense;
    }).toList();

    return InkWell(
      onTap: () async {
        final result = await showMultiSelect<TagNode>(
          context,
          title: '选择标签',
          options: usable,
          labelOf: (t) => t.tagName ?? '',
          idOf: (t) => t.tagId!,
          selectedIds: state.tagIds,
        );
        if (result != null) {
          bloc.add(TagsChanged(
            result.map((t) => t.tagId!).toList(),
            result.map((t) => t.tagName ?? '').toList(),
          ));
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
            const SizedBox(
              width: 72,
              child: Text('标签', style: FxTypography.label),
            ),
            Expanded(
              child: state.tagNames.isEmpty
                  ? Text('添加标签', style: FxTypography.body.copyWith(
                      color: FxColors.textTertiary))
                  : Wrap(
                      spacing: FxSpacing.sm,
                      runSpacing: FxSpacing.sm,
                      children: state.tagNames
                          .map((n) => FxTagChip(label: n, selected: true))
                          .toList(),
                    ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: FxColors.textTertiary),
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
    final members =
        state.options.members.where((m) => m.memberId != null).toList();
    return _PickerRow(
      label: '成员',
      value: state.memberNames.isEmpty ? null : state.memberNames.join('、'),
      placeholder: '可选',
      onTap: () async {
        final result = await showMultiSelect<MemberOption>(
          context,
          title: '选择成员',
          options: members,
          labelOf: (m) => m.memberName ?? '',
          idOf: (m) => m.memberId!,
          selectedIds: state.memberIds,
        );
        if (result != null) {
          bloc.add(MembersChanged(
            result.map((m) => m.memberId!).toList(),
            result.map((m) => m.memberName ?? '').toList(),
          ));
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
    this.placeholder = '请选择',
    this.required = false,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final bool required;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
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
                  Text(label, style: FxTypography.label),
                  if (required)
                    Text(' *',
                        style: FxTypography.label
                            .copyWith(color: FxColors.danger)),
                ],
              ),
            ),
            Expanded(
              child: Text(
                hasValue ? value! : placeholder,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FxTypography.body.copyWith(
                  color:
                      hasValue ? FxColors.textPrimary : FxColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: FxSpacing.sm),
            const Icon(Icons.chevron_right_rounded,
                color: FxColors.textTertiary),
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
        onRemove: (i) => bloc.add(AttachmentRemoved(i)),
        onAdd: () async {
          final result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.image,
          );
          if (result == null) return;
          final files = result.paths
              .whereType<String>()
              .map((p) => File(p))
              .toList();
          if (files.isNotEmpty) {
            bloc.add(AttachmentsAdded(files));
          }
        },
      ),
    );
  }
}

// ---------------- 标题 + 备注 ----------------

class _TitleRemarkCard extends StatefulWidget {
  const _TitleRemarkCard({required this.state});
  final BillEditorState state;

  @override
  State<_TitleRemarkCard> createState() => _TitleRemarkCardState();
}

class _TitleRemarkCardState extends State<_TitleRemarkCard> {
  late final TextEditingController _title;
  late final TextEditingController _remark;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.state.title);
    _remark = TextEditingController(text: widget.state.remark);
  }

  @override
  void dispose() {
    _title.dispose();
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('标题', style: FxTypography.label),
          const SizedBox(height: FxSpacing.xs),
          TextField(
            controller: _title,
            style: FxTypography.body,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.state.firstCategoryName.isEmpty
                  ? '请输入标题'
                  : '默认「${widget.state.firstCategoryName}」',
              hintStyle:
                  FxTypography.body.copyWith(color: FxColors.textTertiary),
            ),
            onChanged: (v) => bloc.add(TitleChanged(v)),
          ),
          const Divider(height: FxSpacing.lg, color: FxColors.border),
          const Text('备注', style: FxTypography.label),
          const SizedBox(height: FxSpacing.xs),
          TextField(
            controller: _remark,
            style: FxTypography.body,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: '添加备注…',
              hintStyle:
                  FxTypography.body.copyWith(color: FxColors.textTertiary),
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
    final bloc = context.read<BillEditorBloc>();
    return FxCard(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeColor: FxColors.primary,
            title: const Text('已确认', style: FxTypography.bodyStrong),
            subtitle: const Text('未确认账单不计入余额', style: FxTypography.caption),
            value: state.confirm,
            onChanged: (v) => bloc.add(ConfirmToggled(v)),
          ),
          const Divider(height: 1, color: FxColors.border),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeColor: FxColors.primary,
            title: const Text('计入统计', style: FxTypography.bodyStrong),
            subtitle: const Text('关闭后不参与收支统计', style: FxTypography.caption),
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
      color: FxColors.surface,
      padding: EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        FxSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: FxButton(
        label: state.mode == 'edit' ? '保存修改' : '保存账单',
        expand: true,
        loading: submitting,
        onPressed: submitting
            ? null
            : () => bloc.add(const BillEditorSubmitted()),
      ),
    );
  }
}
