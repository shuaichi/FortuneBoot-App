import 'package:equatable/equatable.dart';

/// 首页展示相关偏好：金额隐私 + 卡片布局（顺序 / 隐藏）。
class DashboardDisplayPreferences extends Equatable {
  /// 是否隐藏首页金额（显示为掩码）。
  final bool hideAmounts;

  /// 卡片顺序（存储用字符串 ID）。空表示使用目录默认顺序。
  final List<String> cardOrder;

  /// 隐藏的卡片 ID。
  final List<String> hiddenCardIds;

  /// 是否已从本地读到过布局键（区分「从未配置」与「用户清空隐藏」）。
  final bool layoutConfigured;

  const DashboardDisplayPreferences({
    this.hideAmounts = false,
    this.cardOrder = const [],
    this.hiddenCardIds = const [],
    this.layoutConfigured = false,
  });

  factory DashboardDisplayPreferences.defaults() =>
      const DashboardDisplayPreferences();

  DashboardDisplayPreferences copyWith({
    bool? hideAmounts,
    List<String>? cardOrder,
    List<String>? hiddenCardIds,
    bool? layoutConfigured,
  }) {
    return DashboardDisplayPreferences(
      hideAmounts: hideAmounts ?? this.hideAmounts,
      cardOrder: cardOrder ?? this.cardOrder,
      hiddenCardIds: hiddenCardIds ?? this.hiddenCardIds,
      layoutConfigured: layoutConfigured ?? this.layoutConfigured,
    );
  }

  @override
  List<Object?> get props => [
    hideAmounts,
    cardOrder,
    hiddenCardIds,
    layoutConfigured,
  ];
}
