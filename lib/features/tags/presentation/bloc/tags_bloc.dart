import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/features/tags/data/tag_service.dart';
import 'package:fortuneboot/generated/l10n.dart';

part 'tags_event.dart';
part 'tags_state.dart';

/// 标签 Bloc：树形。拉 getList 本地按 tab/搜索过滤；
/// canExpense/canIncome/canTransfer/enable 开关各自乐观更新，失败回滚。
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final TagService _service;
  int? _bookId;

  TagsBloc({TagService? service, int? bookId})
    : _service = service ?? TagService(),
      _bookId = bookId,
      super(const TagsState()) {
    on<TagsLoaded>(_onLoaded);
    on<TagsMutated>(_onLoaded);
    on<TagsBookChanged>(_onBookChanged);
    on<TagsTabChanged>(_onTabChanged);
    on<TagsSearchChanged>(_onSearchChanged);
    on<TagToggleChanged>(_onToggleChanged);
  }

  Future<void> _onBookChanged(
    TagsBookChanged event,
    Emitter<TagsState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != TagsStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    await _load(emit);
  }

  Future<void> _onTabChanged(
    TagsTabChanged event,
    Emitter<TagsState> emit,
  ) async {
    final wasRecycle = state.tab.recycleBin;
    emit(state.copyWith(tab: event.tab));
    if (wasRecycle != event.tab.recycleBin) {
      await _load(emit);
    }
  }

  void _onSearchChanged(TagsSearchChanged event, Emitter<TagsState> emit) {
    emit(state.copyWith(keyword: event.keyword));
  }

  Future<void> _onLoaded(TagsEvent event, Emitter<TagsState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<TagsState> emit) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: TagsStatus.empty, tree: const []));
      return;
    }
    emit(state.copyWith(status: TagsStatus.loading));
    try {
      final tree = await _service.getList(
        bookId: bookId,
        recycleBin: state.tab.recycleBin,
      );
      emit(
        state.copyWith(
          status: tree.isEmpty ? TagsStatus.empty : TagsStatus.loaded,
          tree: tree,
        ),
      );
    } on FxApiException catch (e) {
      emit(state.copyWith(status: TagsStatus.error, errorMessage: e.message));
    } on Object {
      emit(
        state.copyWith(
          status: TagsStatus.error,
          errorMessage: S.current.dashboardLoadFailed,
        ),
      );
    }
  }

  Future<void> _onToggleChanged(
    TagToggleChanged event,
    Emitter<TagsState> emit,
  ) async {
    final bookId = _bookId;
    final tagId = event.tag.tagId;
    if (bookId == null || tagId == null) return;

    final original = state.tree;
    final optimistic = _applyToggle(original, tagId, event.field, event.value);
    emit(state.copyWith(tree: optimistic));

    try {
      await _service.toggle(
        bookId: bookId,
        tagId: tagId,
        action: event.field.action(event.value),
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

  List<FortuneTagVo> _applyToggle(
    List<FortuneTagVo> nodes,
    int tagId,
    TagToggleField field,
    bool value,
  ) {
    return nodes.map((n) {
      final children = _applyToggle(n.children, tagId, field, value);
      if (n.tagId == tagId) {
        return switch (field) {
          TagToggleField.canExpense => n.copyWith(
            canExpense: value,
            children: children,
          ),
          TagToggleField.canIncome => n.copyWith(
            canIncome: value,
            children: children,
          ),
          TagToggleField.canTransfer => n.copyWith(
            canTransfer: value,
            children: children,
          ),
          TagToggleField.enable => n.copyWith(
            enable: value,
            children: children,
          ),
        };
      }
      return n.copyWith(children: children);
    }).toList();
  }
}
