import 'package:equatable/equatable.dart';

/// 统计页卡片布局偏好（顺序 / 隐藏），本地 SharedPreferences。
class StatsDisplayPreferences extends Equatable {
  final List<String> cardOrder;
  final List<String> hiddenCardIds;
  final bool layoutConfigured;

  const StatsDisplayPreferences({
    this.cardOrder = const [],
    this.hiddenCardIds = const [],
    this.layoutConfigured = false,
  });

  factory StatsDisplayPreferences.defaults() =>
      const StatsDisplayPreferences();

  StatsDisplayPreferences copyWith({
    List<String>? cardOrder,
    List<String>? hiddenCardIds,
    bool? layoutConfigured,
  }) {
    return StatsDisplayPreferences(
      cardOrder: cardOrder ?? this.cardOrder,
      hiddenCardIds: hiddenCardIds ?? this.hiddenCardIds,
      layoutConfigured: layoutConfigured ?? this.layoutConfigured,
    );
  }

  @override
  List<Object?> get props => [cardOrder, hiddenCardIds, layoutConfigured];
}
