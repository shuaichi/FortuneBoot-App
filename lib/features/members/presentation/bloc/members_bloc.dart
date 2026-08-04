import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/features/members/data/member_service.dart';
import 'package:stream_transform/stream_transform.dart';

part 'members_event.dart';
part 'members_state.dart';

const _searchDebounce = Duration(milliseconds: 300);

/// 成员 Bloc：扁平列表（getPage）。搜索走服务端 memberName；
/// tab 的 enable 本地过滤、recycleBin 服务端；enable 开关乐观更新。
class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final MemberService _service;
  int? _bookId;

  MembersBloc({MemberService? service, int? bookId})
    : _service = service ?? MemberService(),
      _bookId = bookId,
      super(const MembersState()) {
    on<MembersLoaded>(_onLoaded);
    on<MembersMutated>(_onLoaded);
    on<MembersBookChanged>(_onBookChanged);
    on<MembersTabChanged>(_onTabChanged);
    // 搜索防抖 + restartable：见 PayeesBloc 说明。
    on<MembersSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(_searchDebounce).switchMap(mapper),
    );
    on<MemberEnableToggled>(_onEnableToggled);
  }

  Future<void> _onBookChanged(
    MembersBookChanged event,
    Emitter<MembersState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != MembersStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    await _load(emit);
  }

  Future<void> _onTabChanged(
    MembersTabChanged event,
    Emitter<MembersState> emit,
  ) async {
    final wasRecycle = state.tab.recycleBin;
    emit(state.copyWith(tab: event.tab));
    if (wasRecycle != event.tab.recycleBin) {
      await _load(emit);
    }
  }

  Future<void> _onSearchChanged(
    MembersSearchChanged event,
    Emitter<MembersState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword));
    await _load(emit, silent: true);
  }

  Future<void> _onLoaded(MembersEvent event, Emitter<MembersState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<MembersState> emit, {bool silent = false}) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: MembersStatus.empty, members: const []));
      return;
    }
    if (!silent) emit(state.copyWith(status: MembersStatus.loading));
    try {
      final page = await _service.getPage(
        bookId: bookId,
        recycleBin: state.tab.recycleBin,
        memberName: state.keyword,
      );
      emit(
        state.copyWith(
          status: page.rows.isEmpty
              ? MembersStatus.empty
              : MembersStatus.loaded,
          members: page.rows,
        ),
      );
    } on FxApiException catch (e) {
      emit(
        state.copyWith(status: MembersStatus.error, errorMessage: e.message),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: MembersStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onEnableToggled(
    MemberEnableToggled event,
    Emitter<MembersState> emit,
  ) async {
    final bookId = _bookId;
    final memberId = event.member.memberId;
    if (bookId == null || memberId == null) return;

    final original = state.members;
    final optimistic = original
        .map(
          (m) => m.memberId == memberId ? m.copyWith(enable: event.value) : m,
        )
        .toList();
    emit(state.copyWith(members: optimistic));

    try {
      await _service.toggle(
        bookId: bookId,
        memberId: memberId,
        action: event.value ? 'enable' : 'disable',
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          members: original,
          toastMessage:
              '启用切换失败：${e is FxApiException ? e.message : e.toString()}',
        ),
      );
    }
  }
}
