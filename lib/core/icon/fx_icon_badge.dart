import 'package:flutter/material.dart';
import 'package:fortuneboot/core/icon/smart_category_engine.dart';

/// 统一图标徽标：圆角彩色底 + 居中图标。所有账单图标接入点用它。
class FxIconBadge extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final double size;

  const FxIconBadge({
    super.key,
    required this.icon,
    required this.tint,
    this.size = 40,
  });

  /// 便捷构造：直接从账单输入匹配图标并渲染。
  factory FxIconBadge.forBill(BillIconInput input, {double size = 40}) {
    final m = SmartCategoryEngine().match(input);
    return FxIconBadge(icon: m.icon, tint: m.color, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: tint, size: size * 0.5),
    );
  }
}
