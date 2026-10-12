import 'package:flutter/material.dart';
import 'tag_summary_bar.dart';
import 'tag_pager.dart';
import 'tag_empty_state.dart';
import 'tag_loading_indicator.dart';
import 'tag_error_view.dart';
import 'tag_tree_node.dart';

class TagListView<T> extends StatelessWidget {
  const TagListView({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.typeText,
    required this.total,
    required this.currentPage,
    required this.roots,
    required this.expandedNodeIds,
    required this.childrenOf,
    required this.nameOf,
    required this.remarkOf,
    required this.idOf,
    required this.enableOf,
    required this.canExpenseOf,
    required this.canIncomeOf,
    required this.canTransferOf,
    this.iconOf,
    required this.onToggleNode,
    required this.onModify,
    required this.onMoveToRecycle,
    required this.onAddChild,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  final String typeText; // '标签'
  final int total;
  final int currentPage;

  final List<T> roots;
  final Set<int> expandedNodeIds;

  // Adapters
  final List<T> Function(T) childrenOf;
  final String Function(T) nameOf;
  final String? Function(T) remarkOf;
  final int Function(T) idOf;
  final bool Function(T) enableOf;
  final bool Function(T) canExpenseOf;
  final bool Function(T) canIncomeOf;
  final bool Function(T) canTransferOf;

  /// 可选：取节点自定义图标名（Iconify 名称），未提供时沿用默认图标
  final String? Function(T)? iconOf;

  // Actions
  final void Function(T node, bool expanded) onToggleNode;
  final void Function(T node) onModify;
  final void Function(T node) onMoveToRecycle;
  final void Function(T node) onAddChild;

  // Pager
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    // 断点式横向内边距（Material 3 间距体系）
    double _horizontalPadding() {
      final width = MediaQuery.of(context).size.width;
      if (width < 600) return 16;
      if (width < 1024) return 20;
      return 24;
    }

    // 构建列表/空态内容，统一 ListView padding 与栅格
    Widget _buildListOrEmpty() {
      final double hPadding = _horizontalPadding();
      if (roots.isEmpty) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          children: [
            TagSummaryBar(typeText: typeText, total: total, currentPage: currentPage),
            const SizedBox(height: 80),
            const TagEmptyState(),
            const SizedBox(height: 16),
            TagPager(
              total: total,
              hasPrev: hasPrev,
              hasNext: hasNext,
              onPrev: onPrev,
              onNext: onNext,
            ),
          ],
        );
      }
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        children: [
          TagSummaryBar(typeText: typeText, total: total, currentPage: currentPage),
          const SizedBox(height: 12),
          ...roots.map(
            (n) => TagTreeNode<T>(
              node: n,
              depth: 0,
              childrenOf: childrenOf,
              nameOf: nameOf,
              remarkOf: remarkOf,
              idOf: idOf,
              isExpanded: (x) => expandedNodeIds.contains(idOf(x)),
              onToggleNode: onToggleNode,
              onModify: onModify,
              onMoveToRecycle: onMoveToRecycle,
              onAddChild: onAddChild,
              // 传递四态适配器以供节点渲染使用
              enableOf: enableOf,
              canExpenseOf: canExpenseOf,
              canIncomeOf: canIncomeOf,
              canTransferOf: canTransferOf,
              iconOf: iconOf,
            ),
          ),
          const SizedBox(height: 12),
          TagPager(
            total: total,
            hasPrev: hasPrev,
            hasNext: hasNext,
            onPrev: onPrev,
            onNext: onNext,
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    // 统一状态切换：AnimatedSwitcher（fade + size）
    Widget currentChild;
    Key stateKey;

    if (loading) {
      currentChild = const TagLoadingIndicator();
      stateKey = const ValueKey('state-loading');
    } else if (error != null) {
      currentChild = TagErrorView(message: error ?? '加载失败', onRetry: onRetry);
      stateKey = const ValueKey('state-error');
    } else {
      currentChild = _buildListOrEmpty();
      stateKey = ValueKey(roots.isEmpty ? 'state-empty' : 'state-list');
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        return SizeTransition(sizeFactor: animation, axisAlignment: -1.0, child: fade);
      },
      child: Container(key: stateKey, child: currentChild),
    );
  }
}