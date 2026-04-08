import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

class ThemeSelectionSheet extends StatelessWidget {
  final List<String> themes;
  final String? current;
  final ValueChanged<String> onSelected;

  const ThemeSelectionSheet(
      {super.key,
        required this.themes,
        required this.onSelected,
        this.current});

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('选择主题',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HJColors.textPrimary)),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: HJColors.divider),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final item = themes[index];
                  final selected = (current != null && current == item) ||
                      (current == null && item == '跟随系统');
                  return HJValueItem(
                    icon: selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    iconColor:
                    selected ? HJColors.primary : HJColors.textSecondary,
                    title: item,
                    valueText: selected ? '当前' : null,
                    valueColor: selected ? HJColors.primary : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(item);
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