import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class SelectionOption<T> {
  final String label;
  final T value;
  final bool selected;

  const SelectionOption(
      {required this.label, required this.value, this.selected = false});
}

class SelectionBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<SelectionOption<T>> options;
  final ValueChanged<SelectionOption<T>> onSelected;

  const SelectionBottomSheet(
      {super.key,
        required this.title,
        required this.options,
        required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: HJSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: HJColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HJColors.textPrimary)),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: HJColors.divider),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelected(item);
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) Navigator.pop(context);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        children:[
                          Icon(
                            item.selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: item.selected
                                ? HJColors.primary
                                : HJColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: HJSpacing.md),
                          Expanded(
                            child: Text(item.label,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: item.selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: item.selected
                                        ? HJColors.textPrimary
                                        : HJColors.textSecondary)),
                          ),
                          if (item.selected)
                            const Text('当前',
                                style: TextStyle(
                                    color: HJColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
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