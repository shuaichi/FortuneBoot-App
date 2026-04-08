import 'package:flutter/material.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';

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
  final String typeText;
  final int total;
  final int currentPage;
  final List<T> roots;
  final Set<int> expandedNodeIds;

  final List<T> Function(T) childrenOf;
  final String Function(T) nameOf;
  final String? Function(T) remarkOf;
  final int Function(T) idOf;
  final bool Function(T) enableOf;
  final bool Function(T) canExpenseOf;
  final bool Function(T) canIncomeOf;
  final bool Function(T) canTransferOf;

  final void Function(T node, bool expanded) onToggleNode;
  final void Function(T node) onModify;
  final void Function(T node) onMoveToRecycle;
  final void Function(T node) onAddChild;

  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    Widget buildListOrEmpty() {
      const EdgeInsets listPadding = EdgeInsets.only(
        left: HJSpacing.md,
        right: HJSpacing.md,
        top: HJSpacing.sm,
        bottom: HJSpacing.xl,
      );

      if (roots.isEmpty) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers:[
            SliverPadding(
              padding: listPadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TagSummaryBar(typeText: typeText, total: total, currentPage: currentPage),
                  const SizedBox(height: 80),
                  const TagEmptyState(),
                ]),
              ),
            ),
          ],
        );
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: listPadding,
        itemCount: roots.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return TagSummaryBar(typeText: typeText, total: total, currentPage: currentPage);
          }
          if (index == roots.length + 1) {
            return TagPager(
              total: total,
              hasPrev: hasPrev,
              hasNext: hasNext,
              onPrev: onPrev,
              onNext: onNext,
            );
          }
          final node = roots[index - 1];
          return TagTreeNode<T>(
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
            enableOf: enableOf,
            canExpenseOf: canExpenseOf,
            canIncomeOf: canIncomeOf,
            canTransferOf: canTransferOf,
          );
        },
      );
    }

    Widget currentChild;
    Key stateKey;

    if (loading) {
      currentChild = const TagLoadingIndicator();
      stateKey = const ValueKey('state-loading');
    } else if (error != null) {
      currentChild = TagErrorView(message: error!, onRetry: onRetry);
      stateKey = const ValueKey('state-error');
    } else {
      currentChild = buildListOrEmpty();
      stateKey = ValueKey(roots.isEmpty ? 'state-empty' : 'state-list');
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: stateKey, child: currentChild),
    );
  }
}