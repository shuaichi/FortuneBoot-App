part of 'recurring_bloc.dart';

sealed class RecurringEvent extends Equatable {
  const RecurringEvent();

  @override
  List<Object?> get props => [];
}

/// 加载 / 刷新规则列表。
class RecurringLoaded extends RecurringEvent {
  const RecurringLoaded();
}

/// 启停某规则（乐观更新，失败回滚）。
class RecurringToggled extends RecurringEvent {
  final RecurringRuleVo rule;
  final bool enable;

  const RecurringToggled({required this.rule, required this.enable});

  @override
  List<Object?> get props => [rule.ruleId, enable];
}

/// 写操作（新增/编辑/删除）成功后重拉。
class RecurringMutated extends RecurringEvent {
  const RecurringMutated();
}
