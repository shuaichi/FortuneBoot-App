import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';

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
      emit(state.copyWith(
        status: rules.isEmpty ? RecurringStatus.empty : RecurringStatus.loaded,
        rules: rules,
      ));
    } on FxApiException catch (e) {
      emit(state.copyWith(status: RecurringStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(state.copyWith(
        status: RecurringStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggled(
    RecurringToggled event,
    Emitter<RecurringState> emit,
  ) async {
    final bookId = _bookId;
    final ruleId = event.rule.ruleId;
    if (bookId == null || ruleId == null) return;

    final original = state.rules;
    final optimistic = original
        .map((r) => r.ruleId == ruleId
            ? _copyEnable(r, event.enable)
            : r)
        .toList();
    emit(state.copyWith(rules: optimistic));

    try {
      await _service.toggleRule(
        bookId: bookId,
        ruleId: ruleId,
        enable: event.enable,
      );
    } on Object catch (e) {
      emit(state.copyWith(
        rules: original,
        toastMessage:
            '切换失败：${e is FxApiException ? e.message : e.toString()}',
      ));
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
