import 'package:flutter/material.dart';

class CategoryPager extends StatelessWidget {
  const CategoryPager({
    super.key,
    required this.total,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  final int total;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      // 横向留白交由外层 ListView 控制，这里仅做垂直间距
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Tooltip(
            message: '上一页',
            child: OutlinedButton.icon(
              onPressed: hasPrev ? onPrev : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('上一页'),
              style: ButtonStyle(
                minimumSize: const MaterialStatePropertyAll(Size(120, 44)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '共 $total 条',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
          Tooltip(
            message: '下一页',
            child: OutlinedButton.icon(
              onPressed: hasNext ? onNext : null,
              icon: const Icon(Icons.chevron_right),
              label: const Text('下一页'),
              style: ButtonStyle(
                minimumSize: const MaterialStatePropertyAll(Size(120, 44)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}