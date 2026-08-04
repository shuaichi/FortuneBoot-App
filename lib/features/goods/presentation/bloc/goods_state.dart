part of 'goods_bloc.dart';

enum GoodsViewStatus { initial, loading, loaded, error, empty }

class GoodsState extends Equatable {
  final GoodsViewStatus status;
  final List<FortuneGoodsKeeperVo> goods;
  final GoodsStatistics statistics;
  final String? errorMessage;
  final String? toastMessage;
  final String? currencyCode;

  const GoodsState({
    this.status = GoodsViewStatus.initial,
    this.goods = const [],
    this.statistics = const GoodsStatistics(),
    this.errorMessage,
    this.toastMessage,
    this.currencyCode,
  });

  GoodsState copyWith({
    GoodsViewStatus? status,
    List<FortuneGoodsKeeperVo>? goods,
    GoodsStatistics? statistics,
    String? errorMessage,
    String? toastMessage,
    String? currencyCode,
  }) {
    return GoodsState(
      status: status ?? this.status,
      goods: goods ?? this.goods,
      statistics: statistics ?? this.statistics,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    goods,
    statistics,
    errorMessage,
    toastMessage,
    currencyCode,
  ];
}
