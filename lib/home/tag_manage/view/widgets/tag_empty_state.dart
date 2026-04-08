import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class TagEmptyState extends StatelessWidget {
  const TagEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HJSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: HJColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.label_outline_rounded,
                size: 40,
                color: HJColors.primary,
              ),
            ),
            const SizedBox(height: HJSpacing.lg),
            const Text(
              '暂无标签',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HJColors.textPrimary,
              ),
            ),
            const SizedBox(height: HJSpacing.sm),
            const Text(
              '点击右上角创建您的第一个标签\n良好的分类让账单更清晰',
              style: TextStyle(
                fontSize: 14,
                color: HJColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}