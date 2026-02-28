import 'package:flutter/material.dart';

class TagTreeNode<T> extends StatelessWidget {
  const TagTreeNode({
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
    this.enableOf,
    this.canExpenseOf,
    this.canIncomeOf,
    this.canTransferOf,
  });

  final T node;
  final int depth;

  // Adapters
  final List<T> Function(T) childrenOf;
  final String Function(T) nameOf;
  final String? Function(T) remarkOf;
  final int Function(T) idOf;
  final bool Function(T)? enableOf;
  final bool Function(T)? canExpenseOf;
  final bool Function(T)? canIncomeOf;
  final bool Function(T)? canTransferOf;

  // Controlled expansion
  final bool Function(T) isExpanded;
  final void Function(T node, bool expanded) onToggleNode;

  // Actions
  final void Function(T node) onModify;
  final void Function(T node) onMoveToRecycle;
  final void Function(T node) onAddChild;

  @override
  Widget build(BuildContext context) {
    // Design Tokens aligned with CategoryTreeNode
    const Color surfaceColor = Colors.white;
    const Color primaryText = Colors.black87;
    const Color secondaryText = Colors.grey;
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
        hasChildren ? Icons.local_offer : Icons.local_offer_outlined,
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
          child: Row(children: [Icon(Icons.add_circle_outline, size: 20), SizedBox(width: 12), Text('新增子标签')]),
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

    // Status Chips Logic (Enabled/Expense/Income/Transfer)
    Widget buildStatusChips() {
       final List<Widget> chips = [];
       final bool exp = canExpenseOf?.call(node) ?? false;
       final bool inc = canIncomeOf?.call(node) ?? false;
       final bool trf = canTransferOf?.call(node) ?? false;
       final bool en = enableOf?.call(node) ?? true;

       if (!en) chips.add(_buildMiniChip('已禁用', Colors.grey));
       if (exp) chips.add(_buildMiniChip('支出', Colors.green));
       if (inc) chips.add(_buildMiniChip('收入', Colors.red));
       if (trf) chips.add(_buildMiniChip('转账', Colors.blue));

       if (chips.isEmpty) return const SizedBox.shrink();
       
       return Padding(
         padding: const EdgeInsets.only(top: 4),
         child: Wrap(
           spacing: 4,
           runSpacing: 4,
           children: chips,
         ),
       );
    }

    // Subtitle logic (Remark + Status Chips)
    final Widget? subtitleWidget = (remark != null && remark.isNotEmpty) || 
        (canExpenseOf != null) // If adapters are provided, show chips
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (remark != null && remark.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(remark, style: subtitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              buildStatusChips(),
            ],
          )
        : null;


    // Tile Construction
    final Widget tile = ExpansionTile(
      key: ValueKey('tag-node-${idOf(node)}-$expanded'),
      initiallyExpanded: expanded,
      onExpansionChanged: (v) => onToggleNode(node, v),
      tilePadding: EdgeInsets.only(left: depth == 0 ? 8 : 0, right: 8, top: 4, bottom: 4), // Added vertical padding
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
      children: children.map((c) => TagTreeNode<T>(
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
        enableOf: enableOf,
        canExpenseOf: canExpenseOf,
        canIncomeOf: canIncomeOf,
        canTransferOf: canTransferOf,
      )).toList(),
    );

    // Root nodes get a Card, children get indentation
    if (depth == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
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

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}