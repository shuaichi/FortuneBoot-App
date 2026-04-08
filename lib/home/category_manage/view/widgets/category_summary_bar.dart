import 'package:flutter/material.dart';

class CategorySummaryBar extends StatelessWidget {
  const CategorySummaryBar({
    super.key,
    required this.typeText,
    required this.total,
    required this.currentPage,
  });

  /// “支出”或“收入”
  final String typeText;

  /// 总条目数
  final int total;

  /// 当前页码
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      // 交由外层 ListView 控制横向 padding，这里仅做垂直间距
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Semantics(
            label: '$typeText分类 共$total项',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    typeText == '支出' ? Icons.remove_circle : Icons.add_circle,
                    color: cs.onPrimaryContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$typeText分类 共$total项',
                    style: tt.labelLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            '第 $currentPage 页',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}