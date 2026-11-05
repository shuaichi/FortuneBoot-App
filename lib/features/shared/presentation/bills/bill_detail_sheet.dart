import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/icon/fx_icon_badge.dart';
import 'package:fortuneboot/core/icon/smart_category_engine.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_attachment_card.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_permissions.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_flow_amount.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 账单详情内容（放入 FxSheet.show 的 child）。
/// 通过回调把编辑/删除/确认切换交回页面，避免直接依赖 Navigator / Bloc 派发时机。
class BillDetailSheet extends StatefulWidget {
  final FortuneBillVo bill;
  final BillService service;

  const BillDetailSheet({super.key, required this.bill, required this.service});

  @override
  State<BillDetailSheet> createState() => _BillDetailSheetState();
}

class _BillDetailSheetState extends State<BillDetailSheet> {
  late Future<List<BillFileVo>> _filesFuture;

  FortuneBillVo get _bill => widget.bill;

  @override
  void initState() {
    super.initState();
    _filesFuture = _bill.hasFile && _bill.billId != null
        ? widget.service.getFiles(_bill.billId!)
        : Future.value(const <BillFileVo>[]);
  }

  BillIconInput get _iconInput => BillIconInput(
    billType: _bill.billType,
    title: _bill.title,
    payeeName: _bill.payeeName,
    remark: _bill.remark,
    accountName: _bill.accountName,
    categoryNames: _bill.categoryNamesByAmount,
    tagNames: _bill.tagList
        .map((t) => t.tagName ?? '')
        .where((s) => s.isNotEmpty)
        .toList(),
    toAccountId: _bill.toAccountId,
  );

  bool get _isTransfer => _bill.billType == FxBillType.transfer.value;

  String _titleOf(BuildContext context) {
    final t = _bill.title;
    if (t != null && t.isNotEmpty) return t;
    final cat = _bill.primaryCategoryName;
    if (cat.isNotEmpty) return cat;
    return FxBillType.fromValue(_bill.billType)?.localizedLabel(context) ??
        S.of(context).billTypeFallback;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: FxSpacing.lg,
        right: FxSpacing.lg,
        bottom: FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocSelector<PreferencesCubit, PreferencesState, bool>(
            selector: (state) => state.dashboard.hideAmounts,
            builder: (context, hideAmounts) => _header(context, hideAmounts),
          ),
          const SizedBox(height: FxSpacing.lg),
          Divider(height: 1, color: palette.border),
          const SizedBox(height: FxSpacing.md),
          BlocSelector<PreferencesCubit, PreferencesState, bool>(
            selector: (state) => state.dashboard.hideAmounts,
            builder: (context, hideAmounts) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _infoRows(context, hideAmounts),
            ),
          ),
          const SizedBox(height: FxSpacing.lg),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, bool hideAmounts) {
    final catLine = <String>[];
    if (_bill.primaryCategoryName.isNotEmpty) {
      catLine.add(_bill.primaryCategoryName);
    }
    if (_bill.tradeTime != null) {
      catLine.add(
        DateFormat.yMMMd(
          Localizations.localeOf(context).toString(),
        ).add_Hm().format(_bill.tradeTime!),
      );
    }
    if (!_isTransfer &&
        _bill.accountName != null &&
        _bill.accountName!.isNotEmpty) {
      catLine.add(_bill.accountName!);
    }

    final amount = BillFlowAmount(bill: _bill, masked: hideAmounts);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.2;
        final heading = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxIconBadge.forBill(_iconInput, size: 44),
            const SizedBox(width: FxSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleOf(context),
                    style: FxTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (catLine.isNotEmpty) ...[
                    const SizedBox(height: FxSpacing.xs),
                    Text(
                      catLine.join(' · '),
                      style: FxTypography.caption.copyWith(
                        color: FxPalette.of(context).textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading,
              const SizedBox(height: FxSpacing.lg),
              if (_bill.hasExtrasAdjustment)
                Text(
                  S.of(context).billsSettledAmount,
                  style: FxTypography.label.copyWith(
                    color: FxPalette.of(context).textSecondary,
                  ),
                ),
              Align(alignment: AlignmentDirectional.centerEnd, child: amount),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: FxSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_bill.hasExtrasAdjustment)
                  Text(
                    S.of(context).billsSettledAmount,
                    style: FxTypography.label.copyWith(
                      color: FxPalette.of(context).textSecondary,
                    ),
                  ),
                amount,
              ],
            ),
          ],
        );
      },
    );
  }

  List<Widget> _infoRows(BuildContext context, bool hideAmounts) {
    final rows = <Widget>[];

    if (_bill.hasExtrasAdjustment) {
      rows.add(_sectionLabel(S.of(context).billsAmountBreakdown));
      rows.add(
        _kv(
          S.of(context).billsOriginalAmount,
          trailing: FxMoneyText(
            amount: _bill.displayAmount,
            currencyCode: _bill.currencyCode,
            masked: hideAmounts,
          ),
        ),
      );
      if (_bill.feeTotal > 0) {
        rows.add(
          _kv(
            S.of(context).billsFee,
            trailing: FxMoneyText(
              amount: _bill.feeTotal,
              currencyCode: _bill.currencyCode,
              masked: hideAmounts,
            ),
          ),
        );
      }
      if (_bill.discountTotal > 0) {
        rows.add(
          _kv(
            S.of(context).billsDiscount,
            trailing: FxMoneyText(
              amount: _bill.discountTotal,
              currencyCode: _bill.currencyCode,
              masked: hideAmounts,
            ),
          ),
        );
      }
    }

    // 多分类拆分
    if (_bill.categoryAmountPair.length > 1) {
      rows.add(_sectionLabel(S.of(context).billsCategoryDetail));
      for (final c in _bill.categoryAmountPair) {
        rows.add(
          _kv(
            c.categoryName ?? S.of(context).billsUncategorized,
            trailing: FxMoneyText(
              amount: c.amount,
              currencyCode: _bill.currencyCode,
              billType: _bill.billType,
              fontSize: 15,
              masked: hideAmounts,
            ),
          ),
        );
      }
    }

    // 转账双账户
    if (_isTransfer) {
      rows.add(
        _kv(
          S.of(context).billsTransferOutAccount,
          value: _bill.accountName ?? '-',
        ),
      );
      rows.add(
        _kv(
          S.of(context).billsTransferInAccount,
          value: _bill.toAccountName ?? '-',
        ),
      );
      if (_bill.convertedAmount != null) {
        rows.add(
          _kv(
            S.of(context).billsReceivedAmount,
            trailing: FxMoneyText(
              amount: _bill.convertedAmount!,
              currencyCode: _bill.toCurrencyCode ?? _bill.currencyCode,
              fontSize: 15,
              masked: hideAmounts,
            ),
          ),
        );
      }
    }

    if (_bill.payeeName != null && _bill.payeeName!.isNotEmpty) {
      rows.add(_kv(S.of(context).billsPayee, value: _bill.payeeName));
    }

    final tags = _bill.tagList
        .map((t) => t.tagName ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    if (tags.isNotEmpty) {
      rows.add(
        _kvWidget(
          S.of(context).billsTags,
          Wrap(
            alignment: WrapAlignment.end,
            spacing: FxSpacing.xs,
            runSpacing: FxSpacing.xs,
            children: [...tags.map((tag) => FxTagChip(label: tag))],
          ),
        ),
      );
    }

    final members = _bill.memberList
        .map((m) => m.memberName ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    if (members.isNotEmpty) {
      rows.add(_kv(S.of(context).billsMembers, value: members.join('、')));
    }

    // 附加费用
    if (_bill.extras.isNotEmpty) {
      rows.add(_sectionLabel(S.of(context).billsExtras));
      for (final e in _bill.extras) {
        rows.add(
          _kv(
            _extraLabel(context, e),
            trailing: FxMoneyText(
              amount: e.amount,
              currencyCode: _bill.currencyCode,
              fontSize: 15,
              masked: hideAmounts,
            ),
          ),
        );
        final metadata = [
          if (e.categoryId != null)
            '${S.of(context).billsExtraCategory} #${e.categoryId!}',
          if (e.remark?.isNotEmpty == true) e.remark!,
        ];
        if (metadata.isNotEmpty) {
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: FxSpacing.sm),
              child: Text(
                metadata.join(' · '),
                style: FxTypography.body.copyWith(
                  color: FxPalette.of(context).textSecondary,
                ),
              ),
            ),
          );
        }
      }
    }

    if (_bill.remark != null && _bill.remark!.isNotEmpty) {
      rows.add(_sectionLabel(S.of(context).billsRemark));
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: FxSpacing.md),
          child: Text(_bill.remark!, style: FxTypography.body),
        ),
      );
    }

    rows.add(_sectionLabel(S.of(context).billsRecordStatus));
    final component = _bill.orderComponent;
    if (component != null) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: FxSpacing.sm),
          child: Text(
            _componentLabel(context, component),
            style: FxTypography.body,
          ),
        ),
      );
    }
    rows.add(
      Wrap(
        spacing: FxSpacing.sm,
        runSpacing: FxSpacing.sm,
        children: [
          Text(
            _bill.include
                ? S.of(context).billsFilterIncluded
                : S.of(context).billsFilterExcluded,
            style: FxTypography.body,
          ),
          Text(
            _bill.confirm
                ? S.of(context).billsFilterConfirmed
                : S.of(context).billsPendingConfirm,
            style: FxTypography.body,
          ),
        ],
      ),
    );
    if (_bill.readOnlyReason?.isNotEmpty == true) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: FxSpacing.sm),
          child: Text(
            _bill.readOnlyReason!,
            style: FxTypography.body.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ),
      );
    }

    if (_bill.hasFile) {
      rows.add(_sectionLabel(S.of(context).billsAttachments));
      rows.add(_filesView());
    }

    return rows;
  }

  String _componentLabel(
    BuildContext context,
    FinanceOrderComponent component,
  ) {
    if (component == FinanceOrderComponent.interest) {
      return S.of(context).ordersComponentInterest;
    }
    if (component == FinanceOrderComponent.fee) {
      return S.of(context).ordersComponentFee;
    }
    if (component == FinanceOrderComponent.writeOff) {
      return S.of(context).ordersComponentWriteOff;
    }
    return S.of(context).ordersComponentPrincipal;
  }

  String _extraLabel(BuildContext context, BillExtra e) {
    final type = switch (e.extraType) {
      1 => S.of(context).billsFee,
      2 => S.of(context).billsDiscount,
      _ => S.of(context).billsCharge,
    };
    final side = switch (e.accountSide) {
      1 => S.of(context).billsSideOut,
      2 => S.of(context).billsSideIn,
      _ => null,
    };
    return side == null ? type : S.of(context).billsExtraWithSide(type, side);
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: FxSpacing.sm, bottom: FxSpacing.xs),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  Widget _kv(String key, {String? value, Widget? trailing}) {
    return _kvWidget(
      key,
      trailing ??
          Text(
            value ?? '-',
            style: FxTypography.bodyStrong,
            textAlign: TextAlign.end,
          ),
    );
  }

  Widget _kvWidget(String key, Widget trailing) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final label = Text(
      key,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    );
    if (textScale > 1.2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            const SizedBox(height: FxSpacing.xs),
            Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }

  void _retryFiles() {
    final billId = _bill.billId;
    if (billId == null) return;
    setState(() => _filesFuture = widget.service.getFiles(billId));
  }

  Widget _filesView() {
    return FutureBuilder<List<BillFileVo>>(
      future: _filesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: FxSpacing.md),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).dashboardLoadFailed,
                  style: FxTypography.caption.copyWith(
                    color: FxPalette.of(context).textTertiary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _retryFiles,
                child: Text(S.of(context).commonRetry),
              ),
            ],
          );
        }
        final files = snapshot.data ?? const <BillFileVo>[];
        if (files.isEmpty) {
          return Text(
            S.of(context).billsNoAttachments,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
          );
        }
        return Wrap(
          spacing: FxSpacing.sm,
          runSpacing: FxSpacing.sm,
          children: files.map((f) => _fileThumb(context, f)).toList(),
        );
      },
    );
  }

  Widget _fileThumb(BuildContext context, BillFileVo file) {
    final bytes = _decode(file.fileData);
    final isImage = (file.contentType ?? '').startsWith('image/');
    if (isImage && bytes != null) {
      return Semantics(
        button: true,
        label: file.originalName ?? S.of(context).billsAttachments,
        child: GestureDetector(
          key: const ValueKey('bill-attachment-image'),
          onTap: () => _previewImage(bytes, file.originalName),
          child: ClipRRect(
            borderRadius: FxRadius.tileBorder,
            child: Image.memory(
              bytes,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fileFallback(file),
            ),
          ),
        ),
      );
    }
    return _fileCard(file);
  }

  Widget _fileCard(BillFileVo file) => BillAttachmentCard(file: file);

  Widget _fileFallback(BillFileVo file) {
    final palette = FxPalette.of(context);
    return Semantics(
      label: file.originalName ?? S.of(context).billsAttachments,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: FxRadius.tileBorder,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.insert_drive_file_rounded,
          color: palette.textTertiary,
        ),
      ),
    );
  }

  Uint8List? _decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final normalized = data.contains(',') ? data.split(',').last : data;
      return base64Decode(normalized);
    } on FormatException {
      return null;
    }
  }

  void _previewImage(Uint8List bytes, String? name) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(FxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Semantics(
                image: true,
                label: name ?? S.of(context).billsAttachments,
                child: InteractiveViewer(
                  child: Image.memory(
                    bytes,
                    errorBuilder: (_, _, _) =>
                        _fileFallback(BillFileVo(originalName: name)),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(FxSpacing.sm),
                child: FilledButton(
                  key: const ValueKey('bill-image-preview-close'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(S.of(context).billsClose),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillDetailActions extends StatelessWidget {
  const BillDetailActions({
    super.key,
    required this.bill,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
    required this.onConfirmToggle,
    this.confirmBusy = false,
    this.deleteBusy = false,
  });

  final FortuneBillVo bill;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onConfirmToggle;
  final bool confirmBusy;
  final bool deleteBusy;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final permissions = BillDetailPermissions.of(bill);
    final canEditOrCopy = permissions.canEdit || permissions.canCopy;
    if (permissions.isReadOnly) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.md,
          FxSpacing.md,
          FxSpacing.lg,
        ),
        child: Row(
          children: [
            if (canEditOrCopy)
              Expanded(
                child: FxButton(
                  label: S.of(context).billsEdit,
                  icon: Icons.edit_outlined,
                  onPressed: confirmBusy || deleteBusy ? null : onEdit,
                ),
              ),
            if (canEditOrCopy) const SizedBox(width: FxSpacing.sm),
            Expanded(
              child: FxButton.tonal(
                label: confirmBusy
                    ? S.of(context).billsConfirming
                    : bill.confirm
                    ? S.of(context).billsUnconfirm
                    : S.of(context).confirm,
                onPressed: confirmBusy || deleteBusy
                    ? null
                    : () => onConfirmToggle(!bill.confirm),
              ),
            ),
            const SizedBox(width: FxSpacing.xs),
            FxIconButton(
              key: const ValueKey('bill-detail-more'),
              icon: Icons.more_horiz_rounded,
              tooltip: '更多操作',
              onPressed: confirmBusy || deleteBusy
                  ? null
                  : () => _showMoreActions(context, permissions),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreActions(
    BuildContext context,
    BillDetailPermissions permissions,
  ) {
    FxSheet.show<void>(
      context,
      title: S.of(context).billsDetailTitle,
      child: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (permissions.canCopy)
              ListTile(
                key: const ValueKey('bill-detail-copy'),
                leading: const Icon(Icons.copy_outlined),
                title: Text(S.of(context).billsCopy),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onCopy();
                },
              ),
            if (permissions.canDelete)
              ListTile(
                key: const ValueKey('bill-detail-delete'),
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: FxPalette.of(context).danger,
                ),
                title: Text(
                  S.of(context).billsDelete,
                  style: TextStyle(color: FxPalette.of(context).danger),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }
}
