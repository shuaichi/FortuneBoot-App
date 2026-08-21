import 'package:flutter/material.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/bill_attachment_preview.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 附件缩略图网格：图片缩略图（可删）+ 添加按钮。
class AttachmentGrid extends StatelessWidget {
  const AttachmentGrid({
    super.key,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    this.enabled = true,
  });

  final List<BillAttachment> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool enabled;

  static const double _tile = 76;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).billEditorAttachments,
              style: FxTypography.label.copyWith(
                color: FxPalette.of(context).textSecondary,
              ),
            ),
            if (files.isNotEmpty)
              Text(
                S.of(context).billEditorSelectedCount(files.length),
                style: FxTypography.caption.copyWith(
                  color: FxPalette.of(context).textTertiary,
                ),
              ),
          ],
        ),
        const SizedBox(height: FxSpacing.md),
        Wrap(
          spacing: FxSpacing.sm,
          runSpacing: FxSpacing.sm,
          children: [
            for (int i = 0; i < files.length; i++)
              _Thumb(
                attachment: files[i],
                index: i,
                enabled: enabled,
                onRemove: () => onRemove(i),
              ),
            _AddTile(onTap: onAdd, enabled: enabled),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.attachment,
    required this.index,
    required this.enabled,
    required this.onRemove,
  });
  final BillAttachment attachment;
  final int index;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final fileName = attachment.name;
    return SizedBox(
      width: AttachmentGrid._tile,
      height: AttachmentGrid._tile,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: FxRadius.tileBorder,
            child: buildBillAttachmentPreview(
              attachment: attachment,
              size: AttachmentGrid._tile,
              fileName: fileName,
              fallback: _FileTile(fileName: fileName, palette: palette),
            ),
          ),
          Positioned(
            top: -16,
            right: -16,
            child: FxIconButton(
              icon: Icons.close_rounded,
              tooltip: '${S.of(context).billEditorAttachments} ${index + 1}',
              color: palette.danger,
              onPressed: enabled ? onRemove : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.fileName, required this.palette});

  final String fileName;
  final FxPalette palette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fileName,
      child: Container(
        width: AttachmentGrid._tile,
        height: AttachmentGrid._tile,
        color: palette.surfaceMuted,
        padding: const EdgeInsets.all(FxSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file_rounded, color: palette.textTertiary),
            const SizedBox(height: FxSpacing.xs),
            Text(
              fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, required this.enabled});
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      label: S.of(context).billEditorAddAttachment,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: FxRadius.tileBorder,
        child: Container(
          width: AttachmentGrid._tile,
          height: AttachmentGrid._tile,
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: FxRadius.tileBorder,
            border: Border.all(color: palette.border),
          ),
          child: Tooltip(
            message: S.of(context).billEditorAddAttachment,
            child: Icon(Icons.add_rounded, color: palette.textTertiary),
          ),
        ),
      ),
    );
  }
}
