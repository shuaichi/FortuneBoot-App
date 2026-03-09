import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

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

  final List<T> Function(T) childrenOf;
  final String Function(T) nameOf;
  final String? Function(T) remarkOf;
  final int Function(T) idOf;
  final bool Function(T)? enableOf;
  final bool Function(T)? canExpenseOf;
  final bool Function(T)? canIncomeOf;
  final bool Function(T)? canTransferOf;

  final bool Function(T) isExpanded;
  final void Function(T node, bool expanded) onToggleNode;

  final void Function(T node) onModify;
  final void Function(T node) onMoveToRecycle;
  final void Function(T node) onAddChild;

  @override
  Widget build(BuildContext context) {
    final List<T> children = childrenOf(node);
    final bool hasChildren = children.isNotEmpty;
    final int childCount = children.length;
    final String name = nameOf(node);
    final String? remark = remarkOf(node);
    final bool expanded = isExpanded(node);

    final TextStyle titleStyle = TextStyle(
      fontSize: depth == 0 ? 17 : 15,
      fontWeight: depth == 0 ? FontWeight.w600 : FontWeight.w500,
      color: HJColors.textPrimary,
    );

    final Widget leading = HJSoftIcon(
      icon: hasChildren ? Icons.category_rounded : Icons.label_outline_rounded,
      color: depth == 0 ? HJColors.primary : HJColors.textSecondary,
    );

    final Widget metaInfo = childCount > 0
        ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: HJColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$childCount 子类',
        style: const TextStyle(fontSize: 12, color: HJColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    )
        : const SizedBox.shrink();

    final Widget menu = PopupMenuButton<int>(
      tooltip: '更多操作',
      icon: const Icon(Icons.more_horiz_rounded, color: HJColors.textSecondary),
      color: HJColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onOpened: () => HapticFeedback.lightImpact(),
      onSelected: (value) {
        HapticFeedback.selectionClick();
        if (value == 0) onModify(node);
        else if (value == 1) onMoveToRecycle(node);
        else if (value == 2) onAddChild(node);
      },
      itemBuilder: (context) =>[
        const PopupMenuItem(value: 2, child: Row(children:[Icon(Icons.add_circle_outline, size: 20, color: HJColors.primary), SizedBox(width: 12), Text('新增子标签', style: TextStyle(fontWeight: FontWeight.w500, color: HJColors.textPrimary))])),
        const PopupMenuItem(value: 0, child: Row(children:[Icon(Icons.edit_outlined, size: 20, color: HJColors.textPrimary), SizedBox(width: 12), Text('修改', style: TextStyle(fontWeight: FontWeight.w500, color: HJColors.textPrimary))])),
        const PopupMenuItem(value: 1, child: Row(children:[Icon(Icons.delete_outline, size: 20, color: HJColors.expense), SizedBox(width: 12), Text('移入回收站', style: TextStyle(color: HJColors.expense, fontWeight: FontWeight.w500))])),
      ],
    );

    Widget buildStatusChips() {
      final List<Widget> chips =[];
      final bool exp = canExpenseOf?.call(node) ?? false;
      final bool inc = canIncomeOf?.call(node) ?? false;
      final bool trf = canTransferOf?.call(node) ?? false;
      final bool en = enableOf?.call(node) ?? true;

      if (!en) chips.add(_buildMiniChip('已禁用', HJColors.textSecondary));
      if (exp) chips.add(_buildMiniChip('支出', HJColors.expense));
      if (inc) chips.add(_buildMiniChip('收入', HJColors.income));
      if (trf) chips.add(_buildMiniChip('转账', HJColors.primary));

      if (chips.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(spacing: 6, runSpacing: 4, children: chips),
      );
    }

    final Widget? subtitleWidget = (remark != null && remark.isNotEmpty) || (canExpenseOf != null)
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        if (remark != null && remark.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(remark, style: const TextStyle(fontSize: 13, color: HJColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        buildStatusChips(),
      ],
    )
        : null;

    final Widget arrowIcon = AnimatedRotation(
      turns: expanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: const Icon(Icons.keyboard_arrow_down_rounded, color: HJColors.textSecondary),
    );

    final Widget tile = Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey('tag-node-${idOf(node)}'),
        initiallyExpanded: expanded,
        onExpansionChanged: (v) {
          HapticFeedback.lightImpact();
          onToggleNode(node, v);
        },
        tilePadding: EdgeInsets.only(left: depth == 0 ? 16 : 8, right: 8, top: 4, bottom: 4),
        backgroundColor: Colors.transparent,
        leading: leading,
        title: Text(name, style: titleStyle),
        subtitle: subtitleWidget,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            metaInfo,
            menu,
            if (hasChildren) arrowIcon,
          ],
        ),
        children: children.map((c) => TagTreeNode<T>(
          node: c, depth: depth + 1, childrenOf: childrenOf, nameOf: nameOf, remarkOf: remarkOf,
          idOf: idOf, isExpanded: isExpanded, onToggleNode: onToggleNode, onModify: onModify,
          onMoveToRecycle: onMoveToRecycle, onAddChild: onAddChild, enableOf: enableOf,
          canExpenseOf: canExpenseOf, canIncomeOf: canIncomeOf, canTransferOf: canTransferOf,
        )).toList(),
      ),
    );

    if (depth == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: BoxDecoration(
          color: HJColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow:[
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: tile,
      );
    } else {
      return Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: HJColors.background, width: 1)),
        ),
        padding: const EdgeInsets.only(left: 24),
        child: tile,
      );
    }
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}