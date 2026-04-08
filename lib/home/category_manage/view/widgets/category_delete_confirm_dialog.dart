import 'package:flutter/material.dart';

class CategoryDeleteConfirmDialog extends StatelessWidget {
  const CategoryDeleteConfirmDialog({
    super.key,
    required this.categoryName,
    required this.onConfirm,
  });

  final String categoryName;
  final Future<void> Function() onConfirm;

  ButtonStyle _secondaryButtonStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ButtonStyle(
      minimumSize: const MaterialStatePropertyAll(Size(64, 44)),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      side: MaterialStatePropertyAll(BorderSide(color: cs.outlineVariant)),
      foregroundColor: MaterialStatePropertyAll(cs.onSurfaceVariant),
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.pressed)) {
          return cs.primary.withOpacity(0.08);
        }
        if (states.contains(MaterialState.hovered)) {
          return cs.primary.withOpacity(0.06);
        }
        if (states.contains(MaterialState.focused)) {
          return cs.primary.withOpacity(0.08);
        }
        return null;
      }),
    );
  }

  ButtonStyle _dangerButtonStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ButtonStyle(
      minimumSize: const MaterialStatePropertyAll(Size(64, 44)),
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      side: MaterialStatePropertyAll(BorderSide(color: cs.error)),
      foregroundColor: MaterialStatePropertyAll(cs.error),
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.pressed)) {
          return cs.error.withOpacity(0.12);
        }
        if (states.contains(MaterialState.hovered)) {
          return cs.error.withOpacity(0.08);
        }
        if (states.contains(MaterialState.focused)) {
          return cs.error.withOpacity(0.12);
        }
        return null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final horizontalPadding = w < 600 ? 16.0 : (w < 1024 ? 20.0 : 24.0);

        return AlertDialog(
          backgroundColor: cs.surface,
          surfaceTintColor: cs.surfaceTint,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant),
          ),
          title: Text('移入回收站', style: tt.titleMedium),
          content: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 320, maxWidth: 560, maxHeight: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Text(
                '将分类“$categoryName”移入回收站？其子分类也将一并处理。',
                style: tt.bodyMedium,
              ),
            ),
          ),
          actions: [
            Tooltip(
              message: '取消',
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: _secondaryButtonStyle(context),
                child: Text('取消', style: tt.labelLarge),
              ),
            ),
            Tooltip(
              message: '确认移入回收站',
              child: OutlinedButton(
                onPressed: () async {
                  await onConfirm();
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context, true);
                  }
                },
                style: _dangerButtonStyle(context),
                child: Semantics(
                  button: true,
                  label: '确认移入回收站',
                  child: Text('确认', style: tt.labelLarge),
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        );
      },
    );
  }
}