import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class TagLoadingIndicator extends StatelessWidget {
  const TagLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(HJColors.primary),
            ),
          ),
          SizedBox(height: HJSpacing.md),
          Text(
            '正在加载标签...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: HJColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}