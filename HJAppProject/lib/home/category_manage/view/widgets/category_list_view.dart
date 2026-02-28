import 'package:flutter/material.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_summary_bar.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_pager.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_empty_state.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_loading_indicator.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_error_view.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_tree_node.dart';

class CategoryListView<T> extends StatelessWidget {
  const CategoryListView({
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
    required this.onToggleNode,
    required this.onModify,
    required this.onMoveToRecycle,
    required this.onAddChild,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  final String typeText; // '支出' 或 '收入'
  final int total;
  final int currentPage;

  final List<T> roots;
  final Set<int> expandedNodeIds;

  // Adapters
  final List<T> Function(T) childrenOf;
  final String Function(T) nameOf;
  final String? Function(T) remarkOf;
  final int Function(T) idOf;

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
    // Breakpoint-based horizontal padding
    double _horizontalPadding() {
      final width = MediaQuery.of(context).size.width;
      if (width < 600) return 20; // Increased base padding for cleaner look
      if (width < 1024) return 24;
      return 32;
    }

    // List or Empty State Builder
    Widget _buildListOrEmpty() {
      final double hPadding = _horizontalPadding();
      
      // Vertical padding for the list
      const EdgeInsets listPadding = EdgeInsets.only(top: 8, bottom: 24);

      if (roots.isEmpty) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: hPadding).add(listPadding),
          children: [
            CategorySummaryBar(typeText: typeText, total: total, currentPage: currentPage),
            const SizedBox(height: 80),
            const CategoryEmptyState(),
            const SizedBox(height: 16),
            CategoryPager(
              total: total,
              hasPrev: hasPrev,
              hasNext: hasNext,
              onPrev: onPrev,
              onNext: onNext,
            ),
          ],
        );
      }
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPadding).add(listPadding),
        itemCount: roots.length + 2, // Summary + Roots + Pager
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategorySummaryBar(typeText: typeText, total: total, currentPage: currentPage);
          }
          if (index == roots.length + 1) {
            return CategoryPager(
              total: total,
              hasPrev: hasPrev,
              hasNext: hasNext,
              onPrev: onPrev,
              onNext: onNext,
            );
          }
          final node = roots[index - 1];
          return CategoryTreeNode<T>(
            node: node,
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
          );
        },
      );
    }

    // 统一状态切换：AnimatedSwitcher（fade + size）
    Widget currentChild;
    Key stateKey;

    if (loading) {
      currentChild = const CategoryLoadingIndicator();
      stateKey = const ValueKey('state-loading');
    } else if (error != null) {
      currentChild = CategoryErrorView(message: error ?? '加载失败', onRetry: onRetry);
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
      child: KeyedSubtree(key: stateKey, child: currentChild),
    );
  }
}