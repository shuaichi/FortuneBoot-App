import 'package:equatable/equatable.dart';

/// 首页展示相关偏好，目前用于金额隐私显示。
class DashboardDisplayPreferences extends Equatable {
  /// 是否隐藏首页金额（显示为掩码）。
  final bool hideAmounts;

  const DashboardDisplayPreferences({this.hideAmounts = false});

  factory DashboardDisplayPreferences.defaults() =>
      const DashboardDisplayPreferences();

  DashboardDisplayPreferences copyWith({bool? hideAmounts}) {
    return DashboardDisplayPreferences(
      hideAmounts: hideAmounts ?? this.hideAmounts,
    );
  }

  @override
  List<Object?> get props => [hideAmounts];
}
