import 'package:flutter/material.dart';
import '../../../design_system/hjds_components.dart';
import '../../../design_system/hjds_theme.dart';

class ThemeSelectionSheet extends StatelessWidget {
  final List<String> themes;
  final String? current;
  final ValueChanged<String> onSelected;

  const ThemeSelectionSheet({super.key, required this.themes, required this.onSelected, this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: HJSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择主题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final item = themes[index];
                  final selected = (current != null && current == item) || (current == null && item == '跟随系统');
                  return HJListItem.value(
                    icon: Icons.color_lens_outlined,
                    title: item,
                    valueText: selected ? '当前' : null,
                    valueColor: selected ? Colors.green : null,
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