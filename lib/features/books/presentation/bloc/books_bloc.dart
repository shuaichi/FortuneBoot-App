import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';

part 'books_event.dart';
part 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc({BooksService? service, int? initialGroupId})
    : _service = service ?? BooksService(),
      _initialGroupId = initialGroupId,
      super(BooksState(selectedGroupId: initialGroupId)) {
    on<BooksLoaded>(_onLoaded);
    on<BooksMutated>(_onMutated);
    on<BooksGroupSelected>(_onGroupSelected);
    on<BooksGroupSearchChanged>(_onGroupSearchChanged);
    on<BooksGroupFilterChanged>(_onGroupFilterChanged);
    on<BooksSearchChanged>(_onBooksSearchChanged);
    on<BooksSegmentChanged>(_onBooksSegmentChanged);
    on<BooksCapabilitiesRequested>(_onCapabilitiesRequested);
  }

  final BooksService _service;
  final int? _initialGroupId;
  int _bookLoadSerial = 0;

  Future<void> _onLoaded(BooksLoaded event, Emitter<BooksState> emit) async {
    emit(state.copyWith(status: BooksStatus.loading, errorMessage: null));
    try {
      final results = await Future.wait<dynamic>([
        _service.getGroupPage(),
        _service.getEnabledGroups(),
        _service.getDefaultGroupId(),
        _service.getLoginUserInfo(),
      ]);
      final page = results[0] as PagedRows<ManagedGroup>;
      final groups = page.rows.where((g) => g.groupId != null).toList();
      final enabledGroups = results[1] as List<FortuneGroupVo>;
      final defaultGroupId = results[2] as int?;
      final loginUser = results[3] as LoginUserInfo;
      // ignore: avoid_print
      print(
        '[BooksBloc] loaded groups=${groups.length} enabledGroups=${enabledGroups.length} defaultGroupId=$defaultGroupId selected=${event.selectedGroupId}',
      );
      final selectedId = _resolveSelected(
        groups,
        requestedId: event.selectedGroupId,
      );
      final capabilities = <int, ManageCapabilities>{
        for (final group in groups)
          if (group.groupId != null)
            group.groupId!: CapabilityResolver.fromGroup(group),
      };

      emit(
        state.copyWith(
          status: BooksStatus.loaded,
          groups: groups,
          enabledGroups: enabledGroups,
          defaultGroupId: defaultGroupId,
          selectedGroupId: selectedId,
          capabilitiesByGroupId: capabilities,
          groupsTotal: page.total,
          hasMoreGroups: page.hasMore,
          currentUsername: loginUser.username,
          errorMessage: null,
        ),
      );
      if (selectedId != null) await _loadBooks(emit, selectedId);
    } on FxApiException catch (e) {
      emit(state.copyWith(status: BooksStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(
        state.copyWith(status: BooksStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onMutated(BooksMutated event, Emitter<BooksState> emit) {
    return _onLoaded(BooksLoaded(selectedGroupId: state.selectedGroupId), emit);
  }

  Future<void> _onGroupSelected(
    BooksGroupSelected event,
    Emitter<BooksState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedGroupId: event.groupId,
        status: BooksStatus.loading,
      ),
    );
    try {
      await _loadBooks(emit, event.groupId);
    } on FxApiException catch (e) {
      emit(state.copyWith(status: BooksStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(
        state.copyWith(status: BooksStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onGroupSearchChanged(
    BooksGroupSearchChanged event,
    Emitter<BooksState> emit,
  ) {
    emit(state.copyWith(groupSearch: event.query));
  }

  void _onGroupFilterChanged(
    BooksGroupFilterChanged event,
    Emitter<BooksState> emit,
  ) {
    emit(state.copyWith(groupFilter: event.filter));
  }

  void _onBooksSearchChanged(
    BooksSearchChanged event,
    Emitter<BooksState> emit,
  ) {
    emit(state.copyWith(bookSearch: event.query));
  }

  void _onBooksSegmentChanged(
    BooksSegmentChanged event,
    Emitter<BooksState> emit,
  ) {
    emit(state.copyWith(bookSegment: event.segment));
  }

  Future<void> _onCapabilitiesRequested(
    BooksCapabilitiesRequested event,
    Emitter<BooksState> emit,
  ) async {
    if (state.capabilitiesByGroupId[event.groupId]?.resolved == true) return;
    try {
      final members = await _service.getGroupUsers(event.groupId);
      final current = members.where(
        (m) => m.matchesAccount(state.currentUsername),
      );
      ManagedGroup? group;
      for (final candidate in state.groups) {
        if (candidate.groupId == event.groupId) {
          group = candidate;
          break;
        }
      }
      final capabilities = group == null
          ? ManageCapabilities.visitor
          : CapabilityResolver.fromGroup(
              group,
              fallbackMember: current.isEmpty ? null : current.first,
            );
      final next = Map<int, ManageCapabilities>.of(state.capabilitiesByGroupId)
        ..[event.groupId] = capabilities;
      emit(state.copyWith(capabilitiesByGroupId: next));
    } on Object {
      final next = Map<int, ManageCapabilities>.of(state.capabilitiesByGroupId)
        ..[event.groupId] = ManageCapabilities.visitor;
      emit(state.copyWith(capabilitiesByGroupId: next));
    }
  }

  int? _resolveSelected(List<ManagedGroup> groups, {int? requestedId}) {
    final ids = groups.map((g) => g.groupId).whereType<int>().toSet();
    if (requestedId != null && ids.contains(requestedId)) return requestedId;
    if (state.selectedGroupId != null && ids.contains(state.selectedGroupId)) {
      return state.selectedGroupId;
    }
    if (_initialGroupId != null && ids.contains(_initialGroupId)) {
      return _initialGroupId;
    }
    final enabled = groups.where((g) => g.enable && g.groupId != null);
    if (enabled.isNotEmpty) return enabled.first.groupId;
    return groups.isEmpty ? null : groups.first.groupId;
  }

  Future<void> _loadBooks(Emitter<BooksState> emit, int groupId) async {
    final serial = ++_bookLoadSerial;
    final results = await Future.wait<dynamic>([
      _service.getBookPage(groupId: groupId),
      _service.getBookPage(groupId: groupId, recycleBin: true),
      _service.getBookPage(groupId: groupId, enable: true),
    ]);
    if (serial != _bookLoadSerial) return;
    // ignore: avoid_print
    print(
      '[BooksBloc] loaded books group=$groupId active=${(results[0] as PagedRows<FortuneBookVo>).rows.length} recycled=${(results[1] as PagedRows<FortuneBookVo>).rows.length} enabled=${(results[2] as PagedRows<FortuneBookVo>).rows.length}',
    );
    emit(
      state.copyWith(
        status: BooksStatus.loaded,
        selectedGroupId: groupId,
        books: (results[0] as PagedRows<FortuneBookVo>).rows,
        recycledBooks: (results[1] as PagedRows<FortuneBookVo>).rows,
        enabledActiveBooks: (results[2] as PagedRows<FortuneBookVo>).rows,
        errorMessage: null,
      ),
    );
  }
}
