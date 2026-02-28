import 'package:flutter/material.dart';
import 'package:hjproject/home/payee_manage/view/widgets/enhanced_payee_type_selector.dart'; // Import for enum

class PayeeFilterBar extends StatelessWidget {
  const PayeeFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final PayeeFilterType selectedType;
  final ValueChanged<PayeeFilterType> onTypeChanged;

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
    final allColor = Colors.blue;      // 全部：Blue

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
                title: '全部',
                icon: Icons.all_inclusive,
                isSelected: selectedType == PayeeFilterType.all,
                activeColor: allColor,
                onTap: () => onTypeChanged(PayeeFilterType.all),
              ),
            ),
            Expanded(
              child: _TabButton(
                title: '支出对象',
                icon: Icons.remove_circle_outline,
                isSelected: selectedType == PayeeFilterType.expenseEnabled,
                activeColor: expenseColor,
                onTap: () => onTypeChanged(PayeeFilterType.expenseEnabled),
              ),
            ),
            Expanded(
              child: _TabButton(
                title: '收入对象',
                icon: Icons.add_circle_outline,
                isSelected: selectedType == PayeeFilterType.incomeEnabled,
                activeColor: incomeColor,
                onTap: () => onTypeChanged(PayeeFilterType.incomeEnabled),
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
            // 响应式隐藏图标或文字以适应小屏幕下的三个按钮
            Flexible(
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? activeColor : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13, // 稍微调小字体以适应3个按钮
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}