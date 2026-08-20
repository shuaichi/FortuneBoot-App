import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/generated/l10n.dart';

part 'recurring_event.dart';
part 'recurring_state.dart';

/// 周期记账规则 Bloc：拉规则列表；启停乐观更新。
class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringService _service;
  final int? _bookId;

  RecurringBloc({RecurringService? service, int? bookId})
    : _service = service ?? RecurringService(),
      _bookId = bookId,
      super(const RecurringState()) {
    on<RecurringLoaded>(_onLoaded);
    on<RecurringMutated>(_onLoaded);
    on<RecurringToggled>(_onToggled);
  }

  Future<void> _onLoaded(
    RecurringEvent event,
    Emitter<RecurringState> emit,
  ) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: RecurringStatus.empty, rules: const []));
      return;
    }
    emit(state.copyWith(status: RecurringStatus.loading));
    try {
      final rules = await _service.getRules(bookId: bookId);
      emit(
        state.copyWith(
          status: rules.isEmpty
              ? RecurringStatus.empty
              : RecurringStatus.loaded,
          rules: rules,
        ),
      );
    } on FxApiException catch (e) {
      emit(
        state.copyWith(status: RecurringStatus.error, errorMessage: e.message),
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
    final bookId = _bookId;
    final ruleId = event.rule.ruleId;
    if (bookId == null || ruleId == null) return;

    if (state.pendingToggleIds.contains(ruleId)) return;

    final original = state.rules;
    final optimistic = original
        .map((r) => r.ruleId == ruleId ? _copyEnable(r, event.enable) : r)
        .toList();
    final pending = {...state.pendingToggleIds, ruleId};
    emit(state.copyWith(rules: optimistic, pendingToggleIds: pending));

    try {
      await _service.toggleRule(
        bookId: bookId,
        ruleId: ruleId,
        enable: event.enable,
      );
      final fresh = await _service.getRules(bookId: bookId);
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

  RecurringRuleVo _copyEnable(RecurringRuleVo r, bool enable) {
    return RecurringRuleVo(
      bookId: r.bookId,
      ruleId: r.ruleId,
      ruleName: r.ruleName,
      cronExpression: r.cronExpression,
      enable: enable,
      billRequest: r.billRequest,
      startDate: r.startDate,
      endDate: r.endDate,
      maxExecutions: r.maxExecutions,
      executedCount: r.executedCount,
      lastExecutedTime: r.lastExecutedTime,
      nextExecutionTime: r.nextExecutionTime,
      recoveryStrategy: r.recoveryStrategy,
      remark: r.remark,
    );
  }
}
