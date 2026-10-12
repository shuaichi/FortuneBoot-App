import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/request/tag_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/util/app_icon.dart';

class TagTreeSelection extends StatefulWidget {
  TagTreeSelection(
      {super.key,
      required this.tags,
      this.onTagSelected,
      required this.selectedTagIds});
  List<TagSelectItem> tags;
  Function(List<int>)? onTagSelected;
  List<int> selectedTagIds;

  @override
  State<TagTreeSelection> createState() => _TagTreeSelectionState();
}

class _TagTreeSelectionState extends State<TagTreeSelection> {
  // 展开的节点ID列表（用于控制逐级展开/折叠）
  List<int> _expandedNodeIds = [];

  @override
  Widget build(BuildContext context) {
    widget.onTagSelected?.call(widget.selectedTagIds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 已选择的标签
        if (widget.selectedTagIds.isNotEmpty) _buildSelectedTags(widget.tags),

        // 标签选择器
        _buildTagSelector(widget.tags),
      ],
    );
  }

  // 已选择的标签
  Widget _buildSelectedTags(List<TagSelectItem> allTags) {
    // 从所有标签中找出已选择的标签
    List<String> selectedTagNames = [];

    for (int tagId in widget.selectedTagIds) {
      // 获取标签的完整路径
      String tagPath = TagSelectItem.getFullPathById(allTags, tagId);
      selectedTagNames.add(tagPath);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '已选择的标签',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.selectedTagIds.length, (index) {
              final tagId = widget.selectedTagIds[index];
              final tagName = selectedTagNames[index];

              return Chip(
                label: Text(tagName),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    widget.selectedTagIds.remove(tagId);
                  });
                },
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  // 标签选择器（统一递归渲染，逐级展开）
  Widget _buildTagSelector(List<TagSelectItem> tags) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildNodes(tags, 0),
      ),
    );
  }
  
  // 递归构建所有节点（类内私有方法）
  List<Widget> _buildNodes(List<TagSelectItem> nodes, int depth) {
    return nodes.map((node) => _buildNode(node, depth)).toList();
  }
  
  // 构建单个节点（统一样式与选择逻辑，类内私有方法）
  Widget _buildNode(TagSelectItem node, int depth) {
    final hasChildren = node.children != null && node.children!.isNotEmpty;
    final isExpanded = _expandedNodeIds.contains(node.id);
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren
              ? () {
                  setState(() {
                    if (isExpanded) {
                      _expandedNodeIds.remove(node.id);
                    } else {
                      _expandedNodeIds.add(node.id);
                    }
                  });
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(width: 12.0 * depth),
                Icon(
                  AppIcon.resolve(node.icon) ??
                      (hasChildren ? Icons.label : Icons.label_outline),
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.title,
                    style: TextStyle(
                      fontWeight: depth == 0 ? FontWeight.bold : FontWeight.w500,
                      fontSize: depth == 0 ? 16 : 14,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('选择', style: TextStyle(fontSize: 12)),
                  selected: widget.selectedTagIds.contains(node.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (!widget.selectedTagIds.contains(node.id)) {
                          widget.selectedTagIds.add(node.id);
                        }
                      } else {
                        widget.selectedTagIds.remove(node.id);
                      }
                    });
                  },
                  showCheckmark: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  shape: const StadiumBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ],
            ),
          ),
        ),
  
        if (hasChildren && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildNodes(node.children!, depth + 1),
            ),
          ),
  
        const Divider(height: 1, indent: 16),
      ],
    );
  }
}
