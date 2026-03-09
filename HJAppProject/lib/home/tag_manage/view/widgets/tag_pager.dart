import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class TagPager extends StatelessWidget {
  const TagPager({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HJSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          _buildPagerButton(
            icon: Icons.chevron_left_rounded,
            label: '上一页',
            enabled: hasPrev,
            onPressed: () {
              HapticFeedback.lightImpact();
              onPrev();
            },
          ),
          Text(
            '共 $total 条记录',
            style: const TextStyle(
              color: HJColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildPagerButton(
            icon: Icons.chevron_right_rounded,
            label: '下一页',
            enabled: hasNext,
            isRightIcon: true,
            onPressed: () {
              HapticFeedback.lightImpact();
              onNext();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPagerButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    bool isRightIcon = false,
  }) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(100, 44)),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: enabled ? HJColors.primary : HJColors.divider,
            width: 1,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        foregroundColor: WidgetStatePropertyAll(
          enabled ? HJColors.primary : HJColors.textSecondary.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:[
          if (!isRightIcon) Icon(icon, size: 18),
          if (!isRightIcon) const SizedBox(width: HJSpacing.xs),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          if (isRightIcon) const SizedBox(width: HJSpacing.xs),
          if (isRightIcon) Icon(icon, size: 18),
        ],
      ),
    );
  }
}