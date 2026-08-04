import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';

part 'books_event.dart';
part 'books_state.dart';

/// 账本/分组管理 Bloc：拉分组列表 + 选中分组下账本（正常 + 回收站）。
class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final BooksService _service;
  final int? _initialGroupId;

  BooksBloc({BooksService? service, int? initialGroupId})
      : _service = service ?? BooksService(),
        _initialGroupId = initialGroupId,
        super(BooksState(selectedGroupId: initialGroupId)) {
    on<BooksLoaded>(_onLoaded);
    on<BooksGroupSelected>(_onGroupSelected);
    on<BooksMutated>(_onLoaded);
  }

  Future<void> _onLoaded(BooksEvent event, Emitter<BooksState> emit) async {
    emit(state.copyWith(status: BooksStatus.loading));
    try {
      final allGroups = await _service.getGroups();
      // 过滤掉无 groupId 的脏数据，避免后续 groupId! 解引用崩溃。
      final groups = allGroups.where((g) => g.groupId != null).toList();
      if (groups.isEmpty) {
        emit(state.copyWith(
          status: BooksStatus.loaded,
          groups: const [],
          books: const [],
          recycledBooks: const [],
        ));
        return;
      }
      // 选中分组：保持已选，否则用初始会话分组，否则第一项。
      final selectedId = _resolveSelected(groups);
      await _loadBooks(emit, groups, selectedId);
    } on FxApiException catch (e) {
      emit(state.copyWith(status: BooksStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(state.copyWith(status: BooksStatus.error, errorMessage: e.toString()));
    }
  }

  int _resolveSelected(List<FortuneGroupVo> groups) {
    final ids = groups.map((g) => g.groupId).toList();
    if (state.selectedGroupId != null &&
        ids.contains(state.selectedGroupId)) {
      return state.selectedGroupId!;
    }
    if (_initialGroupId != null && ids.contains(_initialGroupId)) {
      return _initialGroupId;
    }
    return groups.first.groupId!;
  }

  Future<void> _onGroupSelected(
    BooksGroupSelected event,
    Emitter<BooksState> emit,
  ) async {
    emit(state.copyWith(status: BooksStatus.loading, selectedGroupId: event.groupId));
    try {
      await _loadBooks(emit, state.groups, event.groupId);
    } on FxApiException catch (e) {
      emit(state.copyWith(status: BooksStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(state.copyWith(status: BooksStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _loadBooks(
    Emitter<BooksState> emit,
    List<FortuneGroupVo> groups,
    int groupId,
  ) async {
    final results = await Future.wait([
      _service.getBooks(groupId: groupId),
      _service.getBooks(groupId: groupId, recycleBin: true),
    ]);
    emit(state.copyWith(
      status: BooksStatus.loaded,
      groups: groups,
      selectedGroupId: groupId,
      books: results[0],
      recycledBooks: results[1],
    ));
  }
}
