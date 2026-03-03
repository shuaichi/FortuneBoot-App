import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class LanguageSelectionSheet extends StatelessWidget {
  final List<String> languages;
  final String? current;
  final ValueChanged<String> onSelected;

  const LanguageSelectionSheet(
      {super.key,
      required this.languages,
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
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择语言',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final item = languages[index];
                  final selected = (current != null && current == item) ||
                      (current == null && item.contains('简体中文'));
                  return HJValueItem(
                    // ← 修复此处
                    icon: Icons.language,
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
