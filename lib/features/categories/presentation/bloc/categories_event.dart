part of 'categories_bloc.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// 首次/刷新加载（按当前 tab 决定 recycleBin）。
class CategoriesLoaded extends CategoriesEvent {
  const CategoriesLoaded();
}

/// 账本变化 → 重拉。
class CategoriesBookChanged extends CategoriesEvent {
  final int? bookId;
  const CategoriesBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// tab 切换（全部/启用/停用/回收站）。回收站维度变化需重拉。
class CategoriesTabChanged extends CategoriesEvent {
  final ManageTab tab;
  const CategoriesTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// 搜索词变化（本地过滤）。
class CategoriesSearchChanged extends CategoriesEvent {
  final String keyword;
  const CategoriesSearchChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

/// 写操作成功后刷新。
class CategoriesMutated extends CategoriesEvent {
  const CategoriesMutated();
}

/// 切换树节点展开状态。
class ToggleCategoryExpandRequested extends CategoriesEvent {
  const ToggleCategoryExpandRequested(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}

/// 启用开关乐观更新。
class CategoryEnableToggled extends CategoriesEvent {
  final FortuneCategoryVo category;
  final bool value;
  const CategoryEnableToggled({required this.category, required this.value});

  @override
  List<Object?> get props => [category.categoryId, value];
}
