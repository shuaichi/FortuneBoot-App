import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/icon/fx_icon_badge.dart';
import 'package:fortuneboot/core/icon/smart_category_engine.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:intl/intl.dart';

/// 账单详情内容（放入 FxSheet.show 的 child）。
/// 通过回调把编辑/删除/确认切换交回页面，避免直接依赖 Navigator / Bloc 派发时机。
class BillDetailSheet extends StatefulWidget {
  final FortuneBillVo bill;
  final BillService service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onConfirmToggle;

  const BillDetailSheet({
    super.key,
    required this.bill,
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onConfirmToggle,
  });

  static final DateFormat _dateTimeFormat = DateFormat('M月d日 HH:mm');

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

  String get _title {
    final t = _bill.title;
    if (t != null && t.isNotEmpty) return t;
    final cat = _bill.primaryCategoryName;
    if (cat.isNotEmpty) return cat;
    return FxBillType.fromValue(_bill.billType)?.label ?? '账单';
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: FxSpacing.lg,
        right: FxSpacing.lg,
        bottom: FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: FxSpacing.lg),
          Divider(height: 1, color: palette.border),
          const SizedBox(height: FxSpacing.md),
          ..._infoRows(context),
          const SizedBox(height: FxSpacing.lg),
          _actions(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final color = FxFinanceColors.of(context).forBillType(_bill.billType);
    final catLine = <String>[];
    if (_bill.primaryCategoryName.isNotEmpty) {
      catLine.add(_bill.primaryCategoryName);
    }
    if (_bill.tradeTime != null) {
      catLine.add(BillDetailSheet._dateTimeFormat.format(_bill.tradeTime!));
    }
    if (!_isTransfer &&
        _bill.accountName != null &&
        _bill.accountName!.isNotEmpty) {
      catLine.add(_bill.accountName!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxIconBadge.forBill(_iconInput, size: 48),
        const SizedBox(width: FxSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_title, style: FxTypography.titleLarge),
              if (catLine.isNotEmpty) ...[
                const SizedBox(height: FxSpacing.xs),
                Text(catLine.join(' · '), style: FxTypography.caption),
              ],
            ],
          ),
        ),
        const SizedBox(width: FxSpacing.sm),
        FxMoneyText(
          amount: _bill.displayAmount,
          currencyCode: _bill.currencyCode,
          billType: _bill.billType,
          showSign: true,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ],
    );
  }

  List<Widget> _infoRows(BuildContext context) {
    final rows = <Widget>[];

    // 多分类拆分
    if (_bill.categoryAmountPair.length > 1) {
      rows.add(_sectionLabel('分类明细'));
      for (final c in _bill.categoryAmountPair) {
        rows.add(
          _kv(
            c.categoryName ?? '未分类',
            trailing: FxMoneyText(
              amount: c.amount,
              currencyCode: _bill.currencyCode,
              billType: _bill.billType,
              fontSize: 14,
            ),
          ),
        );
      }
    }

    // 转账双账户
    if (_isTransfer) {
      rows.add(_kv('转出账户', value: _bill.accountName ?? '-'));
      rows.add(_kv('转入账户', value: _bill.toAccountName ?? '-'));
      if (_bill.convertedAmount != null) {
        rows.add(
          _kv(
            '到账金额',
            trailing: FxMoneyText(
              amount: _bill.convertedAmount!,
              currencyCode: _bill.toCurrencyCode ?? _bill.currencyCode,
              fontSize: 14,
            ),
          ),
        );
      }
    }

    if (_bill.payeeName != null && _bill.payeeName!.isNotEmpty) {
      rows.add(_kv('交易对象', value: _bill.payeeName));
    }

    final tags = _bill.tagList
        .map((t) => t.tagName ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    if (tags.isNotEmpty) {
      rows.add(
        _kvWidget(
          '标签',
          Wrap(
            alignment: WrapAlignment.end,
            spacing: FxSpacing.xs,
            runSpacing: FxSpacing.xs,
            children: tags.map((t) => FxTagChip(label: t)).toList(),
          ),
        ),
      );
    }

    final members = _bill.memberList
        .map((m) => m.memberName ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    if (members.isNotEmpty) {
      rows.add(_kv('成员', value: members.join('、')));
    }

    // 附加费用
    if (_bill.extras.isNotEmpty) {
      rows.add(_sectionLabel('附加费用'));
      for (final e in _bill.extras) {
        rows.add(
          _kv(
            _extraLabel(e),
            trailing: FxMoneyText(
              amount: e.amount,
              currencyCode: _bill.currencyCode,
              fontSize: 14,
            ),
          ),
        );
      }
    }

    if (_bill.remark != null && _bill.remark!.isNotEmpty) {
      rows.add(_kv('备注', value: _bill.remark));
    }

    if (_bill.hasFile) {
      rows.add(_sectionLabel('附件'));
      rows.add(_filesView());
    }

    return rows;
  }

  String _extraLabel(BillExtra e) {
    final type = switch (e.extraType) {
      1 => '手续费',
      2 => '优惠',
      _ => '费用',
    };
    final side = switch (e.accountSide) {
      1 => '转出',
      2 => '转入',
      _ => null,
    };
    return side == null ? type : '$type（$side）';
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: FxSpacing.sm, bottom: FxSpacing.xs),
    child: Text(text, style: FxTypography.label),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(key, style: FxTypography.label)),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
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
        final files = snapshot.data ?? const <BillFileVo>[];
        if (files.isEmpty) {
          return const Text('无附件', style: FxTypography.caption);
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
    final palette = FxPalette.of(context);
    final bytes = _decode(file.fileData);
    final isImage = (file.contentType ?? '').startsWith('image/');
    if (isImage && bytes != null) {
      return GestureDetector(
        onTap: () => _previewImage(bytes, file.originalName),
        child: ClipRRect(
          borderRadius: FxRadius.tileBorder,
          child: Image.memory(bytes, width: 72, height: 72, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.insert_drive_file_rounded, color: palette.textTertiary),
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
            Flexible(child: InteractiveViewer(child: Image.memory(bytes))),
            Padding(
              padding: const EdgeInsets.all(FxSpacing.sm),
              child: FxButton.text(
                label: '关闭',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FxButton.tonal(
            label: '编辑',
            icon: Icons.edit_rounded,
            onPressed: widget.onEdit,
          ),
        ),
        const SizedBox(width: FxSpacing.sm),
        Expanded(
          child: FxButton(
            label: _bill.confirm ? '取消确认' : '确认',
            variant: FxButtonVariant.text,
            icon: _bill.confirm
                ? Icons.remove_done_rounded
                : Icons.done_all_rounded,
            onPressed: () => widget.onConfirmToggle(!_bill.confirm),
          ),
        ),
        const SizedBox(width: FxSpacing.sm),
        Expanded(
          child: FxButton.critical(
            label: '删除',
            icon: Icons.delete_outline_rounded,
            onPressed: widget.onDelete,
          ),
        ),
      ],
    );
  }
}
