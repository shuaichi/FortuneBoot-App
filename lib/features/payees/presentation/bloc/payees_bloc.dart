import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/features/payees/data/payee_service.dart';
import 'package:stream_transform/stream_transform.dart';

part 'payees_event.dart';
part 'payees_state.dart';

const _searchDebounce = Duration(milliseconds: 300);

/// 交易对象 Bloc：扁平列表（getPage）。搜索走服务端 payeeName；
/// tab 的 enable 本地过滤、recycleBin 服务端；开关乐观更新。
class PayeesBloc extends Bloc<PayeesEvent, PayeesState> {
  final PayeeService _service;
  int? _bookId;

  PayeesBloc({PayeeService? service, int? bookId})
    : _service = service ?? PayeeService(),
      _bookId = bookId,
      super(const PayeesState()) {
    on<PayeesLoaded>(_onLoaded);
    on<PayeesMutated>(_onLoaded);
    on<PayeesBookChanged>(_onBookChanged);
    on<PayeesTabChanged>(_onTabChanged);
    // 搜索防抖 + restartable：连续输入只在停顿 300ms 后发一次请求，
    // 新输入抵达时取消上一次未完成的加载，避免整页重载与 loading 闪烁。
    on<PayeesSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(_searchDebounce).switchMap(mapper),
    );
    on<PayeeToggleChanged>(_onToggleChanged);
  }

  Future<void> _onBookChanged(
    PayeesBookChanged event,
    Emitter<PayeesState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != PayeesStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    await _load(emit);
  }

  Future<void> _onTabChanged(
    PayeesTabChanged event,
    Emitter<PayeesState> emit,
  ) async {
    final wasRecycle = state.tab.recycleBin;
    emit(state.copyWith(tab: event.tab));
    if (wasRecycle != event.tab.recycleBin) {
      await _load(emit);
    }
  }

  Future<void> _onSearchChanged(
    PayeesSearchChanged event,
    Emitter<PayeesState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword));
    // 搜索保留旧列表、不切 loading，避免每次结果替换成整屏 spinner。
    await _load(emit, silent: true);
  }

  Future<void> _onLoaded(PayeesEvent event, Emitter<PayeesState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<PayeesState> emit, {bool silent = false}) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: PayeesStatus.empty, payees: const []));
      return;
    }
    if (!silent) emit(state.copyWith(status: PayeesStatus.loading));
    try {
      final page = await _service.getPage(
        bookId: bookId,
        recycleBin: state.tab.recycleBin,
        payeeName: state.keyword,
      );
      emit(
        state.copyWith(
          status: page.rows.isEmpty ? PayeesStatus.empty : PayeesStatus.loaded,
          payees: page.rows,
        ),
      );
    } on FxApiException catch (e) {
      emit(state.copyWith(status: PayeesStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(
        state.copyWith(status: PayeesStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onToggleChanged(
    PayeeToggleChanged event,
    Emitter<PayeesState> emit,
  ) async {
    final bookId = _bookId;
    final payeeId = event.payee.payeeId;
    if (bookId == null || payeeId == null) return;

    final original = state.payees;
    final optimistic = original.map((p) {
      if (p.payeeId != payeeId) return p;
      return switch (event.field) {
        PayeeToggleField.canExpense => p.copyWith(canExpense: event.value),
        PayeeToggleField.canIncome => p.copyWith(canIncome: event.value),
        PayeeToggleField.enable => p.copyWith(enable: event.value),
      };
    }).toList();
    emit(state.copyWith(payees: optimistic));

    try {
      await _service.toggle(
        bookId: bookId,
        payeeId: payeeId,
        action: event.field.action(event.value),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          payees: original,
          toastMessage:
              '${event.field.label}切换失败：'
              '${e is FxApiException ? e.message : e.toString()}',
        ),
      );
    }
  }
}
