import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class TagSummaryBar extends StatelessWidget {
  final String typeText;
  final int total;
  final int currentPage;

  const TagSummaryBar({
    Key? key,
    required this.typeText,
    required this.total,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: HJSpacing.sm, horizontal: HJSpacing.sm),
      margin: const EdgeInsets.only(bottom: HJSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children:[
          Text(
            '$typeText管理',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: HJColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: HJColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$total 项',
              style: const TextStyle(
                color: HJColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}