import 'package:flutter/material.dart';

class CategoryManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CategoryManageAppBar({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AppBar(
      title: Text('分类管理', style: tt.titleLarge),
      scrolledUnderElevation: 0,
      actions: [
        Tooltip(
          message: '新增分类',
          child: Semantics(
            button: true,
            label: '新增分类',
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: '新增分类',
              onPressed: onAddPressed,
              splashRadius: 24,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
        ),
      ],
    );
  }
}