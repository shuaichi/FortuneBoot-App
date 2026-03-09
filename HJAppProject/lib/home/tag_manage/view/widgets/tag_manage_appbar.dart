import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class TagManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddPressed;

  const TagManageAppBar({
    Key? key,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: HJColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
        '标签管理',
        style: TextStyle(
          color: HJColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: HJColors.textPrimary),
      actions:[
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onAddPressed();
          },
          child: Container(
            margin: const EdgeInsets.only(right: HJSpacing.md),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HJColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 20, color: HJColors.primary),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}