import 'package:flutter/material.dart';

class CategoryTreeNode<T> extends StatelessWidget {
  const CategoryTreeNode({
    super.key,
    required this.node,
    required this.depth,
    required this.childrenOf,
    required this.nameOf,
    required this.remarkOf,
    required this.idOf,
    required this.isExpanded,
    required this.onToggleNode,
    required this.onModify,
    required this.onMoveToRecycle,
    required this.onAddChild,
  });

  final T node;
  final int depth;

  // Adapters
  final List<T> Function(T) childrenOf;
  final String Function(T) nameOf;
  final String? Function(T) remarkOf;
  final int Function(T) idOf;

  // Controlled expansion
  final bool Function(T) isExpanded;
  final void Function(T node, bool expanded) onToggleNode;

  // Actions
  final void Function(T node) onModify;
  final void Function(T node) onMoveToRecycle;
  final void Function(T node) onAddChild;

  @override
  Widget build(BuildContext context) {
    // Design Tokens
    const Color surfaceColor = Colors.white;
    const Color primaryText = Colors.black87;
    const Color secondaryText = Colors.grey; // Grey600 approximation
    const double cardRadius = 16.0;
    
    final List<T> children = childrenOf(node);
    final bool hasChildren = children.isNotEmpty;
    final int childCount = children.length;
    final String name = nameOf(node);
    final String? remark = remarkOf(node);
    final bool expanded = isExpanded(node);

    // Modern typography style
    final TextStyle titleStyle = TextStyle(
      fontSize: depth == 0 ? 16 : 14,
      fontWeight: depth == 0 ? FontWeight.bold : FontWeight.w500,
      color: primaryText,
    );

    final TextStyle subtitleStyle = TextStyle(
      fontSize: 13,
      color: secondaryText,
    );

    // Leading icon - distinct for root vs child
    final Widget leading = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: depth == 0 ? const Color(0xFFF5F5F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        hasChildren ? Icons.folder_open_rounded : Icons.label_outline_rounded,
        size: 20,
        color: depth == 0 ? Colors.black54 : Colors.grey,
      ),
    );

    // Meta info (Child count)
    final Widget metaInfo = childCount > 0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$childCount',
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        : const SizedBox.shrink();

    // Context Menu
    final Widget menu = PopupMenuButton<int>(
      tooltip: '更多操作',
      icon: const Icon(Icons.more_horiz, color: Colors.grey),
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 0) onModify(node);
        else if (value == 1) onMoveToRecycle(node);
        else if (value == 2) onAddChild(node);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 2,
          child: Row(children: [Icon(Icons.add_circle_outline, size: 20), SizedBox(width: 12), Text('新增子类')]),
        ),
        const PopupMenuItem(
          value: 0,
          child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('修改')]),
        ),
        const PopupMenuItem(
          value: 1,
          child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 12), Text('移入回收站', style: TextStyle(color: Colors.red))]),
        ),
      ],
    );

    // Expand/Collapse logic
    final Widget arrowIcon = AnimatedRotation(
      turns: expanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
    );

    // Subtitle logic
    final Widget? subtitleWidget = (remark != null && remark.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(remark, style: subtitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          )
        : null;

    // Tile Construction
    // We use ExpansionTile for logic but customize heavily
    final Widget tile = ExpansionTile(
      key: ValueKey('node-${idOf(node)}-$expanded'),
      initiallyExpanded: expanded,
      onExpansionChanged: (v) => onToggleNode(node, v),
      tilePadding: EdgeInsets.only(left: depth == 0 ? 8 : 0, right: 8, top: 0, bottom: 0),
      shape: const Border(), // Remove default border
      collapsedShape: const Border(),
      backgroundColor: Colors.transparent,
      leading: leading,
      title: Text(name, style: titleStyle),
      subtitle: subtitleWidget,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          metaInfo,
          const SizedBox(width: 4),
          menu,
          if (hasChildren) ...[
            const SizedBox(width: 0),
            arrowIcon,
          ],
        ],
      ),
      children: children.map((c) => CategoryTreeNode<T>(
        node: c,
        depth: depth + 1,
        childrenOf: childrenOf,
        nameOf: nameOf,
        remarkOf: remarkOf,
        idOf: idOf,
        isExpanded: isExpanded,
        onToggleNode: onToggleNode,
        onModify: onModify,
        onMoveToRecycle: onMoveToRecycle,
        onAddChild: onAddChild,
      )).toList(),
    );

    // Root nodes get a Card, children get indentation
    if (depth == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6), // Margin handled by ListView padding usually, but here vertical gap
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: tile,
      );
    } else {
      // Child nodes
      return Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        ),
        padding: const EdgeInsets.only(left: 16), // Indentation
        child: tile,
      );
    }
  }
}