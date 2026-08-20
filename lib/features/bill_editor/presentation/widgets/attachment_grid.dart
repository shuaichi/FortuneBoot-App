import 'dart:io';

import 'package:flutter/material.dart';
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

  final List<File> files;
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
                file: files[i],
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
    required this.file,
    required this.index,
    required this.enabled,
    required this.onRemove,
  });
  final File file;
  final int index;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return SizedBox(
      width: AttachmentGrid._tile,
      height: AttachmentGrid._tile,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: FxRadius.tileBorder,
            child: Image.file(
              file,
              width: AttachmentGrid._tile,
              height: AttachmentGrid._tile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: AttachmentGrid._tile,
                height: AttachmentGrid._tile,
                color: palette.surfaceMuted,
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  color: palette.textTertiary,
                ),
              ),
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
      label: S.of(context).billEditorAttachments,
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
            message: S.of(context).billEditorAttachments,
            child: Icon(
              Icons.add_a_photo_outlined,
              color: palette.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
