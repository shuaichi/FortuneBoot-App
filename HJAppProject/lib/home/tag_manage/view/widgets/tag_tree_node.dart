import 'package:flutter/material.dart';
import 'package:hjproject/util/app_icon.dart';

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
    this.iconOf,
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

  /// 可选：取节点自定义图标名（Iconify 名称，如 ep:collection-tag），未提供时沿用默认图标
  final String? Function(T)? iconOf;

  // Controlled expansion
  final bool Function(T) isExpanded;
  final void Function(T node, bool expanded) onToggleNode;

  // Actions
  final void Function(T node) onModify;
  final void Function(T node) onMoveToRecycle;
  final void Function(T node) onAddChild;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final List<T> children = childrenOf(node);
    final bool hasChildren = children.isNotEmpty;
    final int childCount = children.length;
    final String name = nameOf(node);
    final String? remark = remarkOf(node);
    final bool expanded = isExpanded(node);

    // 自定义图标优先，未设置时沿用原有图标
    final IconData? customIcon = AppIcon.resolve(iconOf?.call(node));
    final Widget leading = Icon(
      customIcon ?? (hasChildren ? Icons.label : Icons.label_outline),
      size: 16,
      color: cs.secondary,
    );

    // 构建状态标识：四态固定展示（支出/收入/转账/启用），true高亮、false置灰，使用主题色
    Widget _buildStatusChips() {
      final List<Widget> chips = [];
      final bool exp = canExpenseOf?.call(node) ?? false;
      final bool inc = canIncomeOf?.call(node) ?? false;
      final bool trf = canTransferOf?.call(node) ?? false;
      final bool en = enableOf?.call(node) ?? true;

      // 固定四态展示，颜色由 _buildStatusChip 内部统一映射
      chips.add(_buildStatusChip('支出', exp, 'expense', context));
      chips.add(_buildStatusChip('收入', inc, 'income', context));
      chips.add(_buildStatusChip('转账', trf, 'transfer', context));
      chips.add(_buildStatusChip('启用', en, 'enabled', context));

      // 在四态之后追加中性信息的子标签数量Chip（始终展示）
      final int childrenCount = _resolveChildrenCount(node, children);
      chips.add(_buildChildrenCountChip(context, childrenCount));
      
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: chips,
      );
    }


    final Widget menu = Tooltip(
      message: '更多操作',
      child: PopupMenuButton<int>(
        tooltip: '更多操作',
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 0) {
            onModify(node);
          } else if (value == 1) {
            onMoveToRecycle(node);
          } else if (value == 2) {
            onAddChild(node);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.add, color: cs.tertiary),
                const SizedBox(width: 8),
                const Text('新增子标签'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Icon(Icons.edit, color: cs.primary),
                const SizedBox(width: 8),
                const Text('修改'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: cs.error),
                const SizedBox(width: 8),
                const Text('移入回收站'),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget arrowIcon = Icon(
      expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: cs.outline,
    );

    final Widget trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        menu,
        const SizedBox(width: 8),
        hasChildren
            ? arrowIcon
            : InkWell(
                onTap: () => onToggleNode(node, !expanded),
                borderRadius: BorderRadius.circular(8),
                child: arrowIcon,
              ),
      ],
    );

    final Widget? subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (remark != null && remark.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              remark,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              softWrap: true,
            ),
          ),
        const SizedBox(height: 4),
        _buildStatusChips(),
      ],
    );

    final Widget tile = hasChildren
        ? ExpansionTile(
            key: ValueKey('tag-node-${idOf(node)}-$expanded'),
            initiallyExpanded: expanded,
            leading: leading,
            title: Text(
              name,
              style: depth == 0
                  ? tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                  : tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            trailing: trailing,
            onExpansionChanged: (v) => onToggleNode(node, v),
            subtitle: subtitle,
            children: children
                .map(
                  (c) => TagTreeNode<T>(
                    node: c,
                    depth: depth + 1,
                    childrenOf: childrenOf,
                    nameOf: nameOf,
                    remarkOf: remarkOf,
                    idOf: idOf,
                    isExpanded: isExpanded, // child recomputes via parent
                    onToggleNode: onToggleNode,
                    onModify: onModify,
                    onMoveToRecycle: onMoveToRecycle,
                    onAddChild: onAddChild,
                    enableOf: enableOf,
                    canExpenseOf: canExpenseOf,
                    canIncomeOf: canIncomeOf,
                    canTransferOf: canTransferOf,
                    iconOf: iconOf,
                  ),
                )
                .toList(),
          )
        : ListTile(
            leading: leading,
            title: Text(
              name,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            trailing: trailing,
            subtitle: subtitle,
          );

    if (depth == 0) {
      final double targetElevation = (expanded && hasChildren) ? 2.0 : 1.0;
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: targetElevation, end: targetElevation),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: value,
            color: cs.surface,
            surfaceTintColor: cs.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant),
            ),
            child: tile,
          );
        },
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: 12.0 * depth),
      child: tile,
    );
  }

  Widget _buildStatusChip(String label, bool active, String type, BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 统一的类型到颜色映射
    Color colorByType;
    switch (type) {
      case 'expense':
        colorByType = Colors.red;
        break;
      case 'income':
        colorByType = Colors.green;
        break;
      case 'transfer':
        colorByType = Colors.amber.shade700;
        break;
      case 'enabled':
        colorByType = Colors.blue;
        break;
      default:
        colorByType = cs.primary; // 兜底，理论上不会走到
    }

    // active 配色与置灰策略
    final Color bg = active
        ? (type == 'transfer'
            ? (isDark ? colorByType.withOpacity(0.16) : colorByType.withOpacity(0.10))
            : colorByType.withOpacity(0.08))
        : cs.surfaceVariant;
    final Color border = active ? colorByType : cs.outlineVariant;
    final Color text = active ? colorByType : cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ).copyWith(color: text),
      ),
    );
  }

  // 获取子标签数量的逻辑：
  // 优先从 node 中取：childrenCount ?? children?.length ?? childCount ?? 0
  // 若存在 hasChildren 字段但没有数量，则显示 0
  // 最后兜底使用当前 childrenOf 适配器提供的列表长度
  int _resolveChildrenCount(T node, List<T> currentChildren) {
    // 1) childrenCount
    try {
      final d = node as dynamic;
      final v = d.childrenCount;
      if (v != null) {
        return v as int;
      }
    } catch (_) {}

    // 2) children?.length
    try {
      final d = node as dynamic;
      final v = d.children;
      if (v is List) {
        return v.length;
      }
    } catch (_) {}

    // 3) childCount
    try {
      final d = node as dynamic;
      final v = d.childCount;
      if (v != null) {
        return v as int;
      }
    } catch (_) {}

    // 4) hasChildren提示但没有数量 => 显示0
    bool hasChildrenHint = false;
    try {
      final d = node as dynamic;
      final v = d.hasChildren;
      if (v is bool) {
        hasChildrenHint = v;
      }
    } catch (_) {}
    if (hasChildrenHint) {
      return 0;
    }

    // 5) 兜底：使用当前childrenOf返回的长度
    return currentChildren.length;
  }

  // 渲染中性信息样式的“{count}个子标签”Chip
  Widget _buildChildrenCountChip(BuildContext context, int count) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        '$count个子标签',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ).copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}