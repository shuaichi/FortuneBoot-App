part of 'goods_bloc.dart';

/// 归物 feature 事件。
sealed class GoodsEvent extends Equatable {
  const GoodsEvent();

  @override
  List<Object?> get props => [];
}

/// 首次加载/下拉刷新：并发拉列表 + 统计。
class GoodsLoaded extends GoodsEvent {
  final Completer<void>? completer;

  const GoodsLoaded({this.completer});

  @override
  List<Object?> get props => [completer];
}

/// 当前账本变化 → 重拉。
class GoodsBookChanged extends GoodsEvent {
  final int? bookId;
  const GoodsBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// 写操作（新增/修改/删除）成功后要求刷新。
class GoodsMutated extends GoodsEvent {
  final Completer<void>? completer;

  const GoodsMutated({this.completer});

  @override
  List<Object?> get props => [completer];
}
