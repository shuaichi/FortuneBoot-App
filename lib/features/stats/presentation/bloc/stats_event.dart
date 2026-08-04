part of 'stats_bloc.dart';

/// StatsBloc 事件。
sealed class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// 账本变更（来自 SessionCubit currentBookId）→ 重新并发拉取全部。
final class StatsBookChanged extends StatsEvent {
  final int? bookId;
  const StatsBookChanged({this.bookId});

  @override
  List<Object?> get props => [bookId];
}

/// 首屏 / 刷新：并发拉取全部图表数据。
final class StatsRefreshed extends StatsEvent {
  const StatsRefreshed();
}

/// 切换时间区间（本周/本月/本年/自定义）。
final class StatsRangeChanged extends StatsEvent {
  final StatsRange range;

  /// 自定义区间起止（仅 range==custom 时提供）。
  final DateTime? customStart;
  final DateTime? customEnd;

  const StatsRangeChanged(this.range, {this.customStart, this.customEnd});

  @override
  List<Object?> get props => [range, customStart, customEnd];
}

/// 切换类型（支出/收入）。
final class StatsTypeChanged extends StatsEvent {
  final StatsType type;
  const StatsTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// 账单月开始日变更，仅影响“本月”范围。
final class StatsMonthStartDayChanged extends StatsEvent {
  final int day;
  const StatsMonthStartDayChanged(this.day);

  @override
  List<Object?> get props => [day];
}
