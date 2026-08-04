import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/data/goods_service.dart';

part 'goods_event.dart';
part 'goods_state.dart';

/// 归物 Bloc：拉列表 + 统计条。切账本重拉。
class GoodsBloc extends Bloc<GoodsEvent, GoodsState> {
  final GoodsService _service;
  int? _bookId;

  GoodsBloc({GoodsService? service, int? bookId, String? currencyCode})
    : _service = service ?? GoodsService(),
      _bookId = bookId,
      super(GoodsState(currencyCode: currencyCode)) {
    on<GoodsLoaded>(_onLoaded);
    on<GoodsMutated>(_onLoaded);
    on<GoodsBookChanged>(_onBookChanged);
  }

  Future<void> _onBookChanged(
    GoodsBookChanged event,
    Emitter<GoodsState> emit,
  ) async {
    if (event.bookId == _bookId && state.status != GoodsViewStatus.initial) {
      return;
    }
    _bookId = event.bookId;
    await _load(emit);
  }

  Future<void> _onLoaded(GoodsEvent event, Emitter<GoodsState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<GoodsState> emit) async {
    final bookId = _bookId;
    if (bookId == null) {
      emit(state.copyWith(status: GoodsViewStatus.empty, goods: const []));
      return;
    }
    emit(state.copyWith(status: GoodsViewStatus.loading));
    try {
      final results = await Future.wait([
        _service.getPage(bookId: bookId, pageSize: 200),
        _service.getStatistics(bookId),
      ]);
      final page = results[0] as GoodsPage;
      final stats = results[1] as GoodsStatistics;
      emit(
        state.copyWith(
          status: page.rows.isEmpty
              ? GoodsViewStatus.empty
              : GoodsViewStatus.loaded,
          goods: page.rows,
          statistics: stats,
        ),
      );
    } on FxApiException catch (e) {
      emit(state.copyWith(status: GoodsViewStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(
        state.copyWith(status: GoodsViewStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
