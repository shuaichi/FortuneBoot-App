import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 附件缩略图网格：图片缩略图（可删）+ 添加按钮。
class AttachmentGrid extends StatelessWidget {
  const AttachmentGrid({
    super.key,
    required this.files,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  static const double _tile = 76;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('附件', style: FxTypography.label),
            if (files.isNotEmpty)
              Text('已选 ${files.length} 张', style: FxTypography.caption),
          ],
        ),
        const SizedBox(height: FxSpacing.md),
        Wrap(
          spacing: FxSpacing.sm,
          runSpacing: FxSpacing.sm,
          children: [
            for (int i = 0; i < files.length; i++)
              _Thumb(file: files[i], onRemove: () => onRemove(i)),
            _AddTile(onTap: onAdd),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.file, required this.onRemove});
  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
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
                color: FxColors.surfaceMuted,
                child: const Icon(Icons.insert_drive_file_rounded,
                    color: FxColors.textTertiary),
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: FxColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: FxRadius.tileBorder,
      child: Container(
        width: AttachmentGrid._tile,
        height: AttachmentGrid._tile,
        decoration: BoxDecoration(
          color: FxColors.surfaceMuted,
          borderRadius: FxRadius.tileBorder,
          border: Border.all(color: FxColors.border),
        ),
        child: const Icon(Icons.add_a_photo_outlined,
            color: FxColors.textTertiary),
      ),
    );
  }
}
