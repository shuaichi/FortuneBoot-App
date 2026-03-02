import 'package:flutter/material.dart';
import '../../../design_system/hjds_components.dart';
import '../../../design_system/hjds_theme.dart';

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
                  return HJListItem.value(
                    icon: Icons.radio_button_checked,
                    title: item.label,
                    valueText: item.selected ? '当前' : null,
                    valueColor: item.selected ? Colors.green : null,
                    onTap: () {
                      onSelected(item);
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
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