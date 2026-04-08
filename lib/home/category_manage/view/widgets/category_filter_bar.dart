import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  /// 当前选择的类型：1 支出，2 收入
  final int selectedType;

  /// 切换类型的回调，传入 1 或 2
  final ValueChanged<int> onTypeChanged;

  static const int expenseType = 1;
  static const int incomeType = 2;

  @override
  Widget build(BuildContext context) {
    // 根据规范使用固定内边距体系
    double hPadding() {
      final w = MediaQuery.of(context).size.width;
      if (w < 600) return 16;
      if (w < 1024) return 20;
      return 24;
    }

    // 语义颜色
    final expenseColor = Colors.green; // 支出：Green
    final incomeColor = Colors.red;    // 收入：Red

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding(), vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1), // 浅灰背景槽
          borderRadius: BorderRadius.circular(12), // 统一圆角
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                title: '支出分类',
                icon: Icons.remove_circle_outline,
                isSelected: selectedType == expenseType,
                activeColor: expenseColor,
                onTap: () => onTypeChanged(expenseType),
              ),
            ),
            Expanded(
              child: _TabButton(
                title: '收入分类',
                icon: Icons.add_circle_outline,
                isSelected: selectedType == incomeType,
                activeColor: incomeColor,
                onTap: () => onTypeChanged(incomeType),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? activeColor : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}