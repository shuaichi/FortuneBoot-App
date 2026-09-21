import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/generated/l10n.dart';

part 'recurring_event.dart';
part 'recurring_state.dart';

/// 周期记账规则 Bloc（对齐成员页：创建即加载 + 账本切换重拉）。
class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringService _service;
  int? _bookId;
  List<int> _bookIds;

  RecurringBloc({
    RecurringService? service,
    int? bookId,
    List<int> bookIds = const [],
  }) : _service = service ?? RecurringService(),
       _bookId = bookId,
       _bookIds = List<int>.unmodifiable(bookIds),
       super(const RecurringState()) {
    on<RecurringBookChanged>(_onBookChanged);
    on<RecurringLoaded>(_onLoaded);
    on<RecurringMutated>(_onLoaded);
    on<RecurringToggled>(_onToggled);
  }

  int? get bookId => _bookId;

  Future<void> _onBookChanged(
    RecurringBookChanged event,
    Emitter<RecurringState> emit,
  ) async {
    _bookId = event.bookId;
    _bookIds = List<int>.unmodifiable(
      event.bookIds.isNotEmpty
          ? event.bookIds
          : (event.bookId != null ? [event.bookId!] : const <int>[]),
    );
    await _onLoaded(event, emit);
  }

  Future<void> _onLoaded(
    RecurringEvent event,
    Emitter<RecurringState> emit,
  ) async {
    final ids = _bookIds.isNotEmpty
        ? _bookIds
        : (_bookId != null ? <int>[_bookId!] : const <int>[]);
    if (ids.isEmpty) {
      emit(
        state.copyWith(status: RecurringStatus.empty, rules: const []),
      );
      return;
    }

    emit(state.copyWith(status: RecurringStatus.loading));
    try {
      final probe = await _service.probeRulesForBooks(ids);
      emit(
        state.copyWith(
          status: probe.rules.isEmpty
              ? RecurringStatus.empty
              : RecurringStatus.loaded,
          rules: probe.rules,
        ),
      );
    } on FxApiException catch (e) {
      emit(
        state.copyWith(
          status: RecurringStatus.error,
          errorMessage: e.message,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: RecurringStatus.error,
          errorMessage: S.current.dashboardLoadFailed,
        ),
      );
    }
  }

  Future<void> _onToggled(
    RecurringToggled event,
    Emitter<RecurringState> emit,
  ) async {
    final bookId = event.rule.bookId ?? _bookId;
    final ruleId = event.rule.ruleId;
    if (bookId == null || ruleId == null) return;
    if (state.pendingToggleIds.contains(ruleId)) return;

    final original = state.rules;
    final optimistic = original
        .map(
          (r) => r.ruleId == ruleId
              ? RecurringRuleVo(
                  bookId: r.bookId,
                  ruleId: r.ruleId,
                  ruleName: r.ruleName,
                  cronExpression: r.cronExpression,
                  enable: event.enable,
                  billRequest: r.billRequest,
                  startDate: r.startDate,
                  endDate: r.endDate,
                  maxExecutions: r.maxExecutions,
                  executedCount: r.executedCount,
                  lastExecutedTime: r.lastExecutedTime,
                  nextExecutionTime: r.nextExecutionTime,
                  recoveryStrategy: r.recoveryStrategy,
                  remark: r.remark,
                )
              : r,
        )
        .toList();
    emit(
      state.copyWith(
        rules: optimistic,
        pendingToggleIds: {...state.pendingToggleIds, ruleId},
      ),
    );

    try {
      await _service.toggleRule(
        bookId: bookId,
        ruleId: ruleId,
        enable: event.enable,
      );
      final ids = _bookIds.isNotEmpty ? _bookIds : [bookId];
      final fresh = await _service.getRulesForBooks(ids);
      emit(
        state.copyWith(
          status: fresh.isEmpty
              ? RecurringStatus.empty
              : RecurringStatus.loaded,
          rules: fresh,
          pendingToggleIds: {...state.pendingToggleIds}..remove(ruleId),
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          rules: original,
          pendingToggleIds: {...state.pendingToggleIds}..remove(ruleId),
          toastMessage: e is FxApiException
              ? e.message
              : S.current.profileSaveFailedRetry,
          toastSerial: state.toastSerial + 1,
        ),
      );
    }
  }
}
