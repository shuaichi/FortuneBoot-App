import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/features/categories/data/category_service.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/generated/l10n.dart';

part 'categories_event.dart';
part 'categories_state.dart';

/// 分类 Bloc：树形。拉 getList（按 recycleBin 维度）本地按 tab/搜索过滤；
/// 启用开关乐观更新。
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryService _service;
  int? _bookId;
  String? _expandedScope;

  CategoriesBloc({CategoryService? service, int? bookId})
    : _service = service ?? CategoryService(),
      _bookId = bookId,
      super(CategoriesState()) {
    on<CategoriesLoaded>(_onLoaded);
    on<CategoriesMutated>(_onLoaded);
    on<CategoriesBookChanged>(_onBookChanged);
    on<CategoriesTabChanged>(_onTabChanged);
    on<CategoriesSearchChanged>(_onSearchChanged);
    on<ToggleCategoryExpandRequested>(_onExpandToggled);
    on<CategoryEnableToggled>(_onEnableToggled);
  }

  Future<void> _onBookChanged(
    CategoriesBookChanged event,
    Emitter<CategoriesState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != CategoriesStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    await _load(emit);
  }

  Future<void> _onTabChanged(
    CategoriesTabChanged event,
    Emitter<CategoriesState> emit,
  ) async {
    final wasRecycle = state.tab.recycleBin;
    emit(state.copyWith(tab: event.tab));
    // recycleBin 维度变化需重拉；enable 过滤本地完成。
    if (wasRecycle != event.tab.recycleBin) {
      await _load(emit);
    }
  }

  void _onSearchChanged(
    CategoriesSearchChanged event,
    Emitter<CategoriesState> emit,
  ) {
    if (event.keyword.trim() == state.keyword.trim()) return;
    emit(state.copyWith(keyword: event.keyword, searchCollapsedIds: const {}));
  }

  void _onExpandToggled(
    ToggleCategoryExpandRequested event,
    Emitter<CategoriesState> emit,
  ) {
    final categoryId = event.categoryId;
    final isSearchActive = state.keyword.trim().isNotEmpty;
    final isExpanded = state.isExpanded(categoryId);
    final expandedIds = {...state.expandedIds};
    final searchCollapsedIds = {...state.searchCollapsedIds};

    if (isSearchActive && state.autoExpandedIds.contains(categoryId)) {
      if (isExpanded) {
        searchCollapsedIds.add(categoryId);
      } else {
        searchCollapsedIds.remove(categoryId);
      }
    } else if (isExpanded) {
      expandedIds.remove(categoryId);
    } else {
      expandedIds.add(categoryId);
    }

    emit(
      state.copyWith(
        expandedIds: expandedIds,
        searchCollapsedIds: searchCollapsedIds,
      ),
    );
  }

  Future<void> _onLoaded(
    CategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<CategoriesState> emit) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: CategoriesStatus.empty, tree: const []));
      return;
    }
    emit(state.copyWith(status: CategoriesStatus.loading));
    try {
      final tree = await _service.getList(
        bookId: bookId,
        recycleBin: state.tab.recycleBin,
      );
      final scope = '$bookId:${state.tab.recycleBin}';
      final isNewScope = scope != _expandedScope;
      if (isNewScope) _expandedScope = scope;
      emit(
        state.copyWith(
          status: tree.isEmpty
              ? CategoriesStatus.empty
              : CategoriesStatus.loaded,
          tree: tree,
          expandedIds: isNewScope
              ? (state.tab.recycleBin
                    ? _collectCategoryIds(tree)
                    : tree
                          .map((category) => category.categoryId)
                          .whereType<int>()
                          .toSet())
              : state.expandedIds,
          searchCollapsedIds: isNewScope ? const {} : state.searchCollapsedIds,
        ),
      );
    } on FxApiException catch (e) {
      emit(
        state.copyWith(status: CategoriesStatus.error, errorMessage: e.message),
      );
    } on Object {
      emit(
        state.copyWith(
          status: CategoriesStatus.error,
          errorMessage: S.current.dashboardLoadFailed,
        ),
      );
    }
  }

  Future<void> _onEnableToggled(
    CategoryEnableToggled event,
    Emitter<CategoriesState> emit,
  ) async {
    final bookId = _bookId;
    final categoryId = event.category.categoryId;
    if (bookId == null || categoryId == null) return;

    final original = state.tree;
    final optimistic = _applyEnable(original, categoryId, event.value);
    emit(state.copyWith(tree: optimistic));

    try {
      await _service.toggle(
        bookId: bookId,
        categoryId: categoryId,
        action: event.value ? 'enable' : 'disable',
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          tree: original,
          toastMessage: e is FxApiException
              ? e.message
              : S.current.profileSaveFailedRetry,
        ),
      );
    }
  }

  List<FortuneCategoryVo> _applyEnable(
    List<FortuneCategoryVo> nodes,
    int categoryId,
    bool value,
  ) {
    return nodes.map((n) {
      final children = _applyEnable(n.children, categoryId, value);
      if (n.categoryId == categoryId) {
        return n.copyWith(enable: value, children: children);
      }
      return n.copyWith(children: children);
    }).toList();
  }

  Set<int> _collectCategoryIds(List<FortuneCategoryVo> nodes) {
    final ids = <int>{};
    void walk(List<FortuneCategoryVo> list) {
      for (final node in list) {
        final id = node.categoryId;
        if (id != null) ids.add(id);
        if (node.children.isNotEmpty) walk(node.children);
      }
    }

    walk(nodes);
    return ids;
  }
}
