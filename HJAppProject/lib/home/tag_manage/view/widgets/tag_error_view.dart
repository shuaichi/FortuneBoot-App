import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';

class TagErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TagErrorView({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HJSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HJColors.expense.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: HJColors.expense,
                size: 36,
              ),
            ),
            const SizedBox(height: HJSpacing.md),
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: HJColors.textPrimary,
              ),
            ),
            const SizedBox(height: HJSpacing.xs),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: HJColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HJSpacing.lg),
            SizedBox(
              width: 120,
              child: HJButton.secondary(
                text: '重试',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}