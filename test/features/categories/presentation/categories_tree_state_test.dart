import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/features/categories/presentation/bloc/categories_bloc.dart';

void main() {
  const tree = [
    FortuneCategoryVo(
      categoryId: 1,
      categoryName: '餐饮',
      children: [
        FortuneCategoryVo(categoryId: 2, categoryName: '早餐'),
        FortuneCategoryVo(categoryId: 3, categoryName: '晚餐'),
      ],
    ),
  ];

  test('search projection preserves matching paths and branch counts', () {
    final state = CategoriesState(tree: tree, keyword: '餐');

    expect(state.filtered.single.categoryId, 1);
    expect(state.filtered.single.children, hasLength(2));
    expect(state.autoExpandedIds, {1});
    expect(state.matchCountFor(1), 3);
    expect(state.matchCountFor(2), 1);
    expect(state.matchCountFor(3), 1);
  });

  test('explicit search collapse overrides automatic expansion', () {
    final state = CategoriesState(
      tree: tree,
      keyword: '餐',
      searchCollapsedIds: {1},
    );

    expect(state.isExpanded(1), isFalse);
  });

  test('only explicit expanded ids are expanded outside search', () {
    final state = CategoriesState(tree: tree, expandedIds: {1});

    expect(state.isExpanded(1), isTrue);
    expect(state.isExpanded(2), isFalse);
  });
}
