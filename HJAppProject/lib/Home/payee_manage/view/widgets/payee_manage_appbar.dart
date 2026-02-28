import 'package:flutter/material.dart';

class PayeeManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PayeeManageAppBar({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AppBar(
      title: Text('交易对象管理', style: tt.titleLarge),
      scrolledUnderElevation: 0,
      actions: [
        Tooltip(
          message: '新增交易对象',
          child: Semantics(
            button: true,
            label: '新增交易对象',
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: '新增交易对象',
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