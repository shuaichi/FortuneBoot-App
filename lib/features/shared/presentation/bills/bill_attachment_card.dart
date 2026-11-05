import 'package:flutter/material.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_reader.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 非图片附件的名称、类型与真实打开/保存动作。
class BillAttachmentCard extends StatefulWidget {
  const BillAttachmentCard({
    super.key,
    required this.file,
    this.reader = const BillAttachmentReader(),
  });

  final BillFileVo file;
  final BillAttachmentReader reader;

  @override
  State<BillAttachmentCard> createState() => _BillAttachmentCardState();
}

class _BillAttachmentCardState extends State<BillAttachmentCard> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final name = widget.file.originalName ?? S.of(context).billsAttachments;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description_outlined, color: palette.textSecondary),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: FxTypography.bodyStrong),
                    const SizedBox(height: FxSpacing.xs),
                    Text(
                      _typeLabel(context),
                      style: FxTypography.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: [
              FxButton.text(
                label: _busy
                    ? S.of(context).billsAttachmentWorking
                    : S.of(context).billsAttachmentOpen,
                onPressed: _busy ? null : () => _run(open: true),
              ),
              FxButton.text(
                label: S.of(context).billsAttachmentSave,
                onPressed: _busy ? null : () => _run(open: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context) {
    final type = widget.file.contentType;
    if (type == null || type.isEmpty) {
      return S.of(context).billsAttachmentUnknownType;
    }
    final subtype = type.split('/').last.toUpperCase();
    return '$subtype · ${S.of(context).billsAttachmentFile}';
  }

  Future<void> _run({required bool open}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = open
          ? await widget.reader.open(widget.file)
          : await widget.reader.save(widget.file);
      if (!mounted) return;
      final s = S.of(context);
      final message = switch (result.status) {
        BillAttachmentActionStatus.opened => s.billsAttachmentOpened,
        BillAttachmentActionStatus.saved =>
          '${s.billsAttachmentSaved}：${result.path ?? ''}',
        BillAttachmentActionStatus.downloadStarted =>
          s.billsAttachmentDownloadStarted,
        BillAttachmentActionStatus.unsupported => s.billsAttachmentUnsupported,
      };
      if (result.status == BillAttachmentActionStatus.unsupported) {
        FxFeedback.warning(context, message: message);
      } else {
        FxFeedback.success(context, message: message);
      }
    } on Object {
      if (mounted) {
        FxFeedback.error(
          context,
          message: S.of(context).billsAttachmentActionFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
