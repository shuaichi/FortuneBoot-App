import 'package:flutter/material.dart';

/// 设置分组通用卡片组件：标准卡片样式，符合 Design Skill
/// - Surface: White
/// - Radius: 16
/// - Spacing: Internal 16, Gap 16
class SettingGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Design Token: Semantic Colors & Spacing
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8, top: 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600], // Token: Secondary Text
              ),
            ),
          ),
        
        // Card Body
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white, // Token: Surface
            borderRadius: BorderRadius.circular(16), // Token: Radius 16
            // Token: Elevation 0 (Flat design), relying on background contrast
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _buildChildrenWithDividers(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final List<Widget> widgets = [];
    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      // Add divider between items, but not after the last one
      if (i < children.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 56), // Align with text start
            child: Divider(
              height: 1, 
              color: Colors.grey[100], 
              thickness: 0.8
            ),
          ),
        );
      }
    }
    return widgets;
  }
}