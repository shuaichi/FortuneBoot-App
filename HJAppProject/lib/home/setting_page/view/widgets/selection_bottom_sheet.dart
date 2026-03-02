import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class SelectionOption<T> {
  final String label;
  final T value;
  final bool selected;
  const SelectionOption({required this.label, required this.value, this.selected = false});
}

class SelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<SelectionOption<T>> options;
  final ValueChanged<SelectionOption<T>> onSelected;

  const SelectionBottomSheet({super.key, required this.title, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: HJSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  // 【修复 Issue 4】重构底部的列表项以完美还原截图要求：左侧单选框，右侧“当前”加箭头
                  return InkWell(
                    onTap: () {
                      onSelected(item);
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: HJSpacing.md, vertical: 16.0),
                      child: Row(
                        children:[
                          Icon(
                            item.selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: item.selected ? Colors.green : Colors.black87,
                            size: 20,
                          ),
                          const SizedBox(width: HJSpacing.md),
                          Expanded(
                            child: Text(item.label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                          ),
                          if (item.selected)
                            const Text('当前', style: TextStyle(color: Colors.green, fontSize: 14)),
                          const SizedBox(width: HJSpacing.sm),
                          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}