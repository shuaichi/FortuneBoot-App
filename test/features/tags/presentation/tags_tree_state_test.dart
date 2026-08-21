import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/features/tags/presentation/bloc/tags_bloc.dart';

void main() {
  const tree = [
    FortuneTagVo(
      tagId: 1,
      tagName: '美食',
      children: [
        FortuneTagVo(tagId: 2, tagName: '美食推荐'),
        FortuneTagVo(tagId: 3, tagName: '晚餐'),
      ],
    ),
  ];

  test('search projection expands matched tag paths and counts matches', () {
    final state = TagsState(tree: tree, keyword: '美食');

    expect(state.filtered.single.tagId, 1);
    expect(state.filtered.single.children, hasLength(1));
    expect(state.autoExpandedIds, {1});
    expect(state.matchCountFor(1), 2);
    expect(state.matchCountFor(2), 1);
  });

  test('root-only expansion can be represented by expanded ids', () {
    final state = TagsState(tree: tree, expandedIds: {1});

    expect(state.isExpanded(1), isTrue);
    expect(state.isExpanded(2), isFalse);
  });
}
