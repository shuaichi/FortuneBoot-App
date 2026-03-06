import 'package:flutter/material.dart';
import 'package:hjproject/home/payee_manage/model/payee.dart';
import 'package:hjproject/home/payee_manage/view/widgets/payee_list_item.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_summary_bar.dart';
import 'package:hjproject/Home/tag_manage/view/widgets/tag_pager.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_empty_state.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_loading_indicator.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_error_view.dart';

class PayeeListView extends StatelessWidget {
  const PayeeListView({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.total,
    required this.currentPage,
    required this.rows,
    required this.onModify,
    required this.onMoveToRecycle,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
    required this.typeText,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  final int total;
  final int currentPage;
  final String typeText;

  final List<Payee> rows;

  // Actions
  final void Function(Payee item) onModify;
  final void Function(Payee item) onMoveToRecycle;

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
      if (width < 600) return 20; 
      if (width < 1024) return 24;
      return 32;
    }

    // List or Empty State Builder
    Widget _buildListOrEmpty() {
      final double hPadding = _horizontalPadding();
      
      // Vertical padding for the list
      const EdgeInsets listPadding = EdgeInsets.only(top: 8, bottom: 24);

      if (rows.isEmpty) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: hPadding).add(listPadding),
          children: [
            CategorySummaryBar(typeText: typeText, total: total, currentPage: currentPage),
            const SizedBox(height: 80),
            // 复用 CategoryEmptyState，如果需要可替换为 PayeeEmptyState
            const CategoryEmptyState(), 
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
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: hPadding).add(listPadding),
        itemCount: rows.length + 2, // Summary + Rows + Pager
        separatorBuilder: (context, index) => const SizedBox(height: 0), // Item 自带 margin
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategorySummaryBar(typeText: typeText, total: total, currentPage: currentPage);
          }
          if (index == rows.length + 1) {
            return TagPager(
              total: total,
              hasPrev: hasPrev,
              hasNext: hasNext,
              onPrev: onPrev,
              onNext: onNext,
            );
          }
          final item = rows[index - 1];
          return PayeeListItem(
            payee: item,
            onModify: () => onModify(item),
            onMoveToRecycle: () => onMoveToRecycle(item),
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
      stateKey = ValueKey(rows.isEmpty ? 'state-empty' : 'state-list');
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