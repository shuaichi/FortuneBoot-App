part of 'tags_bloc.dart';

sealed class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object?> get props => [];
}

class TagsLoaded extends TagsEvent {
  const TagsLoaded();
}

class TagsBookChanged extends TagsEvent {
  final int? bookId;
  const TagsBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class TagsTabChanged extends TagsEvent {
  final ManageTab tab;
  const TagsTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class TagsSearchChanged extends TagsEvent {
  final String keyword;
  const TagsSearchChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class TagsMutated extends TagsEvent {
  const TagsMutated();
}

/// 切换树节点展开状态。
class ToggleTagExpandRequested extends TagsEvent {
  const ToggleTagExpandRequested(this.tagId);

  final int tagId;

  @override
  List<Object?> get props => [tagId];
}

/// 开关切换（canExpense/canIncome/canTransfer/enable）乐观更新。
class TagToggleChanged extends TagsEvent {
  final FortuneTagVo tag;
  final TagToggleField field;
  final bool value;
  const TagToggleChanged({
    required this.tag,
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [tag.tagId, field, value];
}
