import 'package:flutter/material.dart';

class CategoryErrorView extends StatelessWidget {
  const CategoryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Semantics(
        liveRegion: true,
        label: '加载出错',
        child: Card(
          elevation: 1,
          color: cs.surface,
          surfaceTintColor: cs.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: cs.error),
                  ),
                  const SizedBox(height: 12),
                  Tooltip(
                    message: '重试',
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) return cs.onSurface.withOpacity(0.38);
                          return cs.error;
                        }),
                        side: MaterialStatePropertyAll(BorderSide(color: cs.error)),
                        overlayColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return cs.error.withOpacity(0.08);
                          }
                          if (states.contains(MaterialState.hovered)) {
                            return cs.error.withOpacity(0.04);
                          }
                          return null;
                        }),
                        minimumSize: const MaterialStatePropertyAll(Size(120, 44)),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}